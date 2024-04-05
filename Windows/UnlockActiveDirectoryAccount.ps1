$Username = "Username"
Search-ADAccount -lockedout | Select-Object Name, SamAccountName
Unlock-ADAccount -Identity $Username