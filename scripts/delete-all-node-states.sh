#!/bin/bash

echo -n "This will ERASE ALL DATA ON. Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]

for i in $(seq 0 3);
do
    node_ip="192.168.1.10$i"

    if test $i -eq 0; then
        service_name="k3s"
    else
        service_name="k3s-agent"
    fi

    echo "Stopping $service_name on $node_ip"
    ssh tt@$node_ip sudo rc-service $service_name stop

    echo "Removing k3s persisted disk on $node_ip"
    ssh tt@$node_ip sudo rm -rf /mnt/k3s-persisted-state/*
done
