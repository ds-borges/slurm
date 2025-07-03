#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// Função para fundir dois sub-arrays ordenados (parte do Merge Sort sequencial)
void merge(int *arr, int *temp, int left, int mid, int right) {
    int i = left, j = mid + 1, k = left;
    while (i <= mid && j <= right) {
        if (arr[i] <= arr[j]) {
            temp[k++] = arr[i++];
        } else {
            temp[k++] = arr[j++];
        }
    }
    while (i <= mid) temp[k++] = arr[i++];
    while (j <= right) temp[k++] = arr[j++];
    for (i = left; i <= right; i++) arr[i] = temp[i];
}

// Implementação do Merge Sort sequencial para ordenação local
void mergeSortSequential(int *arr, int *temp, int left, int right) {
    if (left < right) {
        int mid = left + (right - left) / 2;
        mergeSortSequential(arr, temp, left, mid);
        mergeSortSequential(arr, temp, mid + 1, right);
        merge(arr, temp, left, mid, right);
    }
}

// Função para fundir os múltiplos sub-arrays ordenados recebidos de cada processo
void mergeFinal(int *arr, int n, int num_procs, int elements_per_proc) {
    if (num_procs <= 1) return;

    int *temp_array = (int *)malloc(n * sizeof(int));
    if (temp_array == NULL) {
        fprintf(stderr, "Falha na alocação de memória para a fusão final.\n");
        return;
    }

    // Cria um array de ponteiros, cada um apontando para o início de um sub-array ordenado
    int **heads = (int **)malloc(num_procs * sizeof(int *));
    int *indices = (int *)calloc(num_procs, sizeof(int));

    for (int i = 0; i < num_procs; i++) {
        heads[i] = arr + i * elements_per_proc;
    }

    // Realiza a fusão dos k (num_procs) sub-arrays
    for (int i = 0; i < n; i++) {
        int min_val = -1;
        int min_proc_idx = -1;

        for (int j = 0; j < num_procs; j++) {
            if (indices[j] < elements_per_proc) {
                if (min_proc_idx == -1 || heads[j][indices[j]] < min_val) {
                    min_val = heads[j][indices[j]];
                    min_proc_idx = j;
                }
            }
        }
        temp_array[i] = min_val;
        indices[min_proc_idx]++;
    }

    // Copia o resultado ordenado de volta para o array original
    for (int i = 0; i < n; i++) {
        arr[i] = temp_array[i];
    }

    free(temp_array);
    free(heads);
    free(indices);
}


int main(int argc, char** argv) {

    long long total_elements;
    int rank, num_procs;
    double start_time, end_time;

    // --- PASSO 1: Inicialização do Ambiente MPI ---
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &num_procs);

    // --- PASSO 2: Validação dos Argumentos de Entrada ---
    if (argc != 2) {
        if (rank == 0) {
            fprintf(stderr, "Uso: %s <numero_total_de_elementos>\n", argv[0]);
        }
        MPI_Finalize();
        return 1;
    }

    total_elements = atoll(argv[1]);

    if (total_elements % num_procs != 0) {
        if (rank == 0) {
            fprintf(stderr, "ERRO: O número total de elementos (%lld) deve ser divisível pelo número de processos (%d).\n", total_elements, num_procs);
        }
        MPI_Finalize();
        return 1;
    }

    long long elements_per_proc = total_elements / num_procs;
    int *global_array = NULL;
    int *local_array = (int *)malloc(elements_per_proc * sizeof(int));

    // O processo mestre (rank 0) cria e inicializa o array global
    if (rank == 0) {
        global_array = (int *)malloc(total_elements * sizeof(int));
        srand(time(NULL));
        for (long long i = 0; i < total_elements; i++) {
            global_array[i] = rand() % 10000; // Números entre 0 e 9999
        }
    }

    // Sincroniza todos os processos e inicia o cronômetro
    MPI_Barrier(MPI_COMM_WORLD);
    start_time = MPI_Wtime();

    // --- PASSO 3: Distribuição dos dados ---
    MPI_Scatter(global_array, elements_per_proc, MPI_INT,
                local_array, elements_per_proc, MPI_INT,
                0, MPI_COMM_WORLD);

    // --- PASSO 4: Ordenação Local ---
    // Cada processo ordena sua porção de forma independente
    int *temp_local_array = (int *)malloc(elements_per_proc * sizeof(int));
    mergeSortSequential(local_array, temp_local_array, 0, elements_per_proc - 1);
    free(temp_local_array);

    // --- PASSO 5: Coleta dos Resultados ---
    MPI_Gather(local_array, elements_per_proc, MPI_INT,
               global_array, elements_per_proc, MPI_INT,
               0, MPI_COMM_WORLD);

    // --- PASSO 6: Fusão Final (apenas no processo mestre) ---
    if (rank == 0) {
        mergeFinal(global_array, total_elements, num_procs, elements_per_proc);
    }
    
    // Sincroniza novamente e para o cronômetro
    MPI_Barrier(MPI_COMM_WORLD);
    end_time = MPI_Wtime();

    // --- PASSO 7: Finalização e Impressão do Resultado ---
    if (rank == 0) {
        double tempo_execucao = end_time - start_time;
        
        printf("====================================================\n");
        printf("Ordenação com Parallel Merge Sort e MPI\n");
        printf("----------------------------------------------------\n");
        printf("Número de processos MPI...: %d\n", num_procs);
        printf("Total de elementos........: %lld\n", total_elements);
        printf("Tempo de execução.........: %f segundos\n", tempo_execucao);

        // Verificação de correção (opcional, mas recomendada)
        int sorted_correctly = 1;
        for (long long i = 0; i < total_elements - 1; i++) {
            if (global_array[i] > global_array[i + 1]) {
                sorted_correctly = 0;
                fprintf(stderr, "ERRO DE ORDENAÇÃO no índice %lld: %d > %d\n", i, global_array[i], global_array[i + 1]);
                break;
            }
        }

        if (sorted_correctly) {
            printf("Verificação de sucesso....: O array foi ordenado corretamente.\n");
        } else {
            printf("Verificação de falha......: O array NÃO foi ordenado corretamente.\n");
        }
        printf("====================================================\n");

        free(global_array);
    }

    free(local_array);
    MPI_Finalize();
    
    return 0;
}
