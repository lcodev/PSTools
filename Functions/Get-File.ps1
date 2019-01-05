function Get-File($initialDirectory) {
    
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.InitialDirectory = $initialDirectory
    $OpenFileDialog.Filter = "All files (*.*) | *.*"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.FileName
    
}

Get-File -initialDirectory "C:\Users\admin"