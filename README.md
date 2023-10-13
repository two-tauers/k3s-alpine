# k3s-alpine

Tools to set up k3s on a Raspberry Pi running Alpine Linux.

## Prerequisites

- Raspberry Pi 4
- SD card and means of attaching it to a computer
- Linux computer that will do the flashing of the cards

## Usage

## Settings

Download urls and target files are set in `settings.yaml`.

### K3s first server

Before installing any agents, you need to install and init a server.
It will use the k3s config in [config/server-init.yaml](config/server-init.yaml).

1. Prepare the SD card

    - Plug in the SD card and check its name with `lsblk`

        > NOTE: next steps will wipe the drive, so make sure you find the correct one

    - Format it and make two drives - one boot partition (FAT32) and one for k3s data (e.g. ext4)

        ```bash
        sudo parted <DRIVE NAME> rm 1  rm 2  mkpart primary FAT32 1M 1024M  mkpart primary FAT32 1024M 100%  set 1 boot on  print
        mkfs.fat <DRIVE NAME>1
        mkfs.ext4 <DRIVE NAME>2
        ```
        
        > Note that this is already done withing the `boot` make target, but please check the code before running it, as it might inadvertently delete data.

        (see [parted docs](https://www.gnu.org/software/parted/manual/parted.html))

2. Build and install the server

    - Prepare a config file, see: [config/server-init.yaml](config/server-init.yaml)

        > NOTE: you need to set `k3s.config.cluster-init: true` in the config for the first control plane, but only for the first one.

    - Mount the boot partition: `mkdir -p /mnt/sd && mount <DRIVE NAME>1 /mnt/sd`

    - Build and install: `make install path=/mnt/sd config=config/server-init.yaml`

    - Unmount the partition: `umount /mnt/sd`

3. Insert the SD card into the Raspberry Pi and power it up. After a minute, the init script should install k3s and start it up.

### Additional nodes

4. Once the server is up, ssh onto the Pi and get the agent token that will be used to add more nodes:

    ```bash
    sudo cat /var/lib/rancher/k3s/server/agent-token
    ```

    Set the IP and token into the `k3s-configs/agent.yaml` file.

5. Prepare another SD card following steps 1-3, except in step 2, where the make command needs the agent config file: `make install path=/mnt/sd config=config/agent.yaml`

    > NOTE: If you're adding another control plan, set `k3s.exec: server` in the config _without_ `k3s.config.cluster-init: true` and with IP and token of the existing server.

6. The agent should join the cluster after booting.

### Kubectl

Docs: https://docs.k3s.io/cluster-access

- From control plane:

    ```bash
    ssh user@control-plane-ip
    sudo k3s kubectl get nodes
    ```

- From outside the cluster:

    ```
    ssh user@control-plane-ip
    sudo cat /etc/rancher/k3s/k3s.yaml
    ```

    Copy the contents of the file to `$HOME/.kube/config`
