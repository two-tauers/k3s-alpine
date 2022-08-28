# k3s-alpine

Tools to set up k3s on Alpine Linux

## install SD onto the SD cards

1. Insert the SD card and unmount any drives

    To see the list of mounts: `lsblk`

2. Partition the boot drive

    Get the device name by running `lsblk` and run `parted <DISK>`, e.g. `parted /dev/sdb`
    In parted:

    - `mkpart primary FAT32 1MB 100%` to create the full-drive partition
    - `set 1 boot on` to mark is as a boot drive
    - `quit` to exit parted

3. Format

    Run `sudo mkfs.fat <DISK PART>`, e.g. `sudo mkfs.fat /dev/sdb1`, to format the drive

4. Mount the drive

    Create the folder and mount the drive by running `sudo mkdir /mnt/sd && sudo mount /dev/sdb1 /mnt/sd`

    