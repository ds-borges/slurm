 # Semi-Automatic Slurm Cluster Installation Guide

![Nivel](https://img.shields.io/badge/Automação-Semi--Automática-orange.svg)
![Language](https://img.shields.io/badge/Scripts-Bash-yellow.svg)
![Manager](https://img.shields.io/badge/Gerenciador-Slurm-blue.svg)
![Protocol](https://img.shields.io/badge/Protocolo-SSH-lightgrey.svg)

This guide details the use of scripts for a semi-automatic Slurm installation. The scripts are designed to automate the vast majority of commands but require an administrator's supervision and intervention at key points.

> Think of them as "semi-automatic." They do the heavy lifting but still need a pilot. 

## 🛠️ Points of Necessary Intervention

It is crucial to understand where your action will be needed to ensure the installation proceeds smoothly.

### 1. In-Execution Intervention: Passwords

* **SSH Password**: This is the main stopping point during execution. 
    * The `To_Configure_Base_Environment.sh` script uses the `ssh-copy-id` command to configure passwordless access between nodes. 
    * You will need to enter the password for each cluster node once when the script prompts you. This is an intentional security measure. 
* **`sudo` password**: Each script must be executed with superuser privileges (`sudo`). The system will likely ask for your administrator password at the beginning of the execution of each of the five scripts.. 

### 2. Preparation Intervention: Script Adaptation

Before executing anything, you must edit the scripts to match your environment. 

* **IP Addresses and Node Names**: In the `01-To_Configure_Base_Environment.sh` script, script, ensure that the list of IPs and names in the `/etc/hosts` file and in the `NODES` variable is correct for your cluster. 
* **`slurm.conf` file**: The `03-Instalar-slurm-mestre.sh` script  contains a minimal `slurm.conf` file for example purposes only. For a real cluster, you should generate a complete configuration (using Slurm's online generator, for example) and replace the example content inside the script with yours.
* **Database Password**: The password for the MariaDB `slurm` user is set to `'bccufj'` in script `03`.  If you change this password in the script, remember to also update the `StoragePass` field in the `slurmdbd.conf` file. 

### Potential Intervention: Error Resolution
* Automation does not handle troubleshooting. If a command fails for any reason (network issue, package conflict, etc.), the script will stop. This will require your manual intervention to fix the error and restart the process.

## 🚀 How to Run the Scripts

### Step 1: Grant Execution Permission
First, make all scripts executable with the `chmod +x` command.


```bash
chmod +x 01-To_Configure_Base_Environment.sh
chmod +x 02-To_Install_Munge.txt.sh
chmod +x 03-To_Install_Slurm_(Master_Node).sh
chmod +x 04-To_Install_Slurm_(Compute_Nodes).sh
chmod +x 05-To_Compile_OpenMPI.sh
```

### Step 2: Execute in the Correct Order
Run the scripts with `sudo` and in the correct numerical sequence, paying attention to which nodes each script should be executed on

```bash
# Run script 01 on ALL nodes
sudo 01-To_Configure_Base_Environment.sh

# Run script 02 on ALL nodes
sudo ./02-To_Install_Munge.txt.sh

# Run script 03 ONLY on the Master node
sudo ./03-To_Install_Slurm_(Master_Node).sh

# Run script 04 ONLY on the Compute nodes
sudo ./04-To_Install_Slurm_(Compute_Nodes).sh

# Run script 05 on ALL nodes
sudo ./05-To_Compile_OpenMPI.sh
```

## 🏁 Conclusion

Using these scripts eliminates the need to type hundreds of commands manually, which drastically reduces installation time and the chance of typos. However, they still require an administrator to prepare them, provide the initial passwords, and supervise the process.