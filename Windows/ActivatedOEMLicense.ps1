# Grabs OEM Hardware license from like Dell Machines and activates it.
$computer = gc env:computername
$key = (wmic path softwarelicensingservice get oa3xoriginalproductkey)[2].Trim()
Write-Output $key
$service = get-wmiObject -query "select * from SoftwareLicensingService" -computername $computer
$service.InstallProductKey($key)
$service.RefreshLicenseStatus()
Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | where { $_.PartialProductKey } | select Description, LicenseStatus