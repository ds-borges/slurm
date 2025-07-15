# Cálculo de Pi com MPI e o Método de Monte Carlo

Este projeto demonstra como calcular o valor de Pi (π) utilizando o método estatístico de Monte Carlo. A implementação é feita em C e utiliza o padrão MPI (Message Passing Interface) para paralelizar o cálculo e executá-lo de forma eficiente em um cluster de computadores.

## O Método de Monte Carlo para Pi

A ideia é simular o lançamento aleatório de "dardos" em um quadrado de lado 2, que contém um círculo de raio 1 inscrito nele. A área do quadrado é $2^2 = 4$, e a área do círculo é $\pi \cdot 1^2 = \pi$.

A razão entre a área do círculo e a área do quadrado é $\frac{\pi}{4}$. Portanto, se lançarmos um número muito grande de dardos, a proporção de dardos que caem dentro do círculo em relação ao total de dardos lançados será uma aproximação de $\frac{\pi}{4}$.

A partir daí, podemos estimar o valor de Pi:

$$\pi \approx 4 \cdot \frac{\text{acertos dentro do círculo}}{\text{total de dardos lançados}}$$

## O Desafio e a Solução com Paralelismo

Para que a aproximação seja precisa, precisamos de um número gigantesco de "dardos", na casa dos bilhões. Realizar essa tarefa em um único computador seria extremamente lento. A solução é usar paralelismo. Para tornar o cálculo viável, o trabalho é dividido entre múltiplos processos de computador. O MPI é um padrão de comunicação que permite que esses processos, executando em diferentes máquinas (nós de um cluster), troquem dados e cooperem.

### Estratégia de Paralelização: Uma Analogia

Para entender como essa divisão funciona na prática, podemos imaginar uma equipe de ajudantes contratada para realizar o jogo de dardos:

* **Divisão da Tarefa:** O trabalho total (ex: 1 bilhão de dardos) é dividido igualmente entre o número de ajudantes disponíveis. No código, cada processo simplesmente calcula sua cota com a linha `shots_per_process = total_shots / num_procs;`.
* **Execução Única e Paralela:** Cada ajudante começa a jogar sua cota de dardos ao mesmo tempo que os outros. O ponto crucial é que cada um tem uma "técnica de arremesso" única, garantindo que não dupliquem o trabalho. No código, isso é assegurado porque cada processo inicializa seu gerador de números aleatórios com uma "semente" única (`srand(time(NULL) + rank);`), fazendo com que os pontos `(x, y)` gerados por `rand()` sejam diferentes para cada um.
* **Agregação dos Resultados:** Ao final, um líder de equipe pergunta a cada ajudante quantos acertos ele teve e soma tudo para obter o total geral. Essa etapa de "somar tudo" é realizada eficientemente pela função `MPI_Reduce(&local_hits, &global_hits, 1, MPI_LONG_LONG, MPI_SUM, 0, MPI_COMM_WORLD);` do MPI, que coleta os `local_hits` de todos e os soma no processo mestre (rank 0).

### Descrição dos Arquivos

📄 **`monte_carlo_mpi.c`**

* O núcleo da lógica de cálculo, escrito em C.
* **Inicialização MPI:** Configura o ambiente para comunicação entre processos com `MPI_Init`.
* **Divisão de Carga:** O número total de "tiros" é dividido igualmente entre todos os processos alocados (`total_shots / num_procs`).
* **Cálculo Independente:** Cada processo executa sua própria simulação de Monte Carlo em um laço `for`.
* **Sementes Aleatórias Distintas:** Garante a independência estatística dos resultados usando o `rank` do processo para gerar uma semente única para a função `srand()`.
* **Agregação de Resultados:** Utiliza `MPI_Reduce` para somar os acertos (`local_hits`) de todos os processos e consolidar o resultado (`global_hits`) no processo mestre (rank 0).
* **Saída Formatada:** Apenas o processo mestre (`rank == 0`) imprime o resultado final, evitando saídas duplicadas.

📜 **`pi_mpi_flexivel.sh`**

* Um script de submissão para o Slurm que automatiza a execução no cluster.
* **Diretivas Slurm:** As linhas `#SBATCH` configuram o job, definindo nome, arquivos de log, tempo de execução e o número de tarefas por nó (`--ntasks-per-node=1`).
* **Flexibilidade:** Permite que o usuário defina o número de nós na linha de comando (`sbatch --nodes=...`).
* **Automação do Fluxo de Trabalho:**
    * Cria um diretório de trabalho seguro e isolado para cada job.
    * Copia o código-fonte para o diretório de trabalho.
    * Compila o código C usando `mpicc` com o flag de otimização `-O3`.
    * Executa o programa compilado com `mpirun`, que se integra ao Slurm para distribuir os processos pelos nós alocados.
    * Mede e reporta o tempo total de execução do script.

### 🚀 Como Usar (em um Cluster com Slurm)

**1. Pré-requisitos**

O script `pi_mpi_flexivel.sh` espera encontrar o código-fonte C em um local específico. Garanta que o arquivo esteja no caminho correto ou ajuste a variável `SOURCE_FILE` no script.

**2. Submissão do Job**

Use o comando `sbatch` para enviar o script para a fila do Slurm. Você deve especificar:
* `--nodes`: O número de nós de computação que deseja usar.
* `<number_of_shots>`: O argumento para o script, que representa a carga de trabalho total.

**Sintaxe:**
```bash
sbatch --nodes=<numero_de_nos> pi_mpi_flexivel.sh <number_of_shots>
```

**Exemplo Prático:** Para executar o cálculo em 16 nós com 100 bilhões de tiros:
```bash
sbatch --nodes=16 pi_mpi_flexivel.sh 100000000000
```
**Atenção:** O número total de tiros deve ser divisível pelo número de processos (nós, neste caso).

**3. Análise dos Resultados**

Os logs de saída e erro serão gerados nos diretórios `/nfs/return/out/` e `/nfs/return/err/`, respectivamente, com o ID do Job (`$SLURM_JOB_ID`) no nome do arquivo.

### 💻 Como Executar Localmente (Sem Slurm)

Se você tiver uma implementação do MPI (como Open MPI ou MPICH) instalada, pode compilar e executar o programa.

**1. Compilação**

Use o `mpicc` para compilar o programa. O comando abaixo usa otimização `-O3`.
```bash
mpicc monte_carlo_mpi.c -o pi_exec_monte_carlo -O3 -lm
```

**2. Execução**

Use `mpirun` com o flag `-np` para especificar o número de processos.
**Sintaxe:**
```bash
mpirun -np <numero_de_processos> ./pi_exec_monte_carlo <numero_total_de_tiros>
```
**Exemplo Prático:** Para executar com 4 processos e 1 bilhão de tiros:
```bash
mpirun -np 4 ./pi_exec_monte_carlo 1000000000
```

### 📊 Exemplo de Saída

A saída do programa, que será impressa pelo processo de rank 0, terá o seguinte formato:

```
====================================================
Calculation of Pi with MPI and Monte Carlo Method
----------------------------------------------------
Number of MPI processes...: 16
Total shots...............: 100000000000
Total hits................: 78539815000
Calculation execution time: 152.731982 seconds
Estimated value of Pi.....: 3.141592600000000
====================================================
```