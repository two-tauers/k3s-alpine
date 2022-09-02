# k3s-alpine

Tools to set up k3s on Alpine Linux

## Install headless Alpine Linux onto an SD card

Below are the instructions for installing alpine linux in a [headless mode](https://github.com/macmpi/alpine-linux-headless-bootstrap) onto an SD card.
Do this for all the nodes of the cluster.

### Prepare the SD card

1. Insert the SD card and unmount any drives

    To see the list of mounts: `lsblk`.
    If the device already contains a partition and it's mounted, unmount it before proceeding (`sudo umount <mountpoint>`)

2. Partition the boot drive

    Get the device name by running `lsblk` and run `sudo parted <DEVICE>`, e.g. `sudo parted /dev/sdb`
    In parted:

    - `mkpart primary FAT32 2048 100%` to create the full-drive partition
    - `set 1 boot on` to mark is as a boot drive
    - `quit` to exit parted

3. Format the drive

    Run `sudo mkfs.fat <PARTITION>`, e.g. `sudo mkfs.fat /dev/sdb1`, to format the drive

### Copy the OS files

1. Mount the drive

    Create the folder and mount the drive by running `sudo mkdir -p /mnt/sd && sudo mount /dev/sdb1 /mnt/sd`

2. Run `sudo make install path=/mnt/sd` to copy the files

    This make target downloads the alpine image and headless bootstrap files and copies it to the sd card. The URLs for the downloads are defined at the top of the `Makefile`.

3. Insert the card into the Raspberry Pi and boot it up. After it boots, you should be able to ssh onto is as `root` user (no password by default).
    