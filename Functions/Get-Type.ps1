function Get-Type {
    param (
        [string]$Pattern = '.'
    )
    [System.AppDomain]::CurrentDomain.GetAssemblies() | Sort-Object -Property FullName |
    ForEach-Object {
        $asm = $PSItem
        Write-Verbose $asm.FullName

        switch ($asm.FullName) {
            { $_ -like 'Anonymously Hosted DynamicMethods Assembly*' } {break}
            { $_ -like 'Microsoft.PowerShell.Cmdletization.GeneratedTypes*' } {break}
            { $_ -like 'Microsoft.Management.Infrastructure.UserFilteredExceptionHandling*' } {break}
            { $_ -like 'Microsoft.GeneratedCode*' } {break}
            { $_ -like 'MetadataViewProxies*' } {break}
            Default {
                $asm.GetExportedTypes() |
                Where-Object {$_ -match $Pattern} |
                Select-Object @{N='Assembly'; E={($_.Assembly -split ',')[0]}},
                IsPublic, IsSerial, FullName, BaseType
            }
        }
    }
}