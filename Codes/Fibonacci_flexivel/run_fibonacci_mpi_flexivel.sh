#!/bin/bash

#SBATCH --job-name=fibonacci_flexivel # Nome do job
#SBATCH --output=/nfs/return/out/fibonacci_flex_out_%j.txt  # Arquivo de saída
#SBATCH --error=/nfs/return/err/fibonacci_flex_err_%j.txt   # Arquivo para erros

# --- DIRETIVAS DE NÓS (FLEXÍVEL) ---
#SBATCH --ntasks-per-node=1       # Inicia 1 processo em cada um dos nós alocados
# -----------------------------------------------------------------

#SBATCH --time=08:00:00           # Tempo máximo de execução

# --- Validação da Entrada do Script ---
if [ "$#" -ne 1 ]; then
    echo "ERRO: É preciso fornecer o número para o cálculo de Fibonacci."
    echo "Uso: sbatch [opções] $0 <numero>"
    echo "Exemplo: sbatch --nodes=3 $0 45"
    exit 1
fi
FIB_NUMBER=$1

# --- MEDIÇÃO DE TEMPO E INFORMAÇÕES DO JOB ---
START_TIME_SECONDS=$(date +%s)
echo "========================================================="
echo "INÍCIO DO JOB: $(date)"
echo "ID do Job: $SLURM_JOB_ID"
echo "Nós solicitados: $SLURM_NNODES | Processos Totais: $SLURM_NTASKS"
echo "Nós utilizados: $SLURM_NODELIST"
echo "Número Limite para Fibonacci: F($FIB_NUMBER)"
echo "========================================================="
echo ""

# --- Define um diretório de trabalho seguro ---
WORK_DIR=/nfs/return/job/job_$SLURM_JOB_ID
mkdir -p $WORK_DIR

# --- Copia o novo código-fonte para o diretório de trabalho ---
# ATUALIZE PARA O NOME DO NOVO ARQUIVO C
SOURCE_FILE="/nfs/execution/fibonacci_mpi_flexivel.c" 
cp $SOURCE_FILE $WORK_DIR

# --- Muda para o diretório de trabalho ---
cd $WORK_DIR
echo "Executando no diretório de trabalho: $(pwd)"
echo ""

# --- PASSO DE COMPILAÇÃO ---
echo "Compilando o código C com 'mpicc'..."
# Compila o novo arquivo para um novo executável
mpicc fibonacci_mpi_flexivel.c -o fibonacci_exec_flexivel -lm

if [ $? -ne 0 ]; then
    echo "ERRO NA COMPILAÇÃO!"
    exit 1
fi
echo "Compilação concluída."
echo ""

# --- PASSO DE EXECUÇÃO COM MPIRUN ---
echo "Executando o programa com mpirun em $SLURM_NNODES nó(s)..."
# Passa o número do Fibonacci como argumento para o executável
mpirun -np $SLURM_NTASKS ./fibonacci_exec_flexivel $FIB_NUMBER
echo ""

# --- MEDIÇÃO DE TEMPO FINAL ---
END_TIME_SECONDS=$(date +%s)
DURATION=$((END_TIME_SECONDS - START_TIME_SECONDS))

echo "========================================================="
echo "FIM DO JOB: $(date)"
echo "Tempo total de execução do script: ${DURATION} segundos."
echo "========================================================="
