📸 Photo Date Organiser

Photo Date Organiser is a macOS app designed to help users quickly organise folders of photos and videos by their creation date. It supports a wide range of file types and creates date-based subfolders for easy browsing and archival.

<img width="412" height="443" alt="Screenshot 2025-10-17 at 13 56 02" src="https://github.com/user-attachments/assets/fc0d579c-cfb7-450a-9937-0d3cd180cb07" />

⸻

✨ Features
	•	🗂️ Automatic folder sorting — organise photos and videos into:
	•	YYYY-MM-DD
	•	YYYY/MM-DD
	•	YYYY/MM/DD
	•	📸 Photo support — JPG, PNG, HEIC, GIF, BMP, TIFF, etc.
	•	🎞️ Video support — MP4, MOV, AVI, MKV, etc.
	•	🧠 Simple UI — drag-and-drop folders or use the “Select” buttons

⸻

🧭 Installation (macOS)

⚠️ This is not a signed app. macOS may warn you when opening it. If you’d rather build it yourself, follow the steps below.

Option 1: Using the prebuilt .app (may trigger macOS security prompt)
	1.	Download the latest release from the Releases page.
	2.	Unzip the archive.
	3.	Right-click the .app file and select Open.

Option 2: Build it yourself using Xcode (recommended)
	1.	Clone or download the project.
	2.	Open PhotoDateOrganizer.xcodeproj in Xcode.
	3.	Select your desired target and build the project.
	4.	Run the app via Xcode or export a release build.

⸻

▶️ Usage
	1.	Launch the app.
	2.	Drag and drop the source folder (containing photos/videos) into the left panel.
	3.	Drag and drop the destination folder into the right panel.
	4.	Select your desired folder structure (e.g. YYYY/MM/DD).
	5.	Click Organise.
	6.	The app will scan the files, extract creation dates, and move them to appropriate subfolders.

⸻

📁 Output Example

DestinationFolder/

├── 2025/

│   └── 10/

│       └── 14/

│           ├── IMG_1234.jpg

│           ├── IMG_1234.mov

│           └── IMG_1234.heic

Each folder corresponds to the selected format. Files are preserved and renamed only if duplicates exist.

⸻

🧩 Technical Notes
	•	Supports drag-and-drop or manual folder selection
	•	Organises by file creation date (not modified date)

⸻

ℹ️ About

Photo Date Organiser is designed for users who want to clean up their camera roll, photo dumps, or downloads without complex photo management tools.
