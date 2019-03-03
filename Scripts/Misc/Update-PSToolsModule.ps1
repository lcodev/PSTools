# Script used to copy the changes made to APLTools and re-importing the module with the updates
Copy-Item -Force -Recurse -Path D:\GitHub\PSTools\Modules\PSTools -Destination 'C:\Program Files\WindowsPowerShell\Modules' -PassThru
Copy-Item -Force -Recurse -Path D:\GitHub\PSTools\Modules\PSTools -Destination 'C:\Program Files\PowerShell\6-preview\Modules' -PassThru 

# Update module in powershel
Remove-Module -Name PSTools -ErrorAction SilentlyContinue 
Import-Module -Name PSTools