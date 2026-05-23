

#GETTING USER´S DESKTOP PATH

$DesktopPath = [Environment]::GetFolderPath("Desktop") + '\DBS_XML_CIGAM\'

#GETTING TODAY´S DATE

$today = get-date -Format "yyyyMMdd"

$servers = @('BRCTAN341', 'BRCTAN342', 'BRCTAN343', 'BRCTAN344', 'BRCTAN345', 'BRCTAN346', 'BRCTAN347', 'BRCTAN455', 'BRCTAN456')

#MENU

clear

$dealer = Read-Host 'Dealer Group Number (2 digits)'
$year = Read-Host 'Year (4 digits)'
$month = Read-Host 'Month (2 digits)'
$day = Read-Host 'Day (2 digits)'
$queryString = Read-Host 'Query String'

#DEALER 06 DIPESUL DOES NOT HAVE A NUMBER

if ($dealer -eq '06') {
    $dealer = ''
}
clear

#DELETING ALL THE FOLDERS THAT WERE NOT CREATED TODAY (EG. YESTERDAY)

if (!(Test-Path $DesktopPath)) {
    New-Item $DesktopPath -ItemType directory
}

foreach ($folder in (Get-ChildItem $DesktopPath)) {
    if ($folder.Fullname -notmatch $today) {
        Remove-Item $folder.FullName -Force -Recurse
    }
}


#CREATING THE NEW FOLDER

$newBaseFolder = $DesktopPath + $queryString + '_' + $today
$newXMLFolder = $DesktopPath + $queryString + '_' + $today + '\XML'
$newZipFolder = $DesktopPath + $queryString + '_' + $today + '\ZIP'

#CHECKING IF THE FOLDER ALREADY EXISTS. IF SO, THE FOLDER WILL NOT BE CREATED
if (!(Test-Path $newXMLFolder)) {
    New-Item $newXMLFolder -ItemType directory
    New-Item $newZipFolder -ItemType directory
}


#COUNTING HOW MANY SERVERS THE SCRIPT WILL NEED TO CHECK
$numberOfServers = 0
foreach ($server in $servers) {
    $numberOfServers++
}

$serverCounter = 1

#SEARCHING THE FOLDERS IN THE SERVERS
foreach ($server in $servers) {

    clear
    Write-Host 'Searching files in the server' $server '(' $serverCounter 'of' $numberOfServers '). Please wait...'

    $folderPath = '\\' + $server + '\trace41$\CIGAM_GDS_' + $dealer + '\trace'
    $fileDate = $year + '-' + $month + '-' + $day

    foreach ($file in (Get-ChildItem $folderPath -Filter *.xml -Recurse | Where-Object { $_.Name -match $fileDate })) {
        if (Select-String $file.FullName -Pattern $queryString -SimpleMatch) {
            Copy-Item -Path $file.FullName -Destination $newXMLFolder
        }
    }

    $serverCounter++
}

clear

#COUNTING HOW MANY FILES HAVE BEEN FOUND
$filesFound = @(Get-ChildItem $newXMLFolder).Count

if ($filesFound -ge 0) {
    
    #ZIPPING THE FILES
    $zipFileName = $queryString + '_' + $today + '.zip'
    $source = $newXMLFolder
    $archive = $newZipFolder + '\' + $zipFileName

    Add-Type -assembly "system.io.compression.filesystem"
    [io.compression.zipfile]::CreateFromDirectory($source, $archive)
    
    #INFORMING THE USER THAT THE SEARCH HAS COMPLEATED
    Write-Host 'File searching has completed.' $filesFound 'file(s) could be found. Please check the folder:' $newBaseFolder
    Invoke-Item $newBaseFolder
}
else {
    #INFORMING THE USER THAT THE SEARCH HAS COMPLEATED - NO FILES FOUND
    Write-Host 'File searching has completed. No XML file could be found' 
}


# If running in the console, wait for input before closing.
if ($Host.Name -eq "ConsoleHost") {
    Write-Host "Press any key to close this window..."
    $Host.UI.RawUI.FlushInputBuffer()   # Make sure buffered input doesn't "press a key" and skip the ReadKey().
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") > $null
}

