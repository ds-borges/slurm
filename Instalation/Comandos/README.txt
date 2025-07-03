============================================================
GUIA COMPLETO DE INSTALAÇÃO E CUSTOMIZAÇÃO DO CLUSTER SLURM
============================================================

Este documento descreve o conteúdo e o propósito de cada um dos cinco arquivos de texto fornecidos, que contêm listas de comandos para a instalação manual e passo a passo de um cluster Slurm.

O objetivo é servir como um guia de consulta completo, permitindo que um administrador entenda a função de cada bloco de comandos, onde eles devem ser executados e quais alterações são necessárias para adaptar a instalação a um novo ambiente.


--- FLUXO GERAL DA INSTALAÇÃO ---

A instalação segue uma ordem lógica e progressiva. É crucial seguir a sequência numérica dos arquivos para garantir que as dependências de cada passo sejam atendidas.

1.  **Configuração do Ambiente Base:** Preparação da infraestrutura de rede, tempo e arquivos.
2.  **Instalação da Autenticação:** Instalação do Munge para comunicação segura.
3.  **Instalação do Slurm:** Configuração separada do Nó Mestre e dos Nós de Computação.
4.  **Instalação do Suporte a MPI:** Compilação do Open MPI para trabalhos paralelos.


--- DESCRIÇÃO E LOCAL DE EXECUÇÃO DOS ARQUIVOS ---

**ARQUIVO 1: 1-Comandos_Configurar_Ambiente_Base.txt**
* **Objetivo:** Configurar os pré-requisitos essenciais para o funcionamento do cluster. 
* **Onde Executar:** Em TODOS os nós (Mestre e Computação). O arquivo contém seções específicas que devem ser aplicadas apenas no mestre ou apenas nos nós de computação, conforme indicado.

**ARQUIVO 2: 2-Comandos_para_Instalar_Munge.txt**
* **Objetivo:** Instalar e configurar o serviço de autenticação Munge.
* **Onde Executar:** Em TODOS os nós.

**ARQUIVO 3: 3-Comandos_para_Instalar_Slurm_(Nó Mestre).txt**
* **Objetivo:** Instalar os componentes centrais ("cérebro") do cluster Slurm.
* **Onde Executar:** Apenas no NÓ MESTRE.

**ARQUIVO 4: 4-Comandos_para_Instalar_o_Slurm_(Nós_de_Computação).txt**
* **Objetivo:** Instalar o serviço "trabalhador" do Slurm (`slurmd`).
* **Onde Executar:** Apenas nos NÓS DE COMPUTAÇÃO (escravos).

**ARQUIVO 5: 5-Comandos_para_Compilar_OpenMPI.txt**
* **Objetivo:** Preparar o ambiente para a execução de trabalhos paralelos de alto desempenho.
* **Onde Executar:** Em TODOS os nós.


--- PONTOS OBRIGATÓRIOS DE ALTERAÇÃO PARA UM NOVO AMBIENTE ---

Antes de executar os comandos, revise e altere os seguintes valores para que correspondam ao seu hardware e às suas preferências.

**No Passo 1 (`1-Comandos_Configurar_Ambiente_Base.txt`):**

* **Mapeamento de Rede:** Altere a lista de IPs e Nomes de Nós na seção do `/etc/hosts`.

* **Configuração do NFS: ** Altere a faixa de rede (ex: 192.168.1.0/24) no comando de configuração do `/etc/exports` e o IP do nó Mestre no comando `sudo mount ...`.

* **Configuração do SSH: ** Altere a lista de comandos `ssh-copy-id` para incluir os nomes de usuário e de nós corretos para o seu cluster. 

**No Passo 2 (`2-Comandos_para_Instalar_Munge.txt`):**

* **(Opcional) IDs de Usuário:** Os IDs para os usuários `munge` e `slurm` estão fixos como 1001 e 1002. Em sistemas já existentes, pode ser necessário alterar esses valores se eles já estiverem em uso.

**No Passo 3 (`3-Comandos_para_Instalar_Slurm_(Nó Mestre).txt` e seus arquivos):**

* **No arquivo `slurmdbd.conf`:**
    * **Senha do Banco de Dados:** A senha do usuário 'slurm' para o MariaDB está definida como 'bccufj07'. É crucial alterá-la no comando `GRANT ALL...` e no parâmetro `StoragePass=...` neste arquivo.
    * **Host do Banco de Dados:** Verifique se os parâmetros `DbdHost` e `StorageHost` correspondem ao nome do seu novo nó Mestre.

* **No arquivo `slurm.conf`:**
    * **Configuração Geral:** Este arquivo é um exemplo. O `SlurmctldHost` deve ser o nome correto do seu nó Mestre. As linhas `NodeName=...` devem listar os nomes e as configurações de CPU/memória corretas para cada um dos seus nós. As linhas `PartitionName=...` devem ser ajustadas para refletir os nós que pertencem a cada partição.

* **No arquivo de script `resume.sh`:**
    * **Interface de Rede (WOL_INTERFACE):** O valor está fixo como `"enp2s0"`. Você DEVE encontrar o nome correto da interface de rede do seu novo Mestre (com o comando `ip a`) e atualizar esta variável.

* **No arquivo `mac_addresses.list`:**
    * **Endereços MAC:** Este arquivo deve ser completamente reescrito com os nomes e endereços MAC correspondentes aos seus novos nós de computação.

* **Pré-requisitos de Sistema para Energia:**
    * Para que os scripts `suspend.sh` e `resume.sh` funcionem, o usuário `slurm` precisa de permissões especiais. Use `sudo visudo` para garantir que:
        1. No **Nó Mestre**, o usuário `slurm` possa executar `/usr/sbin/etherwake` sem senha.
        2. Em **TODOS os Nós de Computação**, o usuário `slurm` possa executar `/sbin/poweroff` sem senha.

**No Passo 4 (`4-Comandos_para_Instalar_o_Slurm_(Nós_de_Computação).txt`):**

* Nenhuma alteração de valor é necessária neste arquivo, pois ele copia as configurações do nó Mestre.

**No Passo 5 (`5-Comandos_para_Compilar_OpenMPI.txt`):**

* **Versão do Open MPI:** A versão do Open MPI (4.1.5) está fixa nos comandos `wget`, `cd` e `configure`. Se precisar de outra versão, você deverá alterar o número da versão em cada um desses comandos. 