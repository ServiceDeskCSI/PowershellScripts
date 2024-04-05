<#
This script will kill the browser task and clear the cache for the listed user. Script is setup to work with 
variables on deployment software but you can also fill out the info below. 
#>

$ClearEdge = "True"
$ClearChrome = "True"
$UserPS = "UserHere"

if ($ClearChrome -eq "True"){
	Stop-Process -Name "chrome" -ErrorAction SilentlyContinue -Force -Confirm:$false
	$UsernamePS = "$UserPS"
	Start-Sleep -Seconds 5
	$Items = @('Archived History',
				'Cache\*',
				'Cookies',
				'History',
				'Login Data',
				'Top Sites',
				'Visited Links',
				'Web Data')
	$Folder = "C:\Users\$UsernamePS\AppData\Local\Google\Chrome\User Data\Default"
	$Items | % { 
		if (Test-Path "$Folder\$_") {
			Remove-Item "$Folder\$_" -Recurse -Force -Confirm:$false
			write-host "Clearing Chrome Cache, Cookies, History, Web Data"
		}
	}
} 

if($ClearEdge -eq "True"){
	Stop-Process -Name "*Edge*" -ErrorAction SilentlyContinue -Force -Confirm:$false
	$UsernamePS = "$UserPS"
	Start-Sleep -Seconds 5
	$Items = @('Archived History',
				'Cache\*',
				'Cookies',
				'History',
				'Login Data',
				'Top Sites',
				'Visited Links',
				'Web Data')
	$Folder = "C:\Users\$UsernamePS\AppData\Local\Microsoft\Edge\User Data\Default"
	$Items | % { 
		if (Test-Path "$Folder\$_") {
			Remove-Item "$Folder\$_" -Recurse -Force -Confirm:$false
			write-host "Clearing Edge Cache, Cookies, History, Web Data"
		}
	}
}
write-host "Task Done"