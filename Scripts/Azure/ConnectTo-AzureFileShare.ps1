$acctKey = ConvertTo-SecureString -String "HashValue" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList "storage", $acctKey
New-PSDrive -Name Z -PSProvider FileSystem -Root "storagepath" -Credential $credential -Persist