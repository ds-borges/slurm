# Calculating Pi with MPI and Slurm

![Language](https://img.shields.io/badge/Linguagem-C-blue.svg)
![Parallelis](https://img.shields.io/badge/Framework-MPI-orange.svg)
![Cluster](https://img.shields.io/badge/Gerenciador-Slurm-red.svg)

This project provides an implementation in C and MPI to calculate the value of Pi (π) using the Monte Carlo statistical method. The system is designed to be executed efficiently on high-performance computing (HPC) clusters managed by the Slurm Workload Manager.

## 🎯 Key Concepts

### Monte Carlo Method for Pi
The idea is to simulate randomly throwing "darts" at a square with a side length of 2, which has a circle of radius 1 inscribed within it. The area of the square is $2^2 = 4$,  and the area of the circle is $\pi \cdot 1^2 = \pi$.

The ratio between the area of the circle and the area of the square is $\frac{\pi}{4}$. Therefore, if we throw a very large number of darts, the proportion of darts that land inside the circle relative to the total number of darts thrown will be an approximation of $\frac{\pi}{4}$.

$$\pi \approx 4 \cdot \frac{\text{hits inside the circle}}{\text{total darts thrown}}$$

### Parallelism with MPI (Message Passing Interface)
To make the calculation feasible with billions of "darts," the work is divided among multiple processes. MPI is a communication standard that allows these processes, running on different nodes of a cluster, to exchange data. In this project, the work is divided, each process calculates a part, and the results are summed at the end (`MPI_Reduce`).

## 📂 File Descriptions

### 📄 `monte_carlo_mpi.c`
The core of the calculation logic, written in C.

* **MPI Initialization**: Sets up the environment for communication between processes.
* **Load Division**: The total number of "shots" is divided equally among all allocated processes (`total_shots / num_procs`).
* **Independent Calculation**: Each process runs its own Monte Carlo simulation
* **SDistinct Random Seeds**: Ensures the statistical independence of the results by using the process `rank`  to generate a unique seed for the `srand()`.
* **Result Aggregation**: Uses `MPI_Reduce` to sum the hits from all processes and consolidate the result on the master process (rank 0).
* **Formatted Output**: Only the master process prints the final result, avoiding duplicate outputs.

### 📜 `pi_mpi_flexivel.sh`
A submission script for Slurm that automates the execution on the cluster.

* **Slurm Directives**: The `#SBATCH` lines configure the job, defining the name, log files, execution time, and most importantly, the number of tasks per node (`--ntasks-per-node=1`).
* **Flexibility**: Allows the user to define the number of nodes on the command line (`sbatch --nodes=...`).
* **Workflow Automation:**:
    1.  Creates a secure and isolated working directory for each job.
    2.  Copies the source code to the working directory.
    3.  Compiles the C code using `mpicc` with the `-O3` optimization flag..
    4.  Executes the compiled program with `mpirun`, qwhich integrates seamlessly with Slurm to distribute the processes across the allocated nodes.
    5.  Measures and reports the total execution time.

## 🚀 How to Use (on a Slurm Cluster)

### 1.  Prerequisites
The `pi_mpi_flexivel.sh` script expects to find the C source code in a specific location. Ensure the file is in the correct path or adjust the script:
```bash
# Path defined in the pi_mpi_flexivel.sh script
SOURCE_FILE="/nfs/execution/monte_carlo_mpi.c"
```

### 2. Job Submission
Use the `sbatch` command to send the script to the Slurm queue. You must specify:
-   `--nodes`: The number of compute nodes you want to use.
-   `<total_number_of_shots>`: The argument for the script, which represents the total workload.

**Syntax:**
```bash
sbatch --nodes=<number_of_nodes> pi_mpi_flexivel.sh <total_number_of_shots>
```

**Practical Example:**
To run the calculation on 16 nodes with 100 billion shots:
```bash
sbatch --nodes=16 pi_mpi_flexivel.sh 100000000000
```
**Attention**: The total number of shots must be divisible by the number of nodes.

### 3. Analyzing the Results
The output and error logs will be generated in the `/nfs/return/out/` and `/nfs/return/err/` directories, respectively, with the Job ID in the filename.

## 💡 Workload Recommendation

For results with higher precision and to truly test the cluster's capacity, it is recommended to use a very high number of "shots" (attempts).

> **It is recommended to start tests with values above 9 billion shots for really tests.**

The higher the number of shots, the closer the result will be to the actual value of π, and the more evident the benefit of parallel computing in reducing execution time will be.

## 💻 How to Run Locally (Without Slurm)

If you have an MPI implementation (like Open MPI or MPICH) installed on your local machine, you can compile and run the program directly.

### 1. Compilation
Use `mpicc`, which is a wrapper for your C compiler (like GCC), to compile the program.
```bash
mpicc monte_carlo_mpi.c -o pi_exec_monte_carlo -O3 -lm
```

### 2. Execution
Use `mpirun` or `mpiexec` to run the compiled program.
-   Use the `-np` flag to specify the number of processes you want to simulate.

**Syntax:**
```bash
mpirun -np <number_of_processes> ./pi_exec_monte_carlo <total_number_of_shots>
```

**Practical Example:**
To run with **4 processes** and **1 billion shots**:
```bash
mpirun -np 4 ./pi_exec_monte_carlo 1000000000
```

## 📊 Output Example
The program's output, which will be found in the Slurm log file, will have the following format:
```
====================================================
Calculation of Pi with MPI and Monte Carlo Method
----------------------------------------------------
Number of MPI processes...: 16
Total shots............: 100000000000
Total hits..........: 78539815000
Calculation execution time: 152.731982 segundos
Estimated value of Pi......: 3.141592600000000
====================================================
```
