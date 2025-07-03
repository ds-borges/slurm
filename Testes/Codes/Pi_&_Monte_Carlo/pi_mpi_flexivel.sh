#!/bin/bash

#SBATCH --job-name=CalculoPi_MPI_flexivel   # Nome do job
#SBATCH --output=/nfs/return/out/pi_mpi_out_%j.txt      # Arquivo de saída
#SBATCH --error=/nfs/return/err/pi_mpi_err_%j.txt       # Arquivo para erros

# --- DIRETIVAS DE NÓS (FLEXÍVEL) ---
# O número de nós será definido na linha de comando (ex: sbatch --nodes=4 ...)
#SBATCH --ntasks-per-node=1          # Inicia 1 processo em cada um dos nós alocados
# -----------------------------------------------------------------

#SBATCH --time=08:00:00              # Tempo máximo de execução

# --- Validação da Entrada do Script ---
if [ "$#" -ne 1 ]; then
    echo "ERRO: É preciso fornecer o número total de 'tiros' para o cálculo."
    echo "Uso: sbatch [opções] $0 <numero_de_tiros>"
    echo "Exemplo: sbatch --nodes=4 $0 10000000000"
    exit 1
fi
TOTAL_THROWS=$1

# --- MEDIÇÃO DE TEMPO E INFORMAÇÕES DO JOB ---
START_TIME_SECONDS=$(date +%s)
echo "========================================================="
echo "INÍCIO DO JOB: $(date)"
echo "ID do Job: $SLURM_JOB_ID"
echo "Nós solicitados: $SLURM_NNODES | Processos Totais: $SLURM_NTASKS"
echo "Nós utilizados: $SLURM_NODELIST"
echo "Número Total de Tiros para Monte Carlo: $TOTAL_THROWS"
echo "========================================================="
echo ""

# --- Define um diretório de trabalho seguro ---
WORK_DIR=/nfs/return/job/job_$SLURM_JOB_ID
mkdir -p $WORK_DIR

# --- Copia o código-fonte para o diretório de trabalho ---
# O código C deve estar neste caminho para ser encontrado
SOURCE_FILE="/nfs/execution/monte_carlo_mpi.c" 
cp $SOURCE_FILE $WORK_DIR

# --- Muda para o diretório de trabalho ---
cd $WORK_DIR
echo "Executando no diretório de trabalho: $(pwd)"
echo ""

# --- PASSO DE COMPILAÇÃO ---
echo "Compilando o código C com 'mpicc'..."
# Compila o arquivo C para um novo executável
# Usando -O3 para otimização de performance
mpicc monte_carlo_mpi.c -o pi_exec_monte_carlo -O3 -lm

if [ $? -ne 0 ]; then
    echo "ERRO NA COMPILAÇÃO!"
    exit 1
fi
echo "Compilação concluída."
echo ""

# --- PASSO DE EXECUÇÃO COM MPIRUN ---
echo "Executando o programa com mpirun em $SLURM_NNODES nó(s)..."
# Passa o número de tiros como argumento para o executável
# mpirun usará o número de processos definido pelo Slurm ($SLURM_NTASKS)
mpirun -np $SLURM_NTASKS ./pi_exec_monte_carlo $TOTAL_THROWS
echo ""

# --- MEDIÇÃO DE TEMPO FINAL ---
END_TIME_SECONDS=$(date +%s)
DURATION=$((END_TIME_SECONDS - START_TIME_SECONDS))

echo "========================================================="
echo "FIM DO JOB: $(date)"
echo "Tempo total de execução do script: ${DURATION} segundos."
echo "========================================================="
