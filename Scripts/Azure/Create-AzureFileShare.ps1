$StorageContext = New-AzureStorageContext -StorageAccountName "accountname" -StorageAccountKey "accesskey"
$new_share = New-AzureStorageShare -Name lcotest -Context $StorageContext