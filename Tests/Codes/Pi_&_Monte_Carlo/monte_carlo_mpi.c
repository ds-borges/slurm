#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/**
 * @brief Calculates Pi using the Monte Carlo method in parallel with MPI.
 * FIXED CODE: MPI initialization was moved before argument
 * validation to avoid the 'rank undeclared' error.
 */
int main(int argc, char** argv) {

    // Declaration of all variables at the beginning of the function
    long long total_shots;
    long long shots_per_process;
    long long local_hits = 0;
    long long global_hits = 0;
    int rank, num_procs;
    double start_time, end_time;

    // --- STEP 1: Initialize the MPI Environment ---
    // This MUST happen before using any MPI function or variable.
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);     // Get the ID (rank) of the current process
    MPI_Comm_size(MPI_COMM_WORLD, &num_procs); // Get the total number of processes

    // --- STEP 2: Validate Input Arguments ---
    // Now that 'rank' is known, we can perform the validation correctly.
    if (argc != 2) {
        // Only the master process (rank 0) prints the error message.
        if (rank == 0) {
            fprintf(stderr, "Usage: %s <total_number_of_shots>\n", argv[0]);
        }
        MPI_Finalize(); // Finalize the MPI environment before exiting
        return 1;
    }

    total_shots = atoll(argv[1]); // Convert the argument to long long

    // Ensure the number of shots is divisible by the number of processes
    if (total_shots % num_procs != 0) {
        if (rank == 0) {
            fprintf(stderr, "ERROR: The total number of shots (%lld) must be divisible by the number of processes (%d).\n", total_shots, num_procs);
        }
        MPI_Finalize();
        return 1;
    }
    
    shots_per_process = total_shots / num_procs;

    // Seed for the random number generator. Crucial for each process
    // to generate a different sequence of numbers.
    srand(time(NULL) + rank);

    // Synchronize all processes and start the timer
    MPI_Barrier(MPI_COMM_WORLD);
    start_time = MPI_Wtime();

    // --- STEP 3: Main Calculation Loop ---
    // Each process performs its share of the work independently.
    for (long long i = 0; i < shots_per_process; i++) {
        double x = (double)rand() / (double)RAND_MAX * 2.0 - 1.0;
        double y = (double)rand() / (double)RAND_MAX * 2.0 - 1.0;
        if (x * x + y * y <= 1.0) {
            local_hits++;
        }
    }

    // --- STEP 4: Collect (Reduce) the Results ---
    MPI_Reduce(&local_hits, &global_hits, 1, MPI_LONG_LONG, MPI_SUM, 0, MPI_COMM_WORLD);

    // Synchronize again and stop the timer
    MPI_Barrier(MPI_COMM_WORLD);
    end_time = MPI_Wtime();

    // --- STEP 5: Finalize and Print the Result ---
    if (rank == 0) {
        double estimated_pi = 4.0 * (double)global_hits / (double)total_shots;
        double execution_time = end_time - start_time;
        
        printf("====================================================\n");
        printf("Calculation of Pi with MPI and Monte Carlo Method\n");
        printf("----------------------------------------------------\n");
        printf("Number of MPI processes...: %d\n", num_procs);
        printf("Total shots...............: %lld\n", total_shots);
        printf("Total hits................: %lld\n", global_hits);
        printf("Calculation execution time: %f seconds\n", execution_time);
        printf("Estimated value of Pi.....: %.15f\n", estimated_pi);
        printf("====================================================\n");
    }

    // Finalize the MPI environment
    MPI_Finalize();
    
    return 0;
}