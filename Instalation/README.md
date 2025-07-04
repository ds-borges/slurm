# Slurm Cluster Installation Guide

![Platform](https://img.shields.io/badge/Plataforma-Linux-green.svg)
![Manager](https://img.shields.io/badge/Gerenciador-Slurm-blue.svg)
![Language](https://img.shields.io/badge/Scripts-Bash-orange.svg)

Welcome to this project for installing and configuring a cluster with the Slurm Workload Manager. This repository is organized to offer flexibility, allowing you to choose the installation method that best suits your needs.

## 📁 Repository Structure

The project is divided into three main subfolders, each with a specific purpose.

### 1. `Slurm Files/`
This folder contains the finalized configuration files, ready to be adapted.

* **Content**: Includes essential files like`slurm.conf`, `slurmdbd.conf`, `cgroup.conf` and power management scripts (`resume.sh`, `suspend.sh`).
* **Usage**:  It serves as a set of universal "templates" for the final cluster configuration. These files should be used regardless of the chosen installation method (manual or scripted).
* **Adaptation**: Contains a `READme.md` that serves as a detailed guide for customizing the files (adjusting IPs, node names, passwords, etc.) for your specific environment.

### 2. `Commands/`
This folder offers a detailed, manual installation approach.

* **Content**: Five `.txt` files, each containing a list of commands for a specific installation step (e.g., Base Environment, Munge, Slurm Master).
* **Usage**: Ideal for those who want to perform a `manual and controlled` installation, executing and validating each command step-by-step. It is an excellent approach for learning purposes or for debugging issues in specific stages of the process.
* **Guide**: Includes a `READme.md` that explains the purpose of each of the five command files.

### 3. `Script/`
This folder offers a faster, more automated installation approach.

* **Content**: Five executable scripts (`.sh`) that automate the execution of commands for each installation step.
* **Usage**: Ideal for those seeking a **semi-automatic** and more agile installation. The scripts still require manual intervention at specific points, such as entering passwords.
* **Guide**: Includes a `README.md` that details how to grant execution permissions to the scripts and points out the moments that require user intervention.

## 🤔  Which Method to Choose??

* **Option 1: Manual Installation (`Commands/`)**
    * **Advantage**: Full control over the process, ideal for understanding every detail of the installation and for granular troubleshooting.

* **Option 2: Semi-Automatic Installation (`Script/`)**
    * **Advantage**: Greater speed and convenience, automating repetitive tasks.

## 🚀 Getting Started

1.  **Configure the Base Files**: First of all, go to the `Arquivos do Slurm/` folder. Read the `READme.md` and edit the configuration files (`.conf`) to match your cluster's hardware and network.
2.  **Choose Your Method**: Decide whether you prefer the manual (`Commands/`) or semi-automatic (`Script/`) installation.
3.  **Follow the Instructions**:  Navigate to the chosen folder and follow the instructions in the local `README.md` to begin the installation.