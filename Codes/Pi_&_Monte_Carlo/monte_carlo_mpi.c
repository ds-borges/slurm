#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/**
 * @brief Calcula Pi usando o método de Monte Carlo em paralelo com MPI.
 * CÓDIGO CORRIGIDO: A inicialização do MPI foi movida para antes da
 * validação dos argumentos para evitar o erro 'rank undeclared'.
 */
int main(int argc, char** argv) {

    // Declaração de todas as variáveis no início da função
    long long total_tiros;
    long long tiros_por_processo;
    long long acertos_locais = 0;
    long long acertos_globais = 0;
    int rank, num_procs;
    double start_time, end_time;

    // --- PASSO 1: Inicialização do Ambiente MPI ---
    // Isto DEVE acontecer antes de usar qualquer função ou variável do MPI.
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);    // Pega o ID (rank) do processo atual
    MPI_Comm_size(MPI_COMM_WORLD, &num_procs); // Pega o número total de processos

    // --- PASSO 2: Validação dos Argumentos de Entrada ---
    // Agora que 'rank' é conhecido, podemos fazer a validação corretamente.
    if (argc != 2) {
        // Apenas o processo mestre (rank 0) imprime a mensagem de erro.
        if (rank == 0) {
            fprintf(stderr, "Uso: %s <numero_total_de_tiros>\n", argv[0]);
        }
        MPI_Finalize(); // Encerra o ambiente MPI antes de sair
        return 1;
    }

    total_tiros = atoll(argv[1]); // Converte o argumento para long long

    // Garante que o número de tiros é divisível pelo número de processos
    if (total_tiros % num_procs != 0) {
        if (rank == 0) {
            fprintf(stderr, "ERRO: O número total de tiros (%lld) deve ser divisível pelo número de processos (%d).\n", total_tiros, num_procs);
        }
        MPI_Finalize();
        return 1;
    }
    
    tiros_por_processo = total_tiros / num_procs;

    // Semente do gerador aleatório. Crucial para que cada processo
    // gere uma sequência de números diferente.
    srand(time(NULL) + rank);

    // Sincroniza todos os processos e inicia o cronômetro
    MPI_Barrier(MPI_COMM_WORLD);
    start_time = MPI_Wtime();

    // --- PASSO 3: Laço de Cálculo Principal ---
    // Cada processo realiza sua cota de trabalho de forma independente.
    for (long long i = 0; i < tiros_por_processo; i++) {
        double x = (double)rand() / (double)RAND_MAX * 2.0 - 1.0;
        double y = (double)rand() / (double)RAND_MAX * 2.0 - 1.0;
        if (x * x + y * y <= 1.0) {
            acertos_locais++;
        }
    }

    // --- PASSO 4: Coleta (Redução) dos Resultados ---
    MPI_Reduce(&acertos_locais, &acertos_globais, 1, MPI_LONG_LONG, MPI_SUM, 0, MPI_COMM_WORLD);

    // Sincroniza novamente e para o cronômetro
    MPI_Barrier(MPI_COMM_WORLD);
    end_time = MPI_Wtime();

    // --- PASSO 5: Finalização e Impressão do Resultado ---
    if (rank == 0) {
        double pi_estimado = 4.0 * (double)acertos_globais / (double)total_tiros;
        double tempo_execucao = end_time - start_time;
        
        printf("====================================================\n");
        printf("Cálculo de Pi com MPI e Método de Monte Carlo\n");
        printf("----------------------------------------------------\n");
        printf("Número de processos MPI...: %d\n", num_procs);
        printf("Total de tiros............: %lld\n", total_tiros);
        printf("Total de acertos..........: %lld\n", acertos_globais);
        printf("Tempo de execução do cálculo: %f segundos\n", tempo_execucao);
        printf("Valor estimado de Pi......: %.15f\n", pi_estimado);
        printf("====================================================\n");
    }

    // Finaliza o ambiente MPI
    MPI_Finalize();
    
    return 0;
}
