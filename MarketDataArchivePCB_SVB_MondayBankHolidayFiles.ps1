

#ADDING THE LIST OF THE FOLDERS/FILES TYPES TO A VARIABLE
$folders = @('MARK_PCB', 'MARK_SVB')

#PATH TO THE NETWORK FOLDER AND THE BANK HOLIDAYS FILE
$networkFolder = '\\fake-corp-fileserver\dept-share\project123\market-data-root\'
$bankHolidaysConfigFile = '\\fake-corp-config\automation\market-data\config\Bank_Holidays.txt'

#GETTING THE CURRENT MONTH
$currentMonth = get-date -Format "yyyyMM"
$today = get-date -Format "yyyyMMdd"
$dayOfTheWeek = (Get-Date).DayOfWeek

#READING THE BANK HOLIDAYS CONFIG FILE
$isTodayBankHoliday = $false

foreach ($line in Get-Content $bankHolidaysConfigFile) {
    if ($line -match (get-date -Format 'dd/MM/yyyy')) {
        $isTodayBankHoliday = $true
    }
}

#IF TODAY IS MONDAY OR BANK HOLIDAY, THE PCB AND SVB FILES CAN BE ARCHIVED
if ($dayOfTheWeek -match "Monday" -or $isTodayBankHoliday) {
    #LOOPING THROUGH THE MARKET DATA FOLDER $folders
    foreach ($folder in $folders) {
        $sourceFolderPath = $networkFolder + $folder + '\Database from e-mails\'
        $destinationFolderPath = $networkFolder + $folder

        #CREATING THE DESTINATION FOLDER PATH BASED ON EACH FOLDER/FILE TYPE
        switch ($folder) {
            'MARK_PCB' { $destinationFolderPath += '\Base_OK\' + $currentMonth }
            'MARK_SVB' { $destinationFolderPath += '\Base_OK\' + $currentMonth }
        }
    
        #LOOPING THROUGH ALL THE FILES IN THE SOURCE FOLDER AND FILTERING TO ONLY CHECK THE ZIP FILES
        foreach ($file in (Get-ChildItem $sourcefolderPath -Filter *.zip)) {
            if (!($file.Name -like "*$today*")) {
                #CONFIRMING THAT THE DESTINATION FOLDER EXISTS. IF IT DOES NOT, THAT IT WILL BE CREATED
                #The below makes sure the folder named with the current month exists when we reach the 'next' month. For example: 202007 (2020=Year, 07=July)
                if (!(Test-Path $destinationFolderPath)) {
                    #CREATING THE NEW FOLDER
                    New-Item $destinationFolderPath -ItemType Directory
                }

                #MOVING THE FILES FROM SOURCE PATH TO THE DESTINATION PATH ADDING -FORCE TO OVERWRITE ANY EXISTING FILES IN THE DESTINATION FOLDER
                Move-Item -Path $file.FullName -Destination $destinationFolderPath -Force
            }
        }
    }
}


