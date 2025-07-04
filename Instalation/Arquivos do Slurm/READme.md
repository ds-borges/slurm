# Guia Técnico: Customização de Ambiente Slurm

![Gerenciador](https://img.shields.io/badge/Gerenciador-Slurm-blue.svg)
![Banco de Dados](https://img.shields.io/badge/Banco_de_Dados-MySQL_/_MariaDB-orange.svg)
![Linguagem](https://img.shields.io/badge/Scripts-Bash-yellow.svg)
![Tecnologia](https://img.shields.io/badge/Tecnologia-cgroups-lightgrey.svg)
![Tecnologia](https://img.shields.io/badge/Tecnologia-Wake--on--LAN-informational.svg)

Este documento é uma referência técnica para adaptar os arquivos de configuração do Slurm a um novo ambiente de hardware. A configuração fornecida é totalmente funcional e inclui recursos avançados, como gerenciamento de energia (suspender/reativar nós ociosos) e controle estrito de recursos com cgroups.

## 📄 Descrição dos Arquivos de Configuração

* `slurm.conf`
    * É o arquivo de configuração principal do Slurm. Ele define o nome do cluster, o nó controlador (mestre), as especificações de hardware de cada nó de computação (CPUs, memória), as partições de trabalho e os parâmetros para o recurso de economia de energia.

* `slurmdbd.conf`
    * Configura o daemon do banco de dados do Slurm (SlurmDBD). Este arquivo gerencia a conexão com o banco de dados (MySQL/MariaDB), onde o histórico de jobs e a contabilidade do cluster são armazenados.

* `cgroup.conf`
    * Define como o Slurm utilizará os Control Groups (cgroups) do kernel Linux.  Nesta configuração, ele é usado para restringir o uso de núcleos de CPU e memória RAM, garantindo que os jobs não consumam mais recursos do que o alocado.

* `suspend.sh` e `resume.sh`
    * Scripts customizados que gerenciam o ciclo de energia dos nós. 
    * **`suspend.sh`**: Executado pelo Slurm para desligar um nó ocioso através do comando `poweroff`.
    * **`resume.sh`**: Executado para "acordar" um nó desligado, enviando um pacote mágico Wake-on-LAN.

* `mac_addresses.list`
    * Um arquivo auxiliar usado pelo script `resume.sh`. Ele mapeia os hostnames dos nós aos seus respectivos endereços MAC, que são essenciais para o funcionamento do Wake-on-LAN.

## ⚠️ Guia de Alterações Obrigatórias

Para que esta configuração funcione em um novo ambiente, as seguintes alterações são **críticas**.

### 1. No arquivo `slurm.conf`:
* `SlurmctldHost`: Altere o nome do host e o IP para os do seu novo nó Mestre. 
Exemplo: `SlurmctldHost=MeuNovoMaster(192.168.1.100)`. 
* `AccountingStorageHost`: Altere para o nome do host do seu novo nó Mestre. 
* `NodeName`: **Esta é a alteração mais importante.** Remova as definições existentes e adicione uma nova linha para CADA um dos seus nós de computação, garantindo que `NodeAddr`, `CPUs` e `RealMemory` correspondam ao hardware de cada um.
* `PartitionName`: Após redefinir os nós, atualize a lista `Nodes=` em cada partição para incluir os nomes dos seus novos nós.

### 2. No arquivo `slurmdbd.conf`:
* `DbdHost` e `StorageHost`: Altere para o nome do host do seu novo nó Mestre.
* `StoragePass`: Altere a senha `bccufj07` para a senha que você definiu para o usuário `slurm` no seu banco de dados MariaDB.

### 3. No arquivo `resume.sh`:
* `MAC_LIST_FILE`: O script aponta para `/etc/slurm/mac_addresses.list`. Certifique-se de que este caminho esteja correto ou mova seu arquivo para este local.
* `WOL_INTERFACE`: Altere o valor `"enp2s0"` para o nome da interface de rede do seu novo nó Mestre. Você pode encontrar o nome correto usando o comando `ip a`.

### 4. No arquivo `mac_addresses.list`:
* Apague todo o conteúdo e preencha com a lista dos seus novos nós e seus respectivos endereços MAC. Mantenha o formato `NomeDoNo endereço:mac`.

## 🛠️ Pré-requisitos do Sistema para Gerenciamento de Energia

* **Para `suspend.sh` funcionar:**
    * O script executa o comando `ssh slurm@${node} "sudo /sbin/poweroff"`.
    * Isso exige que o acesso SSH sem senha do usuário `slurm` (do nó Mestre para todos os nós de computação) esteja configurado.     * Também exige que o usuário `slurm` tenha permissão para executar `sudo /sbin/poweroff` sem precisar de senha em todos os nós de computação. Esta permissão é configurada via `/etc/sudoers` (usando `sudo visudo`). 

* **Para `resume.sh` funcionar:**
    * O script utiliza o comando `sudo /usr/sbin/etherwake`.
    * O usuário `slurm` no nó Mestre precisa ter permissão para executar este comando via `sudo` sem senha.
