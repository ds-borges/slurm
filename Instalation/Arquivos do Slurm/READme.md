# Technical Guide: Customizing a Slurm Environment

![Manager](https://img.shields.io/badge/Gerenciador-Slurm-blue.svg)
![Database](https://img.shields.io/badge/Banco_de_Dados-MySQL_/_MariaDB-orange.svg)
![Language](https://img.shields.io/badge/Scripts-Bash-yellow.svg)
![Technology](https://img.shields.io/badge/Tecnologia-cgroups-lightgrey.svg)
![Technology](https://img.shields.io/badge/Tecnologia-Wake--on--LAN-informational.svg)

This document is a technical reference for adapting Slurm's configuration files to a new hardware environment. The provided configuration is fully functional and includes advanced features such as power management (suspending/resuming idle nodes) and strict resource control with cgroups.

## 📄 Description of Configuration Files

* `slurm.conf`
    * This is the main configuration file for Slurm. It defines the cluster name, the controller (master) node, the hardware specifications for each compute node (CPUs, memory), the job partitions, and the parameters for the power-saving feature.

* `slurmdbd.conf`
    * Configures the Slurm Database Daemon (SlurmDBD). This file manages the connection to the database (MySQL/MariaDB), where the job history and cluster accounting are stored.

* `cgroup.conf`
    * Defines how Slurm will use the Linux kernel's Control Groups (cgroups). In this configuration, it is used to constrain the use of CPU cores and RAM, ensuring that jobs do not consume more resources than allocated

* `suspend.sh` e `resume.sh`
    * Custom scripts that manage the power cycle of the nodes. 
    * **`suspend.sh`**: Executed by Slurm to shut down an idle node via the `poweroff` command.
    * **`resume.sh`**: Executed to `wake up` a powered-off node by sending a Wake-on-LAN magic packet.

* `mac_addresses.list`
    * A helper file used by the `resume.sh` script. It maps the hostnames of the nodes to their respective MAC addresses, which are essential for Wake-on-LAN to function.

## ⚠️ Guide to Mandatory Changes

For this configuration to work in a new environment, the following changes are **critical**.

### 1. In the `slurm.conf` file:
* `SlurmctldHost`:  Change the hostname and IP to those of your new Master node. Example: `SlurmctldHost=MyNewMaster(192.168.1.100)`. 
* `AccountingStorageHost`: Change this to the hostname of your new Master node.
* `NodeName`: **This is the most critical change.** Remove the existing definitions and add a new line for EACH of your compute nodes, ensuring that `NodeAddr`, `CPUs` and `RealMemory` match the hardware of each one.
* `PartitionName`: After redefining the nodes, update the `Nodes=` list in each partition to include the names of your new nodes.

### 2. In the `slurmdbd.conf` file:
* `DbdHost` and `StorageHost`: Change these to the hostname of your new Master node.
* `StoragePass`:  Change the password `bccufj` to the password you defined for the slurm user in your MariaDB database.

### 3. In the `resume.sh` file:
* `MAC_LIST_FILE`: The script points to `/etc/slurm/mac_addresses.list`. Ensure this path is correct or move your file to this location.
* `WOL_INTERFACE`: Change the value `"enp2s0"` to the network interface name of your new Master node. You can find the correct name using the `ip a` command.

### 4. In the `mac_addresses.list` file:
* Delete all content and populate it with the list of your new nodes and their respective MAC addresses. Maintain the `NomeDoNo endereço:mac` format.

## 🛠️ System Prerequisites for Power Management

* **For  `suspend.sh` to work:**
    * The script executes the command `ssh slurm@${node} "sudo /sbin/poweroff"`.
    * This requires that passwordless SSH access for the `slurm` user (from the Master node to all compute nodes) be configured.
     * It also requires that the `slurm` user has permission to execute `sudo /sbin/poweroff` without needing a password on all compute nodes. This permission is configured via `/etc/sudoers` (using `sudo visudo`). 

* **For  `resume.sh` to work:**
    * The script uses the command `sudo /usr/sbin/etherwake`.
    * The `slurm` user on the Master node needs to have permission to execute this command via `sudo` without a password.
