$accountname = Read-Host "enter user account"

Get-ADUser -Identity $accountname -Properties * | Select-Object -Property AccountLockoutTime