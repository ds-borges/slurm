#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

// Função Fibonacci ITERATIVA - rápida e eficiente.
long long fibonacci(int n) {
    if (n <= 1) {
        return n;
    }
    long long a = 0, b = 1, c;
    for (int i = 2; i <= n; i++) {
        c = a + b;
        a = b;
        b = c;
    }
    return b;
}

int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);

    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (argc != 2) {
        if (rank == 0) {
            fprintf(stderr, "ERRO: Forneça o número para o cálculo de Fibonacci.\n");
            fprintf(stderr, "Uso: mpirun -np <num_procs> ./executavel <numero_fibonacci>\n");
        }
        MPI_Finalize();
        return 1;
    }

    int fib_limit = atoi(argv[1]);

    // --- LÓGICA DO MESTRE (Rank 0) ---
    if (rank == 0) {
        long long final_result;
        const int STOP_SIGNAL = -1; // Sinal para trabalhadores pararem

        // Se houver trabalhadores disponíveis (size > 1)
        if (size > 1) {
            int worker_id = 1; // Vamos usar apenas o primeiro trabalhador (rank 1)
//            printf("[Mestre] Enviando a tarefa de calcular F(%d) para o Trabalhador %d.\n", fib_limit, worker_id);
            
            // Envia a tarefa única
            MPI_Send(&fib_limit, 1, MPI_INT, worker_id, 0, MPI_COMM_WORLD);

            // Recebe o resultado final de volta do trabalhador
            MPI_Recv(&final_result, 1, MPI_LONG_LONG, worker_id, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
  //          printf("[Mestre] Resultado recebido do Trabalhador %d.\n", worker_id);

            // Envia o sinal de parada para TODOS os trabalhadores, para que eles finalizem
            for (int i = 1; i < size; i++) {
                MPI_Send(&STOP_SIGNAL, 1, MPI_INT, i, 0, MPI_COMM_WORLD);
            }

        } else { // Se só houver 1 processo (sbatch --nodes=1), o mestre faz o trabalho
             printf("Executando em modo de processo único.\n");
             final_result = fibonacci(fib_limit);
        }

        // Imprime APENAS o resultado final solicitado
        printf("\n===================================\n");
        printf("  Resultado Final: F(%d) = %lld\n", fib_limit, final_result);
        printf("===================================\n\n");

    }
    // --- LÓGICA DO TRABALHADOR (Ranks > 0) ---
    else {
        while (1) {
            int n_to_calc;
            MPI_Recv(&n_to_calc, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

            // Se for o sinal de parada, sai do loop
            if (n_to_calc == -1) {
                //printf("[Trabalhador %d] Recebi sinal de parada. Finalizando.\n", rank);
	        break;
            }
            
            // Se for uma tarefa, calcula e envia de volta
          	//printf("[Trabalhador %d] Recebi tarefa F(%d). Calculando...\n", rank, n_to_calc);
            long long result = fibonacci(n_to_calc);
            
            // Envia o resultado numérico de volta para o mestre
            MPI_Send(&result, 1, MPI_LONG_LONG, 0, 0, MPI_COMM_WORLD);
        }
    }

    MPI_Finalize();
    return 0;
}
