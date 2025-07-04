#!/bin/bash

#SBATCH --job-name=CalculatePi_MPI_flexible   		# Job name
#SBATCH --output=/nfs/return/out/pi_mpi_out_%j.txt      # Output file
#SBATCH --error=/nfs/return/err/pi_mpi_err_%j.txt       # Error log

# --- NODE DIRECTIVES (FLEXIBLE) ---
# The number of nodes will be defined on the command line (e.g., sbatch --nodes=4 ...)
#SBATCH --ntasks-per-node=1         # Launches 1 process on each of the allocated nodes
# -----------------------------------------------------------------

#SBATCH --time=08:00:00             # Maximum execution time

# --- Script Input Validation ---
if [ "$#" -ne 1 ]; then
	echo "ERROR: You must provide the total number of 'shots' for the calculation."
	echo "Usage: sbatch [options] $0 <number_of_shots>"
	echo "Example: sbatch --nodes=4 $0 10000000000"
    exit 1
fi
TOTAL_THROWS=$1

# --- TIME MEASUREMENT AND JOB INFORMATION ---
START_TIME_SECONDS=$(date +%s)
echo "========================================================="
echo "JOB START: $(date)"
echo "Job ID: $SLURM_JOB_ID"
echo "Nodes requested: $SLURM_NNODES | Total Tasks: $SLURM_NTASKS"
echo "Nodes used: $SLURM_NODELIST"
echo "Total Number of Shots for Monte Carlo: $TOTAL_THROWS"
echo "========================================================="
echo ""

# --- Define a secure working directory ---
WORK_DIR=/nfs/return/job/job_$SLURM_JOB_ID
mkdir -p $WORK_DIR

# --- Copy the source code to the working directory ---
# The C code must be in this path to be found.
SOURCE_FILE="/nfs/execution/monte_carlo_mpi.c" 
cp $SOURCE_FILE $WORK_DIR

# --- Change to the working directory ---
cd $WORK_DIR
echo "Running in working directory: $(pwd)"
echo ""

# --- COMPILATION STEP ---
echo "Compiling the C code with 'mpicc'..."
# Compiles the C file into a new executable
# Using -O3 for performance optimization
mpicc monte_carlo_mpi.c -o pi_exec_monte_carlo -O3 -lm

if [ $? -ne 0 ]; then
    echo "COMPILATION ERROR!"
    exit 1
fi
echo "Compilation complete."
echo ""

# --- EXECUTION STEP WITH MPIRUN ---
echo "Running the program with mpirun on $SLURM_NNODES node(s)..."
# Pass the number of shots as an argument to the executable
# mpirun will use the number of processes defined by Slurm ($SLURM_NTASKS)
mpirun -np $SLURM_NTASKS ./pi_exec_monte_carlo $TOTAL_THROWS
echo ""

# --- FINAL TIME MEASUREMENT ---
END_TIME_SECONDS=$(date +%s)
DURATION=$((END_TIME_SECONDS - START_TIME_SECONDS))

echo "========================================================="
echo "JOB END: $(date)"
echo "Total script execution time: ${DURATION} seconds."
echo "========================================================="