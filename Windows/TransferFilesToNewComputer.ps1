if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host("Running as administrator! Please run PowerShell as user.") -ForegroundColor Red;
	Start-Sleep -Seconds 10 
}
$UserPS = Read-Host -Prompt 'Enter Username:'
$NewPC = Read-Host -Prompt 'Enter New Computer Hostname:'

New-Item -ItemType "directory" -Path "c:\users\$UserPS\desktop\CSI"
write-host "Saving files to c:\users\$UserPS\desktop\CSI"
<#
Export Bookmarks 
#>

# Path to EdgeChromium Bookmarks File and HTML Export
$JSON_File_Path_Edge = "C:\Users\" + $UserPS + "\AppData\Local\Microsoft\Edge\User Data\Default\Bookmarks"
$ExportedTime = Get-Date -Format 'yyyy-MM-dd_HH.mm'
$HTML_File_Root = "c:\users\$UserPS\desktop\CSI"
$HTML_File_Path = "$($HTML_File_Root)\Edge-Bookmarks.html"
# Reference-Timestamp needed to convert Timestamps of JSON (Milliseconds / Ticks since LDAP / NT epoch 01.01.1601 00:00:00 UTC) to Unix-Timestamp (Epoch)
$Date_LDAP_NT_EPOCH = Get-Date -Year 1601 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0
if (!(Test-Path -Path $HTML_File_Root -PathType Container)) { 
    #throw "Destination-Path $HTML_File_Path does not exist!" 
    write-output $HTML_File_Root not found
}
$EdgeError = $JSON_File_Path_Edge + " not found"
if (!(Test-Path -Path $JSON_File_Path_Edge -PathType Leaf)) {
    #throw "Source-File Path $JSON_File_Path_Edge does not exist!" 
    write-output $EdgeError
}else {
write-output "Exporting Edge Bookmarks to CSI Folder" 
# ---- HTML Header ----
$BookmarksHTML_Header = @'
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<!-- This is an automatically generated file.
     It will be read and overwritten.
     DO NOT EDIT! -->
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<TITLE>Bookmarks</TITLE>
<H1>Bookmarks</H1>
<DL><p>
'@

$BookmarksHTML_Header | Out-File -FilePath $HTML_File_Path -Force -Encoding utf8

# ---- Enumerate Bookmarks Folders ----
Function Get-BookmarkFolder {
    [cmdletbinding()] 
    Param( 
        [Parameter(Position = 0, ValueFromPipeline = $True)]
        $Node 
    )
    function ConvertTo-UnixTimeStamp {
        param(
            [Parameter(Position = 0, ValueFromPipeline = $True)]
            $TimeStamp 
        )
        $date = [Decimal] $TimeStamp
        if ($date -gt 0) { 
            $date = $Date_LDAP_NT_EPOCH.AddTicks($date * 10)
            $date = $date | Get-Date -UFormat %s 
            $unixTimeStamp = [int][double]::Parse($date) - 1
            return $unixTimeStamp
        }
    }   
    if ($node.name -like "Favorites Bar") {
        $DateAdded = [Decimal] $node.date_added | ConvertTo-UnixTimeStamp
        $DateModified = [Decimal] $node.date_modified | ConvertTo-UnixTimeStamp
        "        <DT><H3 FOLDED ADD_DATE=`"$($DateAdded)`" LAST_MODIFIED=`"$($DateModified)`" PERSONAL_TOOLBAR_FOLDER=`"true`">$($node.name )</H3>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
        "        <DL><p>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
    }
    foreach ($child in $node.children) {
        $DateAdded = [Decimal] $child.date_added | ConvertTo-UnixTimeStamp    
        $DateModified = [Decimal] $child.date_modified | ConvertTo-UnixTimeStamp
        if ($child.type -eq 'folder') {
            "        <DT><H3 ADD_DATE=`"$($DateAdded)`" LAST_MODIFIED=`"$($DateModified)`">$($child.name)</H3>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
            "        <DL><p>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
            Get-BookmarkFolder $child # Recursive call in case of Folders / SubFolders
            "        </DL><p>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
        }
        else {
            # Type not Folder => URL
            "        <DT><A HREF=`"$($child.url)`" ADD_DATE=`"$($DateAdded)`">$($child.name)</A>" | Out-File -FilePath $HTML_File_Path -Append -Encoding utf8
        }
    }
    if ($node.name -like "Favorites Bar") {
        "        </DL><p>" | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
    }
}

# ---- Convert the JSON Contens (recursive) ----
$data = Get-content $JSON_File_Path_Edge -Encoding UTF8 | out-string | ConvertFrom-Json
$sections = $data.roots.PSObject.Properties | Select-Object -ExpandProperty name
ForEach ($entry in $sections) { 
    $data.roots.$entry | Get-BookmarkFolder
}

# ---- HTML Footer ----
'</DL>' | Out-File -FilePath $HTML_File_Path -Append -Force -Encoding utf8
# Edge Booksmarks Done
}

#Path to chrome bookmarks
$JSON_File_Path_Chrome = "C:\Users\" + $UserPS + "\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"

$htmlOut = "$($HTML_File_Root)\Chorme-Bookmarks.html"

$ChromeError = $JSON_File_Path_Chrome + " not found"
if (!(Test-Path -Path $JSON_File_Path_Chrome -PathType Leaf)) {
    #throw "Source-File Path $JSON_File_Path_Chrome does not exist!" 
    write-output $ChromeError
}else {
write-output "Exporting Chrome Bookmarks to CSI Folder"
   $htmlHeader = @'
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<!--This is an automatically generated file.
    It will be read and overwritten.
    Do Not Edit! -->
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<Title>Bookmarks</Title>
<H1>Bookmarks</H1>
<DL><p>
'@

$htmlHeader | Out-File -FilePath $htmlOut -Force -Encoding utf8 #line59

#A nested function to enumerate bookmark folders
Function Get-BookmarkFolder {
[cmdletbinding()]
Param(
[Parameter(Position=0,ValueFromPipeline=$True)]
$Node
)

Process 
{

 foreach ($child in $node.children) 
 {
   $da = [math]::Round([double]$child.date_added / 1000000) #date_added - from microseconds (Google Chrome {dates}) to seconds 'standard' epoch.
   $dm = [math]::Round([double]$child.date_modified / 1000000) #date_modified - from microseconds (Google Chrome {dates}) to seconds 'standard' epoch.
   if ($child.type -eq 'Folder') 
   {
     "    <DT><H3 FOLDED ADD_DATE=`"$($da)`">$($child.name)</H3>" | Out-File -FilePath $htmlOut -Append -Force -Encoding utf8
     "       <DL><p>" | Out-File -FilePath $htmlOut -Append -Force -Encoding utf8
     Get-BookmarkFolder $child
     "       </DL><p>" | Out-File -FilePath $htmlOut -Append -Force -Encoding utf8
   }
   else 
   {
        "       <DT><a href=`"$($child.url)`" ADD_DATE=`"$($da)`">$($child.name)</a>" | Out-File -FilePath $htmlOut -Append -Encoding utf8
  } #else url
 } #foreach
 } #process
} #end function

$data = Get-content $JSON_File_Path_Chrome -Encoding UTF8 | out-string | ConvertFrom-Json
$sections = $data.roots.PSObject.Properties | select -ExpandProperty name
ForEach ($entry in $sections) {
    $data.roots.$entry | Get-BookmarkFolder
}
'</DL>' | Out-File -FilePath $htmlOut -Append -Force -Encoding utf8
# Chrome Bookmarks done
}

<#
Export Drives and Printers 
#>
write-host "Saving Drives and Printers to CSI Folder"
cmd /c wmic printer list brief > "c:\users\$UserPS\desktop\CSI\Printers.txt"
cmd /c net use > "c:\users\$UserPS\desktop\CSI\Mapped_Drives.txt"
Start-Sleep -Seconds 5 
<#
Move Files 
#>
write-host "Lets try moving files"
if (Test-Path -Path c:\users\$UserPS\Desktop) {
	if (Test-Path -Path \\$NewPC\C$\Users\$UserPS\Desktop){
		write-host "Moving: Desktop Folder"
		Move-Item “Path c:\users\$UserPS\Desktop -Destination \\$NewPC\C$\Users\$UserPS\Desktop -force
	}
}

if (Test-Path -Path c:\users\$UserPS\Documents) {
	if (Test-Path -Path \\$NewPC\C$\Users\$UserPS\Documents){
		write-host "Moving: Documents Folder"
		Move-Item “Path c:\users\$UserPS\Documents -Destination \\$NewPC\C$\Users\$UserPS\Documents -force
	}
}


if (Test-Path -Path c:\users\$UserPS\Links) {
	if (Test-Path -Path \\$NewPC\C$\Users\$UserPS\Links){
		write-host "Moving: Links Folder"
		Move-Item “Path c:\users\$UserPS\Links -Destination \\$NewPC\C$\Users\$UserPS\Links -force
	}
}
if (Test-Path -Path c:\users\$UserPS\Favorites) {
	if (Test-Path -Path \\$NewPC\C$\Users\$UserPS\Favorites){
		write-host "Moving: Favorites Folder"
		Move-Item “Path c:\users\$UserPS\Favorites -Destination \\$NewPC\C$\Users\$UserPS\Favorites -force
	}
}
