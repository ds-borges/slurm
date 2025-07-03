#!/bin/bash

#SBATCH --job-name=MergeSort_MPI_flexivel    # Nome do job
#SBATCH --output=/nfs/return/out/sort_mpi_out_%j.txt      # Arquivo de saída
#SBATCH --error=/nfs/return/err/sort_mpi_err_%j.txt       # Arquivo para erros

# --- DIRETIVAS DE NÓS (FLEXÍVEL) ---
# O número de nós será definido na linha de comando (ex: sbatch --nodes=3 ...)
#SBATCH --ntasks-per-node=1          # Inicia 1 processo em cada um dos nós alocados
# -----------------------------------------------------------------

#SBATCH --time=08:00:00              # Tempo máximo de execução

# --- Validação da Entrada do Script ---
if [ "$#" -ne 1 ]; then
    echo "ERRO: É preciso fornecer o número total de 'elementos' para ordenar."
    echo "Uso: sbatch [opções] $0 <numero_de_elementos>"
    echo "Exemplo: sbatch --nodes=3 $0 30000000"
    exit 1
fi
TOTAL_ELEMENTS=$1

# --- MEDIÇÃO DE TEMPO E INFORMAÇÕES DO JOB ---
START_TIME_SECONDS=$(date +%s)
echo "========================================================="
echo "INÍCIO DO JOB: $(date)"
echo "ID do Job: $SLURM_JOB_ID"
echo "Nós solicitados: $SLURM_NNODES | Processos Totais: $SLURM_NTASKS"
echo "Nós utilizados: $SLURM_NODELIST"
echo "Número Total de Elementos para Ordenar: $TOTAL_ELEMENTS"
echo "========================================================="
echo ""

# --- Define um diretório de trabalho seguro ---
WORK_DIR=/nfs/return/job/job_$SLURM_JOB_ID
mkdir -p $WORK_DIR

# --- Copia o código-fonte para o diretório de trabalho ---
# O código C deve estar neste caminho para ser encontrado
SOURCE_FILE="/nfs/execution/parallel_merge_sort.c" 
cp $SOURCE_FILE $WORK_DIR

# --- Muda para o diretório de trabalho ---
cd $WORK_DIR
echo "Executando no diretório de trabalho: $(pwd)"
echo ""

# --- PASSO DE COMPILAÇÃO ---
echo "Compilando o código C com 'mpicc'..."
# Compila o arquivo C para um novo executável
# Usando -O3 para otimização de performance
mpicc parallel_merge_sort.c -o sort_exec -O3 -lm

if [ $? -ne 0 ]; then
    echo "ERRO NA COMPILAÇÃO!"
    exit 1
fi
echo "Compilação concluída."
echo ""

# --- PASSO DE EXECUÇÃO COM MPIRUN ---
echo "Executando o programa com mpirun em $SLURM_NNODES nó(s)..."
# Passa o número de elementos como argumento para o executável
# mpirun usará o número de processos definido pelo Slurm ($SLURM_NTASKS)
mpirun -np $SLURM_NTASKS ./sort_exec $TOTAL_ELEMENTS
echo ""

# --- MEDIÇÃO DE TEMPO FINAL ---
END_TIME_SECONDS=$(date +%s)
DURATION=$((END_TIME_SECONDS - START_TIME_SECONDS))

echo "========================================================="
echo "FIM DO JOB: $(date)"
echo "Tempo total de execução do script: ${DURATION} segundos."
echo "========================================================="
