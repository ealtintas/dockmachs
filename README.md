# docker-machine-scripts

## Purpose

Create and manage many multiple docker-machine vms easily

## Description

This repository contains small scripts which can help you create your docker swarm cluster using docker-machine, boot2docker, virtualbox-headless (VBoxManage) etc.

I used this scripts to fill the gaps that I saw in docker-machine just for myself. It helped me provision and managing many docker-machine vms on a single host. 

## How To

Update dm-settings.sh according to your network/ip configuration. 

### Usage

```
dm-all.sh - helps you manages all docker-machines at once

Syntax: dm-all.sh [ <command> ] [ <options> ]

You can use docker-machine like command for all the machines easily:

        status
        stop
        start
        rm
        ip
        pubip
        restart
        ssh
```

**Important:** docker-machine it-self is not supported currently.

Hope this script helps you :)

Plesase feel free to customize or improve it and if you wish send me a merge reuqest.
