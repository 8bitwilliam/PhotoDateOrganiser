import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var sourceFolderButton: NSButton!
    @IBOutlet weak var destinationFolderButton: NSButton!
    @IBOutlet weak var organizeButton: NSButton!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var sourceDropView: FolderDropView!
    @IBOutlet weak var destinationDropView: FolderDropView!
    @IBOutlet weak var sourceFolderLabel: NSTextField!
    @IBOutlet weak var destinationFolderLabel: NSTextField!
    @IBOutlet weak var sourceFolderIcon: NSImageView!
    @IBOutlet weak var destinationFolderIcon: NSImageView!
    @IBOutlet weak var folderStructurePopUpButton: NSPopUpButton!

    var sourceFolderURL: URL?
    var destinationFolderURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sourceFolderIcon.alphaValue = 0.4
        destinationFolderIcon.alphaValue = 0.4
        
        if let sourceDrop = sourceDropView {
            sourceDrop.dropTarget = .source
            sourceDrop.onFolderDropped = { url in
                print("Dropped into source: \(url.path)")
                self.sourceFolderURL = url
                self.sourceFolderLabel.stringValue = url.lastPathComponent
                self.sourceFolderIcon.image = NSWorkspace.shared.icon(forFile: url.path)
                self.sourceFolderIcon.alphaValue = 1.0
            }
        }

        if let destDrop = destinationDropView {
            destDrop.dropTarget = .destination
            destDrop.onFolderDropped = { url in
                print("Dropped into destination: \(url.path)")
                self.destinationFolderURL = url
                self.destinationFolderLabel.stringValue = url.lastPathComponent
                self.destinationFolderIcon.image = NSWorkspace.shared.icon(forFile: url.path)
                self.destinationFolderIcon.alphaValue = 1.0
            }
        }

        if #available(macOS 12.0, *) {
            let folderIcon = NSWorkspace.shared.icon(for: .folder)
            sourceFolderIcon.image = folderIcon
            destinationFolderIcon.image = folderIcon
        } else {
            let folderIcon = NSWorkspace.shared.icon(forFileType: NSFileTypeForHFSTypeCode(OSType(kGenericFolderIcon)))
            sourceFolderIcon.image = folderIcon
            destinationFolderIcon.image = folderIcon
        }

        folderStructurePopUpButton.removeAllItems()
        folderStructurePopUpButton.addItems(withTitles: ["YYYY-MM-DD", "YYYY/MM-DD", "YYYY/MM/DD"])
    }

    @IBAction func chooseSourceFolder(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.begin { result in
            if result == .OK {
                self.sourceFolderURL = openPanel.url
                self.sourceFolderLabel.stringValue = self.sourceFolderURL?.lastPathComponent ?? "No Source Folder Selected"
                self.sourceFolderIcon.image = NSWorkspace.shared.icon(forFile: self.sourceFolderURL?.path ?? "")
            }
        }
    }

    @IBAction func chooseDestinationFolder(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.begin { result in
            if result == .OK {
                self.destinationFolderURL = openPanel.url
                self.destinationFolderLabel.stringValue = self.destinationFolderURL?.lastPathComponent ?? "No Destination Folder Selected"
                self.destinationFolderIcon.image = NSWorkspace.shared.icon(forFile: self.destinationFolderURL?.path ?? "")
            }
        }
    }

    @IBAction func organizeFiles(_ sender: Any) {
        guard let sourceFolderURL = sourceFolderURL, let destinationFolderURL = destinationFolderURL else {
            showAlert(message: "Please select source and destination folders.")
            return
        }

        DispatchQueue.global(qos: .background).async {
            self.organizeFilesInFolder(sourceFolderURL: sourceFolderURL, destinationFolderURL: destinationFolderURL)
        }
    }

    func organizeFilesInFolder(sourceFolderURL: URL, destinationFolderURL: URL) {
        let fileManager = FileManager.default
        let fileTypes = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "tif", "mov", "heic", "mp4", "avi", "mkv", "dmg", "aae"]

        var totalFiles = 0

        do {
            totalFiles = try countFilesInFolder(at: sourceFolderURL, with: fileTypes)

            DispatchQueue.main.async {
                self.progressBar.minValue = 0
                self.progressBar.maxValue = Double(totalFiles)
                self.progressBar.doubleValue = 0
            }

            try fileManager.enumerateFiles(at: sourceFolderURL, fileTypes: fileTypes) { url, _ in
                let creationDate = try url.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date()
                let year = String(format: "%04d", Calendar.current.component(.year, from: creationDate))
                let month = String(format: "%02d", Calendar.current.component(.month, from: creationDate))
                let day = String(format: "%02d", Calendar.current.component(.day, from: creationDate))

                let selectedStructure = self.folderStructurePopUpButton.titleOfSelectedItem
                var destinationFolder: URL

                switch selectedStructure {
                case "YYYY-MM-DD":
                    destinationFolder = destinationFolderURL.appendingPathComponent("\(year)-\(month)-\(day)")
                case "YYYY/MM-DD":
                    destinationFolder = destinationFolderURL.appendingPathComponent("\(year)/\(month)-\(day)")
                case "YYYY/MM/DD":
                    destinationFolder = destinationFolderURL.appendingPathComponent("\(year)/\(month)/\(day)")
                default:
                    destinationFolder = destinationFolderURL.appendingPathComponent("\(year)-\(month)-\(day)")
                }

                try fileManager.createDirectory(at: destinationFolder, withIntermediateDirectories: true, attributes: nil)

                var destinationURL = destinationFolder.appendingPathComponent(url.lastPathComponent)
                var counter = 1
                while fileManager.fileExists(atPath: destinationURL.path) {
                    let base = url.deletingPathExtension().lastPathComponent
                    let ext = url.pathExtension
                    let newName = "\(base)_\(counter).\(ext)"
                    destinationURL = destinationFolder.appendingPathComponent(newName)
                    counter += 1
                }

                try fileManager.moveItem(at: url, to: destinationURL)

                DispatchQueue.main.async {
                    self.progressBar.increment(by: 1)
                }
            }

            DispatchQueue.main.async {
                self.showAlert(message: "\(totalFiles) files organised successfully!")
            }

        } catch {
            DispatchQueue.main.async {
                self.showAlert(message: "Error: \(error.localizedDescription)")
            }
        }
    }

    func showAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    func countFilesInFolder(at folderURL: URL, with fileTypes: [String]) throws -> Int {
        var count = 0
        try FileManager.default.enumerateFiles(at: folderURL, fileTypes: fileTypes) { _, _ in
            count += 1
        }
        return count
    }
}

extension FileManager {
    func enumerateFiles(at folderURL: URL, fileTypes: [String], handler: (URL, String) throws -> Void) throws {
        let enumerator = self.enumerator(at: folderURL, includingPropertiesForKeys: [.creationDateKey], options: [.skipsHiddenFiles, .skipsPackageDescendants])
        while let fileURL = enumerator?.nextObject() as? URL {
            if fileTypes.contains(fileURL.pathExtension.lowercased()) {
                try handler(fileURL, fileURL.pathExtension.lowercased())
            }
        }
    }
}
