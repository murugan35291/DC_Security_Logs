<#

.SYNOPSIS
     * To Zip the archived security logs from domain controller provided in the Dclist.txt file. 
     * Copy the zipped file to the remote server specified in the remote server parameter value


# .Example

Example1: .\DC_EventLog_Backup_v1.ps1 -remoteServer 'Server1' -dclisting '.\Dclist.txt'

.NOTES
Author : murugan.natarajan@outlook.com
Date   : 20/April/2018


#>

# Parameters


    Param(
        
        [string]$remoteServer='Server1',
        [string]$DCsListing='.\DCList.txt'
    
    )

    
# Defining Global Parameters

$Logdate=Get-Date -Format ddMMyyyy-hh-mm    # for Logfilename
$CurrentDate= Get-date -Format dd-MMM-yyyy  # folder creation purpose
#$remoteServer="Server1"


#$DCsList = "Server002,server001,Server004"
#$DCsListing=$DCsList.Split(",")

foreach ($DomainCntrl in (Get-content $DCsListing))
{

    $SourceLocation="\\$DomainCntrl\c$\windows\System32\Winevt\Logs"
    $DestinationLoc="\\$remoteServer\H$\DC_Security_Logs\$DomainCntrl"
    $Logfile="\\$remoteServer\H$\DC_Security_Logs\Transfer_Logs\$CurrentDate-$DomainCntrl.log"


If (-not (Test-Path -Path "$DestinationLoc\$CurrentDate"))
{

         New-Item -ItemType directory -Path $DestinationLoc -Name $CurrentDate | Out-Null
         $Message="Today's folder does not exist,hence created it"
         $Message | Out-File -Append $Logfile
         
}
    else 
        {
            $Message = "Today's date folder exists on the remote path"
            $Message | Out-File -Append $Logfile
                }

# Check whether Archive files are exist and send log information 

$checkforArchive= Get-ChildItem -Path $SourceLocation\Arch*.evtx

$pathfor7zip='.\7-Zip64'
$Archivename="$sourcelocation\Archive-$CurrentDate-$DomainCntrl.zip"
If ( -not ($checkforArchive -eq $null))

{

 # Compressing the files to single file in Security Log

 & "$pathfor7zip\7z.exe" a -tzip "$Archivename" $checkforArchive | Out-File -Append $Logfile

     Copy-Item "$Archivename" -Destination "$DestinationLoc\$CurrentDate"

     $Message="Copied items $Archivename to the share"
     $Message | Out-File -Append $Logfile


     # Clearing Archive after successfull copying 

Remove-Item $checkforArchive -Force
$Message="Cleard the $checkforArchive items from Logs folder"
$Message | Out-File -Append $Logfile

# Clearing the original Archive files from DC logs folder to save space.
Remove-Item $Archivename -Force
$Message="Cleard the $Archivename items from Logs folder"
$Message | Out-File -Append $Logfile

 }
  

 Else
        {

        $Message="Something wrong with the Archive configuration on this server or Archive files are missing"
        $Message | Out-File -Append $Logfile
}

}

