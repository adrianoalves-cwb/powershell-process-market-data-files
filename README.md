# Market Data PowerShell Scripts

This folder contains utility scripts for:
- Archiving Market Data `.zip` files in network shares.
- Searching XML trace files across multiple servers and packaging results.

## Scripts Overview

### 1. `MarketDataArchiveAllFiles.ps1`
Archives all `.zip` files from each configured source folder to its destination folder.

Configured folder groups:
- `MARK_PCB`
- `MARK_SVB`
- `MARK_PCA`
- `MARK_SVA`
- `MARKM_PCA`
- `MARKM_SVA`

Source path pattern:
- `\\vcn.ds.volvo.net\cli-sd\sd0855\043160\01.GDS Database\<GROUP>\Database from e-mails\`

Destination path rules:
- `MARK_PCB`, `MARK_SVB` -> `Base_OK\yyyyMM`
- `MARK_PCA`, `MARK_SVA` -> `Agrupar excel`
- `MARKM_PCA`, `MARKM_SVA` -> `OK\yyyyMM`

Behavior:
- Creates destination folder if missing.
- Moves files with overwrite (`Move-Item -Force`).

---

### 2. `MarketDataArchiveMondayFiles.ps1`
Archives `.zip` files for `MARK_PCB` and `MARK_SVB` only when today is Monday.

Additional behavior:
- Excludes files containing today date (`yyyyMMdd`) in the file name.
- Destination uses `Base_OK\yyyyMM` for both groups.

Use case:
- Weekly (Monday) archive routine without moving files generated today.

---

### 3. `MarketDataArchivePCB_SVB_MondayBankHolidayFiles.ps1`
Archives `.zip` files for `MARK_PCB` and `MARK_SVB` when either:
- Today is Monday, or
- Today is listed in bank holidays config.

Bank holiday config file:
- `\\vcn.ds.volvo.net\it-cta\ITPROJ02\002378\DESENV\DBS\AUTOMATOR\MARK_DATA\Automator-MARKET_DATA_Bank_Holidays.txt`

Expected date format in config:
- `dd/MM/yyyy`

Additional behavior:
- Excludes files containing today date (`yyyyMMdd`) in the file name.
- Destination uses `Base_OK\yyyyMM`.

Use case:
- Monday process that also runs on configured bank holidays.

---

### 4. `SearchForFilesInNetworkFolders.ps1`
Interactive script that searches `.xml` trace files across multiple servers, copies matches, and creates a zip archive.

Prompts:
- Dealer Group Number (2 digits)
- Year (4 digits)
- Month (2 digits)
- Day (2 digits)
- Query String

Special rule:
- Dealer `06` is converted to empty dealer suffix.

Servers scanned:
- `BRCTAN341`, `BRCTAN342`, `BRCTAN343`, `BRCTAN344`, `BRCTAN345`, `BRCTAN346`, `BRCTAN347`, `BRCTAN455`, `BRCTAN456`

Server path pattern:
- `\\<SERVER>\trace41$\CIGAM_GDS_<DEALER>\trace`

Output location:
- Desktop subfolder: `DBS_XML_CIGAM\<QueryString>_<yyyyMMdd>`
- XML copies: `...\XML`
- Zip archive: `...\ZIP\<QueryString>_<yyyyMMdd>.zip`

Behavior:
- Removes previous result folders not from today.
- Filters XML files by date in filename (`yyyy-MM-dd`).
- Keeps files where content contains the query string (`Select-String -SimpleMatch`).
- Creates zip package from found XML files.

## Prerequisites

- PowerShell (Windows PowerShell 5.1 or PowerShell 7+).
- Network access and permissions to:
  - `\\vcn.ds.volvo.net\...`
  - `\\BRCTAN***\trace41$\...`
- Read/write access to destination folders.

## How To Run

Run from this folder in PowerShell:

```powershell
# Archive all configured groups
.\MarketDataArchiveAllFiles.ps1

# Archive PCB/SVB only on Monday
.\MarketDataArchiveMondayFiles.ps1

# Archive PCB/SVB on Monday or bank holiday
.\MarketDataArchivePCB_SVB_MondayBankHolidayFiles.ps1

# Interactive XML search across servers
.\SearchForFilesInNetworkFolders.ps1
```

## Notes and Operational Considerations

- Archiving scripts use `Move-Item -Force`; existing destination files can be overwritten.
- Running scripts with insufficient network permissions will fail while reading, creating, copying, or moving files.
- The search script is interactive and intended for manual execution.
- For scheduled execution, run with an account that has required network share permissions.
