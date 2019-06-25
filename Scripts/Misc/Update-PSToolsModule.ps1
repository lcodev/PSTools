# Script used to copy the changes made to APLTools and re-importing the module with the updates
Copy-Item -Force -Recurse -Path C:\Users\luper\GitRepo\PSTools\Modules\PSTools -Destination 'C:\Program Files\WindowsPowerShell\Modules' -PassThru
Copy-Item -Force -Recurse -Path C:\Users\luper\GitRepo\PSTools\Modules\PSTools 'C:\Program Files\PowerShell\7-preview\Modules' -PassThru 

# Update module in powershel
Remove-Module -Name PSTools -ErrorAction SilentlyContinue 
Import-Module -Name PSTools