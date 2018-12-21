$vmnum = Read-Host 'number of vms'
$ubuntu = "D:\Software\Linux\Ubuntu\ubuntu-18.04.1-desktop-amd64.iso"

for ($i = 0; $i -lt $vmnum; $i++) {
    # name vm
    $vm_name = Read-Host 'enter vm name'

    # Create vm and set vm attributes
    New-VM -Name $vm_name -ComputerName lcowd -NewVHDPath "E:\HyperV\Virtual Hard Disks\$vm_name.vhdx" -NewVHDSizeBytes 50GB -SwitchName VrtSwitch -BootDevice CD -MemoryStartupBytes 2GB
    Get-VMDvdDrive -VMName $vm_name -ComputerName lcowd | Set-VMDvdDrive -Path $ubuntu
    Set-VM -Name $vm_name -ComputerName lcowd -ProcessorCount 2 -DynamicMemory -MemoryStartupBytes 2GB -MemoryMinimumBytes 2GB -MemoryMaximumBytes 4GB
}