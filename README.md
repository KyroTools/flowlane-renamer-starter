# Flowlane Renamer Starter

### Bulk File Renamer for Windows

Bulk File Renamer for Windows – rename thousands of files safely with preview, undo, collision detection, and advanced batch operations.

Whether you're organizing photos, engineering documents, archives, downloads, or project files, Flowlane Renamer helps automate repetitive renaming tasks in seconds.

---

## Features

### Free Version

* Add prefixes to filenames
* Add suffixes to filenames
* Replace text in filenames
* Remove text from filenames
* Automatic numbering
* Change filename case
* Optional rename preview
* Undo previous operations
* Filename collision detection

---

## System Requirements

* Windows 10 or Windows 11
* Windows PowerShell 5.1 or later
* PowerShell 7 supported

No installation required.

---

# Getting Started

## 1. Download and Extract

Extract the application files to a folder of your choice.

Example:

```text
C:\Tools\FlowlaneRenamer
```

---

## 2. Open PowerShell

Launch either:

* Windows PowerShell
* PowerShell 7

---

## 3. Navigate to the Application Folder

```powershell
cd C:\Tools\FlowlaneRenamer
```

---

## 4. Launch Flowlane Renamer

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\FlowLane_Renamer_Starter_v1.ps1
```

At startup, you will be asked to select a working directory.

---

# Main Menu

```text
Working folder : D:\Photos
Preview mode   : ON

1 Add Prefix
2 Add Suffix
3 Replace Text
4 Remove Text
5 Auto Number
6 Change Case
7 Undo
8 Change Working Folder
9 Toggle Preview
0 Exit
```

---

# Function Reference

## Add Prefix

Adds text at the beginning of each filename.

Example:

```text
IMG_001.jpg
```

becomes:

```text
Paris_IMG_001.jpg
```

---

## Add Suffix

Adds text before the file extension.

Example:

```text
Report.docx
```

becomes:

```text
Report_Final.docx
```

---

## Replace Text

Replaces text within filenames.

Example: replace "Draft" by "Final"

```text
Draft_Report.docx
```

becomes:

```text
Final_Report.docx
```

Replacement is case-insensitive.

---

## Remove Text

Removes a specific text string.

Example:

```text
Photo_Copy.jpg
```

becomes:

```text
Photo.jpg
```

---

## Auto Number

Adds sequential numbering.

Example:

```text
Photo.jpg
```

becomes:

```text
Photo_001.jpg
Photo_002.jpg
Photo_003.jpg
```

Configurable:

* Starting number
* Number of digits

---

## Change Case

Available modes:

### UPPERCASE

```text
report.docx
```

↓

```text
REPORT.docx
```

### lowercase

```text
REPORT.docx
```

↓

```text
report.docx
```

### Title Case

```text
monthly report.docx
```

↓

```text
Monthly Report.docx
```

---

## Preview Mode

When enabled, a preview table is displayed before files are renamed.

This allows you to verify changes before execution.

Preview mode can be enabled or disabled from the main menu.

---

## Undo

Flowlane Renamer automatically stores rename operations in JSON log files.

The Undo function allows you to revert previous rename operations.

---

## Change Working Folder

Switch to another folder without restarting the application.

---

# Safety Features

Flowlane Renamer includes several safeguards:

* Rename preview
* User confirmation before execution
* Collision detection
* Undo support
* Persistent operation logs

The application never intentionally overwrites existing files.

---

# Typical Use Cases

### Photography

```text
IMG_1234.jpg
```

↓

```text
Paris_2025_IMG_1234.jpg
```

### Engineering Documents

```text
Report.docx
```

↓

```text
ProjectX_Report_V1.docx
```

### Archive Cleanup

```text
Invoice_Copy.pdf
```

↓

```text
Invoice.pdf
```

---


# About

**Flowlane Renamer**
**Bulk File Renamer for Windows**

Fast, safe and efficient bulk file renaming.
