# Guia de Instalação Manual de Cluster Slurm

![Gerenciador](https://img.shields.io/badge/Gerenciador-Slurm-blue.svg)
![Autenticação](https://img.shields.io/badge/Autenticação-Munge-purple.svg)
![Paralelismo](https://img.shields.io/badge/Paralelismo-Open%20MPI-orange.svg)
![Rede](https://img.shields.io/badge/Rede-NFS-lightgrey.svg)
![Linguagem](https://img.shields.io/badge/Comandos-Bash-yellow.svg)

Este repositório contém um conjunto de arquivos de texto com listas de comandos para a instalação manual e passo a passo de um cluster Slurm.  O objetivo é servir como um guia de consulta completo, permitindo que um administrador entenda a função de cada comando e adapte a instalação a um novo ambiente. 

## ⚙️ Fluxo de Instalação

A instalação segue uma ordem lógica e progressiva.  É crucial seguir a sequência numérica dos arquivos para garantir que as dependências de cada etapa sejam atendidas. 

1.  **Configuração do Ambiente Base**: Preparação da infraestrutura de rede, tempo e arquivos. 
2.  **Instalação da Autenticação**: Instalação e configuração do Munge para comunicação segura. 
3.  **Instalação do Slurm**: Configuração do Nó Mestre e, em seguida, dos Nós de Computação. 
4.  **Instalação do Suporte a MPI**: Compilação do Open MPI para permitir a execução de trabalhos paralelos. 

## 📄 Guia dos Arquivos de Comandos

Aqui está a descrição de cada arquivo e onde seus comandos devem ser executados. 

### `1-Comandos_Configurar_Ambiente_Base.txt`
* **Objetivo**: Configurar os pré-requisitos essenciais para o funcionamento do cluster.
* **Onde Executar**: Em **TODOS** os nós (Mestre e Computação).  O arquivo possui seções que se aplicam apenas ao mestre ou aos nós de computação, conforme indicado. 

### `2-Comandos_para_Instalar_Munge.txt`
* **Objetivo**: Instalar e configurar o serviço de autenticação Munge. 
* **Onde Executar**: Em **TODOS** os nós. 

### `3-Comandos_para_Instalar_Slurm_(Nó Mestre).txt`
* **Objetivo**: Instalar os componentes centrais ("cérebro") do cluster Slurm. 
* **Onde Executar**: Apenas no **NÓ MESTRE**. 

### `4-Comandos_para_Instalar_o_Slurm_(Nós_de_Computação).txt`
* **Objetivo**: Instalar o serviço "trabalhador" do Slurm (`slurmd`). 
* **Onde Executar**: Apenas nos **NÓS DE COMPUTAÇÃO**. 

### `5-Comandos_para_Compilar_OpenMPI.txt`
* **Objetivo**: Preparar o ambiente para a execução de trabalhos paralelos de alto desempenho. 
* **Onde Executar**: Em **TODOS** os nós. 

## ⚠️ Pontos de Alteração Obrigatórios

Antes de executar os comandos, revise e altere os seguintes valores para que correspondam ao seu ambiente.

### Passo 1: `1-Comandos_Configurar_Ambiente_Base.txt` 
* **Mapeamento de Rede**: Altere a lista de IPs e Nomes de Nós na seção de configuração do arquivo `/etc/hosts`. 
* **Configuração do NFS**:
    * Altere a faixa de rede (ex: `192.168.1.0/24`) no comando de configuração do `/etc/exports`. 
    * Altere o IP do nó Mestre no comando `sudo mount ...`. 
* **Configuração do SSH**: Altere a lista de comandos `ssh-copy-id` para incluir os nomes de usuário e de nós corretos para o seu cluster. 

### Passo 2: `2-Comandos_para_Instalar_Munge.txt` 
* **(Opcional) IDs de Usuário**: Os IDs para os usuários `munge` e `slurm` estão fixos como `1001` e `1002`.  Pode ser necessário alterar esses valores se eles já estiverem em uso no seu sistema. 

### Passo 3: `3-Comandos_para_Instalar_Slurm_(Nó Mestre).txt` 
Este passo envolve a edição de vários arquivos de configuração.

* **No arquivo `slurmdbd.conf`:**
    * **Senha do Banco de Dados**: A senha do usuário 'slurm' para o MariaDB está definida como `'bccufj07'`.  É crucial alterá-la tanto no comando SQL `GRANT ALL...` quanto no parâmetro `StoragePass=...` dentro deste arquivo. 
    * **Host do Banco de Dados**: Verifique se `DbdHost` e `StorageHost` correspondem ao nome do seu novo nó Mestre. 
* **No arquivo `slurm.conf`:**
    * `SlurmctldHost`: Deve conter o nome correto do seu nó Mestre. 
    * `NodeName`: As linhas `NodeName=...` devem ser reescritas para listar os nomes e as configurações de CPU/memória corretas para cada um dos seus nós. 
    * `PartitionName`: As linhas `PartitionName=...` devem ser ajustadas para refletir quais nós pertencem a cada partição. 
* **No script `resume.sh`:**
    * `WOL_INTERFACE`: O valor está fixo como `"enp2s0"`.  Você **DEVE** encontrar o nome correto da interface de rede do seu novo nó Mestre (usando `ip a`) e atualizar esta variável. 
* **No arquivo `mac_addresses.list`:**
    * Este arquivo deve ser **completamente reescrito** com os nomes e endereços MAC correspondentes aos seus novos nós de computação. 
* **Pré-requisitos de Sistema para Energia:**
    * Para que os scripts `suspend.sh` e `resume.sh` funcionem, o usuário `slurm` precisa de permissões `sudo` sem senha.  Use `sudo visudo` para garantir que: 
        1.  No **Nó Mestre**, `slurm` possa executar `/usr/sbin/etherwake`. 
        2.  Em **TODOS os Nós de Computação**, `slurm` possa executar `/sbin/poweroff`. 

### Passo 5: `5-Comandos_para_Compilar_OpenMPI.txt` 
* **Versão do Open MPI**: A versão `4.1.5` está fixa nos comandos `wget`, `cd` e `configure`.  Se você precisar de outra versão, deverá alterar o número em cada um desses comandos. 
