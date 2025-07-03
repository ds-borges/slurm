====================================================
GUIA DE INSTALAÇÃO SEMI-AUTOMÁTICA DE CLUSTER SLURM
====================================================


--- Atenção: Scripts Semi-Automáticos ---

Os scripts neste diretório não instalarão tudo de forma 100% automática sem nenhuma intervenção. Eles foram criados para automatizar a grande maioria dos comandos, mas existem alguns pontos que exigirão sua atenção.

Pense neles como "semi-automáticos". Eles executam as tarefas pesadas, mas ainda precisam de um piloto.

----------------------------------------------------

--- Pontos de Intervenção Necessária ---

Aqui estão os pontos exatos onde a intervenção será necessária:

1. Intervenção Obrigatória: Senha do SSH (ssh-copy-id)
---------------------------------------------------------
Este é o principal ponto de parada. No script 01-configurar-ambiente-base.sh, o comando ssh-copy-id é usado para configurar o login sem senha entre os nós. Na primeira vez que ele se conectar a cada nó, ele vai pedir a senha daquele nó.

* Isso é intencional e uma medida de segurança.
* Você precisará digitar a senha de cada nó do cluster uma vez quando o script chegar a essa parte.


2. Intervenção de Preparação: Adaptação dos Scripts
------------------------------------------------------
Antes mesmo de executar os scripts, você precisará editá-los para que correspondam ao seu ambiente. Isso inclui:

* Endereços IP e Nomes dos Nós: No script 01, você deve garantir que a lista de IPs e nomes no arquivo /etc/hosts e na variável NODES esteja correta para o seu cluster.

* Arquivo slurm.conf: No script 03, foi incluído um slurm.conf mínimo apenas como exemplo. Para um cluster real, você precisará gerar uma configuração completa (usando o gerador online) e substituir o conteúdo de exemplo no script pelo seu.

* Senha do Banco de Dados: A senha do usuário 'slurm' do MariaDB está definida como 'bccufj07' no script 03. Você pode querer alterá-la. Se o fizer, lembre-se de atualizar também o campo StoragePass no arquivo slurmdbd.conf.


3. Intervenção Potencial: Senha do sudo e Erros
--------------------------------------------------
* Senha do sudo: Cada script precisa ser executado com sudo (sudo ./01-....sh). O sistema provavelmente pedirá sua senha de administrador no início da execução de cada script.

* Erros Inesperados: Se um comando falhar por qualquer motivo (por exemplo, um problema de rede durante o download de um pacote, um conflito de pacotes, etc.), o script irá parar. A automação não lida com a resolução de problemas; isso exigirá sua intervenção manual para corrigir o erro e reiniciar o processo.

----------------------------------------------------

--- Como Executar os Scripts ---

Passo 1: Dar Permissão de Execução
------------------------------------
Primeiro, torne os arquivos de script executáveis com o comando chmod +x:

    chmod +x 01-Configurar-ambiente-base.sh
    chmod +x 02-Instalar-munge.sh
    chmod +x 03-Instalar-slurm-mestre.sh
    chmod +x 04-Instalar-slurm-no-computacao.sh
    chmod +x 05-Compilar-openmpi.sh


Passo 2: Executar os Scripts na Ordem Correta
------------------------------------------------
Execute os scripts como superusuário (sudo) e na sequência numérica correta. Lembre-se de executar nos nós apropriados (Mestre vs. Computação), conforme detalhado anteriormente.

    # Execute o script 01 em todos os nós
    sudo ./01-Configurar-ambiente-base.sh

    # Execute o script 02 em todos os nós
    sudo ./02-Instalar-munge.sh

    # Execute o script 03 APENAS no nó Mestre
    sudo ./03-Instalar-slurm-mestre.sh

    # Execute o script 04 APENAS nos nós de Computação
    sudo ./04-Instalar-slurm-no-computacao.sh

    # Execute o script 05 em todos os nós
    sudo ./05-Compilar-openmpi.sh

----------------------------------------------------

--- Conclusão ---

Os scripts eliminam a necessidade de digitar centenas de comandos manualmente, o que reduz drasticamente o tempo de instalação e a chance de erros de digitação. No entanto, eles ainda exigem um administrador para prepará-los, fornecer as senhas iniciais e supervisionar o processo.