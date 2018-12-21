# ISO file path variables
$win2k16_iso = "\\lcowd\D$\Software\Windows Server 2016\Win2k16.ISO"

# TO-DO
#$win2k12_iso = "E:\Software\Windows Server 2012\Win2k12.ISO"
#$win10_iso = "E:\Software\Windows 10\Windows10.iso"

# prompt for number of vm's
[int]$vm_num = Read-Host 'enter number of vms'

for ($i = 0; $i -lt $vm_num; $i++) {
    # prompt for new vm name
    $vm_name = Read-Host "enter vm name"

    # prompt for iso or wds installation
    $wds = Read-Host "wds install? yes/no"

    if ($wds -eq 'yes') {
        Write-Verbose "Windows Deployment Services Installation"

        # Create vm and set vm attributes
        New-VM -Name $vm_name -ComputerName lcowd -NewVHDPath F:\$vm_name.vhdx -NewVHDSizeBytes 50GB -SwitchName hvswitch -BootDevice LegacyNetworkAdapter -MemoryStartupBytes 2GB
        Set-VM -Name $vm_name -ComputerName lcowd -ProcessorCount 2 -DynamicMemory -MemoryStartupBytes 2GB -MemoryMinimumBytes 1GB -MemoryMaximumBytes 4GB

        # Prompt for vm start
        $start = Read-Host "Start vm? yes/no" 
        if ($start -ceq 'yes') {
            Start-VM $vm_name -ComputerName lcowd
        } else {
            Write-Output "$vm_name created NOT started"
        }

    } else {
        Write-Verbose -Message "ISO manual installation"

        # Create vm and set vm attributes
        New-VM -Name $vm_name -ComputerName lcowd -NewVHDPath "E:\HyperV\Virtual Hard Disks\$vm_name.vhdx" -NewVHDSizeBytes 50GB -SwitchName hvswitch -BootDevice CD -MemoryStartupBytes 2GB
        Get-VMDvdDrive -VMName $vm_name -ComputerName lcowd | Set-VMDvdDrive -Path $win2k16_iso
        Set-VM -Name $vm_name -ComputerName lcowd -ProcessorCount 2 -DynamicMemory -MemoryStartupBytes 2GB -MemoryMinimumBytes 2GB -MemoryMaximumBytes 4GB

        # Prompt for vm start
        $start = Read-Host "Start vm? yes/no" 
        if ($start -ceq 'yes') {
            Start-VM $vm_name -ComputerName lcowd
            vmconnect lcowd $vm_name
        }
        else {
            Write-Output "$vm_name created successfully"
        }

    } # end else-if statement

} # end for-loop