$vmnum = Read-Host 'number of vms'
$Centos7 = "E:\Software\Linux\Centos\centos.iso"

for ($i = 0; $i -lt $vmnum; $i++) {
    # name vm
    $vm_name = Read-Host 'enter vm name'

    # Create vm and set vm attributes
    New-VM -Name $vm_name -ComputerName lcowd -NewVHDPath "D:\Hyper-V\Virtual Hard Disks\$vm_name.vhdx" -NewVHDSizeBytes 60GB -SwitchName VrtSwitch -BootDevice CD -MemoryStartupBytes 2GB
    Get-VMDvdDrive -VMName $vm_name -ComputerName lcowd | Set-VMDvdDrive -Path $Centos7
    Set-VM -Name $vm_name -ComputerName lcowd -ProcessorCount 2 -DynamicMemory -MemoryStartupBytes 2GB -MemoryMinimumBytes 2GB -MemoryMaximumBytes 4GB
}