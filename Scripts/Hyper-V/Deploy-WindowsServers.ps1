$vmnum = Read-Host 'number of vms'
$Srv2019Path = 'E:\Software\Windows Server 2019\WIN2K19.ISO'   
$bootdevice = 'not yet defined'
$wds = Read-Host 'are you using wds? yes/no'

# Check for Windows Deployment Services
if ($wds -eq 'yes') {
    $bootdevice = 'Legacy'
}
else {
    $bootdevice = 'cd'   
}

for ($i = 0; $i -lt $vmnum; $i++) {
    # name vm
    $vm_name = Read-Host 'enter vm name'
    # Check for VM generation
    $gen = Read-Host 'enter VM generation: 1 or 2'

    # Create vm and set vm attributes
    New-VM -Name $vm_name -Generation $gen -ComputerName lcowd -NewVHDPath "D:\Hyper-V\Virtual Hard Disks\$vm_name.vhdx" -NewVHDSizeBytes 60GB -SwitchName VrtSwitch -BootDevice $bootdevice -MemoryStartupBytes 2GB
    
    if ($bootdevice -eq 'cd') {
        Get-VMDvdDrive -VMName $vm_name -ComputerName lcowd | Set-VMDvdDrive -Path $Srv2019Path
    }

    Set-VM -Name $vm_name -ComputerName lcowd -ProcessorCount 2 -DynamicMemory -MemoryStartupBytes 2GB -MemoryMinimumBytes 2GB -MemoryMaximumBytes 4GB
}