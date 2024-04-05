<#
Pulls License Status

0=Unlicensed
1=Licensed
2=OOBGrace
3=OOTGrace
4=NonGenuineGrace
5=Notification
6=ExtendedGrace
#>
Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | where { $_.PartialProductKey } | select Description, LicenseStatus
