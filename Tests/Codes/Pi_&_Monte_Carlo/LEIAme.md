# Cálculo de Pi com MPI e Slurm

![Linguagem](https://img.shields.io/badge/Linguagem-C-blue.svg)
![Paralelismo](https://img.shields.io/badge/Framework-MPI-orange.svg)
![Cluster](https://img.shields.io/badge/Gerenciador-Slurm-red.svg)

Este projeto oferece uma implementação em C e MPI para calcular o valor de Pi (π) através do método estatístico de Monte Carlo. O sistema é projetado para ser executado de forma eficiente em clusters de computação de alto desempenho (HPC) gerenciados pelo Slurm Workload Manager.

## 🎯 Conceitos Chave

### Método de Monte Carlo para Pi
A ideia é simular o lançamento aleatório de "dardos" em um quadrado de lado 2, que contém um círculo de raio 1 inscrito nele. A área do quadrado é $2^2 = 4$, e a área do círculo é $\pi \cdot 1^2 = \pi$.

A razão entre a área do círculo e a área do quadrado é $\frac{\pi}{4}$. Portanto, se lançarmos um número muito grande de dardos, a proporção de dardos que caem dentro do círculo em relação ao total de dardos lançados será uma aproximação de $\frac{\pi}{4}$.

$$\pi \approx 4 \cdot \frac{\text{acertos dentro do círculo}}{\text{total de dardos lançados}}$$

### Paralelismo com MPI (Message Passing Interface)
Para tornar o cálculo viável com bilhões de "dardos", o trabalho é dividido entre múltiplos processos. O MPI é um padrão de comunicação que permite que esses processos, executando em diferentes nós de um cluster, troquem dados. Neste projeto, o trabalho é dividido, cada processo calcula uma parte, e os resultados são somados no final (`MPI_Reduce`).

## 📂 Descrição dos Arquivos

### 📄 `monte_carlo_mpi.c`
O núcleo da lógica de cálculo, escrito em C.

* **Inicialização MPI**: Configura o ambiente para comunicação entre processos.
* **Divisão de Carga**: O número total de "tiros" é dividido igualmente entre todos os processos alocados (`total_tiros / num_procs`).
* **Cálculo Independente**: Cada processo executa sua própria simulação de Monte Carlo.
* **Sementes Aleatórias Distintas**: Garante a independência estatística dos resultados usando o `rank` do processo para gerar uma semente única para a função `srand()`.
* **Agregação de Resultados**: Utiliza `MPI_Reduce` para somar os acertos de todos os processos e consolidar o resultado no processo mestre (rank 0).
* **Saída Formatada**: Apenas o processo mestre imprime o resultado final, evitando saídas duplicadas.

### 📜 `pi_mpi_flexivel.sh`
Um script de submissão para o Slurm que automatiza a execução no cluster.

* **Diretivas Slurm**: As linhas `#SBATCH` configuram o job, definindo nome, arquivos de log, tempo de execução e, mais importante, o número de tarefas por nó (`--ntasks-per-node=1`).
* **Flexibilidade**: Permite que o usuário defina o número de nós na linha de comando (`sbatch --nodes=...`).
* **Automação do Fluxo de Trabalho**:
    1.  Cria um diretório de trabalho seguro e isolado para cada job.
    2.  Copia o código-fonte para o diretório de trabalho.
    3.  Compila o código C usando `mpicc` com o flag de otimização `-O3`.
    4.  Executa o programa compilado com `mpirun`, que se integra perfeitamente ao Slurm para distribuir os processos pelos nós alocados.
    5.  Mede e reporta o tempo total de execução.

## 🚀 Como Usar (em um Cluster com Slurm)

### 1. Pré-requisitos
O script `pi_mpi_flexivel.sh` espera encontrar o código-fonte C em um local específico. Garanta que o arquivo esteja no caminho correto ou ajuste o script:
```bash
# Caminho definido no script pi_mpi_flexivel.sh
SOURCE_FILE="/nfs/execution/monte_carlo_mpi.c"
```

### 2. Submissão do Job
Use o comando `sbatch` para enviar o script para a fila do Slurm. Você deve especificar:
-   `--nodes`: O número de nós de computação que deseja usar.
-   `<numero_total_de_tiros>`: O argumento para o script, que representa a carga de trabalho total.

**Sintaxe:**
```bash
sbatch --nodes=<numero_de_nos> pi_mpi_flexivel.sh <numero_total_de_tiros>
```

**Exemplo Prático:**
Para executar o cálculo em **16 nós** com **100 bilhões de tiros**:
```bash
sbatch --nodes=16 pi_mpi_flexivel.sh 100000000000
```
**Atenção:** O número total de tiros deve ser divisível pelo número de nós.

### 3. Análise dos Resultados
Os logs de saída e erro serão gerados nos diretórios `/nfs/return/out/` e `/nfs/return/err/`, respectivamente, com o ID do Job no nome do arquivo.

## 💡 Recomendação de Carga de Trabalho

Para resultados com maior precisão e para realmente testar a capacidade do cluster, é recomendado usar um número de "tiros" (tentativas) muito alto.

> **Recomenda-se iniciar os testes com valores acima de 9 bilhões de tiros.**

Quanto maior o número de tiros, mais o resultado se aproximará do valor real de π, e mais evidente será o benefício da computação paralela na redução do tempo de execução.

## 💻 Como Executar Localmente (Sem Slurm)

Se você tiver uma implementação do MPI (como Open MPI ou MPICH) instalada em sua máquina local, pode compilar e executar o programa diretamente.

### 1. Compilação
Use o `mpicc`, que é um wrapper para o seu compilador C (como o GCC), para compilar o programa.
```bash
mpicc monte_carlo_mpi.c -o pi_exec_monte_carlo -O3 -lm
```

### 2. Execução
Use `mpirun` ou `mpiexec` para executar o programa compilado.
-   Use o flag `-np` para especificar o número de processos que deseja simular.

**Sintaxe:**
```bash
mpirun -np <numero_de_processos> ./pi_exec_monte_carlo <numero_total_de_tiros>
```

**Exemplo Prático:**
Para executar com **4 processos** e **1 bilhão de tiros**:
```bash
mpirun -np 4 ./pi_exec_monte_carlo 1000000000
```

## 📊 Exemplo de Saída
A saída do programa, que será encontrada no arquivo de log do Slurm, terá o seguinte formato:
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
