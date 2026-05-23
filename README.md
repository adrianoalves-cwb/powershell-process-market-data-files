# Market Data PowerShell Scripts

This folder contains utility scripts for:
- Archiving Market Data `.zip` files in network shares.
- Searching XML trace files across multiple servers and packaging results.

## Scripts Overview

### 1. `MarketDataArchiveAllFiles.ps1`
Archives all `.zip` files from each configured source folder to its destination folder.

Configured folder groups:
- `GROUP_A1`
- `GROUP_A2`
- `GROUP_B1`
- `GROUP_B2`
- `GROUP_C1`
- `GROUP_C2`

Source path pattern:
- `\\fake-corp-fileserver\dept-share\project123\market-data-root\<GROUP>\incoming-emails\`

Destination path rules:
- `GROUP_A1`, `GROUP_A2` -> `ARCHIVE_A\yyyyMM`
- `GROUP_B1`, `GROUP_B2` -> `ARCHIVE_B`
- `GROUP_C1`, `GROUP_C2` -> `ARCHIVE_C\yyyyMM`

Behavior:
- Creates destination folder if missing.
- Moves files with overwrite (`Move-Item -Force`).

---

### 2. `MarketDataArchiveMondayFiles.ps1`
Archives `.zip` files for `GROUP_A1` and `GROUP_A2` only when today is Monday.

Additional behavior:
- Excludes files containing today date (`yyyyMMdd`) in the file name.
- Destination uses `ARCHIVE_A\yyyyMM` for both groups.

Use case:
- Weekly (Monday) archive routine without moving files generated today.

---

### 3. `MarketDataArchivePCB_SVB_MondayBankHolidayFiles.ps1`
Archives `.zip` files for `GROUP_A1` and `GROUP_A2` when either:
- Today is Monday, or
- Today is listed in bank holidays config.

Bank holiday config file:
- `\\fake-corp-config\automation\market-data\config\Bank_Holidays.txt`

Expected date format in config:
- `dd/MM/yyyy`

Additional behavior:
- Excludes files containing today date (`yyyyMMdd`) in the file name.
- Destination uses `ARCHIVE_A\yyyyMM`.

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
- `FAKEAPP341`, `FAKEAPP342`, `FAKEAPP343`, `FAKEAPP344`, `FAKEAPP345`, `FAKEAPP346`, `FAKEAPP347`, `FAKEAPP455`, `FAKEAPP456`

Server path pattern:
- `\\<FAKE_SERVER>\trace$\APP_GDS_<DEALER>\logs`

Output location:
- Desktop subfolder: `FAKE_XML_RESULTS\<QueryString>_<yyyyMMdd>`
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
  - `\\fake-corp-fileserver\...`
  - `\\FAKE-SRV***\trace$\...`
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
