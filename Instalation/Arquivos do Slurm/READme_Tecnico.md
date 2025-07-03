===================================================================
GUIA TÉCNICO PARA CONFIGURAÇÃO E CUSTOMIZAÇÃO DO CLUSTER SLURM
===================================================================

Este documento serve como um guia de referência para adaptar os arquivos de configuração do Slurm para um novo ambiente de hardware.

Os arquivos representam uma configuração funcional que inclui funcionalidades avançadas como gerenciamento de energia (suspender/reativar nós) e controle de recursos com cgroups.


--- DESCRIÇÃO DOS ARQUIVOS DE CONFIGURAÇÃO ---

* slurm.conf:
  É o arquivo principal de configuração do Slurm. Ele define o nome do cluster, o nó mestre (controlador), as especificações de cada nó de computação (CPU, memória, etc.), as partições de trabalho e os parâmetros para funcionalidades avançadas como o power saving.

* slurmdbd.conf:
  Configura o daemon do banco de dados do Slurm (SlurmDBD). Ele gerencia a conexão com o banco de dados MySQL/MariaDB onde todo o histórico de jobs e a contabilidade do cluster são armazenados.

* cgroup.conf:
  Configura como o Slurm utilizará os Control Groups (cgroups) do Linux. Neste caso, está configurado para restringir o uso de núcleos de CPU e memória RAM pelos jobs, garantindo que um job não utilize mais recursos do que foi alocado.

* suspend.sh e resume.sh:
  São os scripts customizados que controlam o gerenciamento de energia.
  - `suspend.sh`: É executado pelo Slurm para desligar (via `poweroff`) um nó que está ocioso por um determinado tempo.
  - `resume.sh`: É executado para "acordar" um nó desligado, enviando um pacote Wake-on-LAN.

* mac_addresses.list:
  Um arquivo auxiliar utilizado pelo script `resume.sh`. Ele mapeia os nomes dos nós (hostnames) para seus respectivos endereços MAC da placa de rede, que são necessários para o Wake-on-LAN.


--- GUIA DE ALTERAÇÕES OBRIGATÓRIAS PARA UM NOVO AMBIENTE ---

Para que esta configuração funcione em um novo conjunto de computadores, as seguintes alterações são CRÍTICAS:

**1. No arquivo `slurm.conf`:**

* `SlurmctldHost`: Altere o nome do host e o endereço IP para corresponderem ao seu novo nó Mestre.
  Ex: `SlurmctldHost=MeuNovoMaster(192.168.1.100)`

* `AccountingStorageHost`: Altere para o nome do host do seu novo nó Mestre.

* `NodeName`: Esta é a alteração mais importante. Você deve apagar as linhas `NodeName=Node01...`, `NodeName=Node02...`, etc., e adicionar novas linhas que descrevam CADA um dos seus novos nós de computação. Certifique-se de que os valores de `NodeAddr`, `CPUs`, e `RealMemory` estão corretos para o hardware de cada nó.

* `PartitionName`: Após redefinir os nós, atualize a lista `Nodes=` em cada partição para que ela inclua os seus novos nomes de nós.

**2. No arquivo `slurmdbd.conf`:**

* `DbdHost` e `StorageHost`: Altere para o nome do host do seu novo nó Mestre.

* `StoragePass`: Altere a senha 'bccufj07' para a senha que você configurou para o usuário 'slurm' no seu banco de dados MariaDB.

**3. No arquivo `resume.sh`:**

* `MAC_LIST_FILE`: O script aponta para `/etc/slurm/mac_addresses.list`. Certifique-se de que este caminho corresponde ao local e nome do seu arquivo de endereços MAC (neste caso, `mac_addresses.list`). É recomendado mover o arquivo para `/etc/slurm/` e renomeá-lo ou ajustar o caminho no script.

* `WOL_INTERFACE`: O valor "enp2s0" é o nome da interface de rede do nó Mestre original. Você DEVE encontrar o nome da interface de rede correta no seu novo nó Mestre (usando o comando `ip a`) e atualizar esta variável.

**4. No arquivo `mac_addresses.list`:**

* Apague todo o conteúdo e preencha com a lista dos seus novos nós e seus respectivos endereços MAC, mantendo o formato `NomeDoNo endereço:mac`.

**5. Pré-requisitos do Sistema para os Scripts de Energia:**

* Para `suspend.sh`: O script executa `ssh slurm@${node} "sudo /sbin/poweroff"`. Isso exige que:
  a) O acesso SSH sem senha do usuário `slurm` do nó Mestre para todos os nós de computação esteja configurado.
  b) O usuário `slurm` tenha permissão de executar `sudo /sbin/poweroff` sem senha em todos os nós de computação (configurado via `/etc/sudoers`).
    $ sudo visudo

* Para `resume.sh`: O script usa `sudo /usr/sbin/etherwake`. O usuário `slurm` no nó Mestre precisa de permissão para executar este comando via `sudo` sem senha.
    $ sudo visudo