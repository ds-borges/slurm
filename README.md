# Slurm Cluster Installation and Testing Repository

![Manager](https://img.shields.io/badge/Gerenciador-Slurm-blue.svg)
![Parallelism](https://img.shields.io/badge/Paralelismo-Open%20MPI-orange.svg)
![Language](https://img.shields.io/badge/Linguagem-C%20%7C%20Bash-yellow.svg)
![Platform](https://img.shields.io/badge/Plataforma-Linux-green.svg)

Welcome to this repository, whose main objective is to assist in the implementation of a Slurm cluster, from creation and configuration to functional validation. The content is organized to be a complete guide for building a high-performance computing (HPC) environment, divided into two main sections: **Installation** and **Tests**.

## 📁 Repository Structure

The content is organized into two main folders for ease of use:

### 1. `/Instalation`
This folder contains everything you need to build a functional Slurm cluster from scratch. Inside, you will find three different approaches, each with its own detailed documentation:

* **`/Slurm Files`**: Contains the finalized configuration files (`slurm.conf`, `cgroup.conf`, `slurmdbd.conf`, etc.).  They serve as templates that must be customized for your environment before installation. Refer to the technical `README.md` inside this folder for a customization guide.
* **`/Commands`**: Offers a guide for the manual installation of the cluster. It is the ideal approach for those who want to learn each step of the process and have full control.
* **`/Script`**: Provides scripts for a semi-automatic installation. This approach is faster and reduces the chance of errors, but still requires administrator intervention at key points.

### 2. `/Tests`
After the successful installation of the cluster, this folder offers the resources to validate its functionality.

* **Objective**: To verify that the cluster is operational, that jobs are submitted correctly, and that the parallel computing environment (MPI) is working as expected.
* **Content**: Includes a C code example with MPI to calculate the value of Pi using the Monte Carlo method. This is a classic HPC test that uses multiple nodes to perform an intensive calculation.
* **Instructions**: Inside this folder, you will find a `README.md` with detailed instructions on how to compile and run the validation test on your new cluster.

## 🚀 How to Use This Repository

Follow this workflow for the best results:

1.  **Start with the Installation**: Navigate to the `/Installation` folder to begin building your cluster.
2.  **Choose Your Method**: Decide between the manual (`/Commands`) or semi-automatic (`/Script`) approach and follow the instructions in the corresponding `README.md`.
3.  **Validate the Cluster**: Once the cluster is online and the Slurm services are running, go to the `/Tests` folder.
4.  **Run the Tes**: Follow the instructions to run the Pi calculation program. A successful result confirms that your cluster is ready to process high-performance jobs.
