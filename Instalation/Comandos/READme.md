# Manual Installation Guide for a Slurm Cluster

![Manager](https://img.shields.io/badge/Gerenciador-Slurm-blue.svg)
![Authentication](https://img.shields.io/badge/Autenticação-Munge-purple.svg)
![Parallelism](https://img.shields.io/badge/Paralelismo-Open%20MPI-orange.svg)
![Network](https://img.shields.io/badge/Rede-NFS-lightgrey.svg)
![Language](https://img.shields.io/badge/Comandos-Bash-yellow.svg)

This repository contains a set of text files with lists of commands for the manual, step-by-step installation of a Slurm cluster. The goal is to serve as a complete reference guide, allowing an administrator to understand the function of each command and adapt the installation to a new environment.

## ⚙️ Installation Workflow

The installation follows a logical and progressive order. It is crucial to follow the numerical sequence of the files to ensure that the dependencies of each step are met.

1.  **Base Environment Configuration**: Preparation of the network, time, and file infrastructure.
 
2.  **Authentication Installation**: Installation and configuration of Munge for secure communication. 
3.  **Slurm Installation**: Configuration of the Master Node and then the Compute Nodes. 
4.  **MPI Support Installation**: Compilation of Open MPI to allow the execution of parallel jobs.

## 📄 Guide to the Command Files

Here is a description of each file and where its commands should be executed.

### `1-Commands_Configure_Base_Environment.txt`
* **Objective**: To configure the essential prerequisites for the cluster's operation.
* **Where to Execute**: On ALL nodes (Master and Compute). The file has sections that apply only to the master or the compute nodes, as indicated.

### `2-Commands_to_Install_Munge.txt`
* **Objective**: To install and configure the Munge authentication service.
* **Where to Execute**: On **ALL** nodes. 

### `3-Commands_to_Install_Slurm_(Master_Node).txt`
* **Objective**: To install the central components ("brain") of the Slurm cluster. 
* **Where to Execute**: Only on the **MASTER NODE**.

### `4-Commands_to_Install_Slurm_(Compute_Nodes).txt`
* **Objective**: To install the Slurm "worker" service (`slurmd`).
* **Where to Execute**: Only on the **COMPUTE NODES**.

### `5-Commands_to_Compile_OpenMPI.txt`
* **Objective**: To prepare the environment for executing high-performance parallel jobs.
* **Where to Execute**: On **ALL** nodes.

## ⚠️ Mandatory Change Points

Before executing the commands, review and change the following values to match your environment.

### Step 1: `1-Commands_Configure_Base_Environment.txt` 
* **Network Mapping**: Change the list of IPs and Node Names in the configuration section of the `/etc/hosts` file. 
* **NFS Configuring**:
    * Change the network range (ex: `192.168.1.0/24`) in the configuration command for `/etc/exports`. 
    * Change the Master node's IP in the `sudo mount ...` command. 
* **SSH Configuration**: Change the list of `ssh-copy-id` commands to include the correct usernames and node names for your cluster. 

### Step 2: `2-Commands_to_Install_Munge.txt`
* **(Optional) User IDs**: The IDs for the `munge` and `slurm` users are fixed as `1001` and `1002`. It may be necessary to change these values if they are already in use on your system.

### Step 3: `3-Commands_to_Install_Slurm_(Master_Node).txt` 
This step involves editing several configuration files.

* **In the `slurmdbd.conf` file:** 
    * **Database Password**: The password for the 'slurm' user for MariaDB is set to  `'bccufj07'`. It is crucial to change it in both the  `GRANT ALL...` SQL command and in the `StoragePass=...` parameter within this file.
    * **Database Host**: Verify that `DbdHost` and `StorageHost` match the name of your new Master node. 
* **In the `slurm.conf` file:**
    * `SlurmctldHost`: Must contain the correct name of your Master node. 
    * `NodeName`: The `NodeName=...` lines must be rewritten to list the correct names and CPU/memory configurations for each of your nodes.
    * `PartitionName`: The `PartitionName=...` lines must be adjusted to reflect which nodes belong to each partition.

* **In the `resume.sh` script:**
    * `WOL_INTERFACE`: The value is fixed as `"enp2s0"`. You MUST find the correct network interface name of your new Master node (using `ip a`) and update this variable. 
* **In the `mac_addresses.list` file:**
    * This file must be completely rewritten with the names and corresponding MAC addresses of your new compute nodes.

* **System Prerequisites for Power Management:**
    * For the `suspend.sh` and `resume.sh` scripts to work, the `slurm` userneeds `sudo` permissions without a password. Use `sudo visudo` to ensure that:
        1.  On the **Nó Mestre**, `slurm` can execute `/usr/sbin/etherwake`. 
        2.  On the **ALL Compute Nodes,**, `slurm` can execute `/sbin/poweroff`. 

### Step 5: `5-Commands_to_Compile_OpenMPI.txt` 
* **Open MPI Version:**: The version used in this work is `4.1.5` and is fixed in the `wget`, `cd` and `configure`. If you need another version, you must change the number in each of these commands.
