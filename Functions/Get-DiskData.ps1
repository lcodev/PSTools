function Get-DiskData {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]
        $ComputerName,

        # Parameter help description
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential
    )
    
    begin {
    }
    
    process {
        foreach ($Computer in $ComputerName) {
            $data = Get-WmiObject -Class Win32_DiskDrive -ComputerName $Computer -Credential $Credential |
                Select-Object -Property Model, Signature, @{
                    name = 'Size';expression={[math]::Round($_.Size / 1GB, 2)}
                }

            foreach ($item in $data) {
                $props = @{
                    ComputerName    = $Computer 
                    Model           = $item.Model
                    Serial          = $item.Signature
                    SizeGB          = $item.Size
                }

                # Custom output object
                $obj = New-Object -TypeName psobject -Property $props
                Write-Output -InputObject $obj
            }
        }
    }
    
    end {
    }
}

Get-DiskData -ComputerName lco-sql1 -Credential $admin