 # Guia de Instalação Semi-Automática de Cluster Slurm

![Nível](https://img.shields.io/badge/Automação-Semi--Automática-orange.svg)
![Linguagem](https://img.shields.io/badge/Scripts-Bash-yellow.svg)
![Gerenciador](https://img.shields.io/badge/Gerenciador-Slurm-blue.svg)
![Protocolo](https://img.shields.io/badge/Protocolo-SSH-lightgrey.svg)

Este guia detalha o uso dos scripts para uma instalação semi-automática do Slurm. Os scripts foram projetados para automatizar a grande maioria dos comandos, mas exigem a supervisão e intervenção de um administrador em pontos-chave. 

> Pense neles como "semi-automáticos". Eles executam as tarefas pesadas, mas ainda precisam de um piloto. 

## 🛠️ Pontos de Intervenção Necessária

É crucial entender onde sua ação será necessária para garantir que a instalação ocorra sem problemas.

### 1. Intervenção Durante a Execução: Senhas

* **Senha do SSH**: Este é o principal ponto de parada durante a execução. 
    * O script `01-configurar-ambiente-base.sh` usa o comando `ssh-copy-id` para configurar o acesso sem senha entre os nós. 
    * Você precisará digitar a senha de cada nó do cluster uma vez quando o script solicitar.  Esta é uma medida de segurança intencional. 
* **Senha do `sudo`**: Cada script deve ser executado com privilégios de superusuário (`sudo`).  É provável que o sistema solicite sua senha de administrador no início da execução de cada um dos cinco scripts. 

### 2. Intervenção de Preparação: Adaptação dos Scripts
Antes de executar qualquer coisa, você **precisa** editar os scripts para que correspondam ao seu ambiente. 

* **Endereços IP e Nomes dos Nós**: No script `01-configurar-ambiente-base.sh`, garanta que a lista de IPs e nomes no arquivo `/etc/hosts` e na variável `NODES` esteja correta para o seu cluster. 
* **Arquivo `slurm.conf`**: O script `03-Instalar-slurm-mestre.sh` contém um `slurm.conf` mínimo apenas como exemplo.  Para um cluster real, você deve gerar uma configuração completa (usando o gerador online do Slurm, por exemplo) e substituir o conteúdo de exemplo dentro do script pelo seu. 
* **Senha do Banco de Dados**: A senha para o usuário `slurm` do MariaDB está definida como `'bccufj07'` no script `03`.  Se você alterar essa senha no script, lembre-se de atualizar também o campo `StoragePass` no arquivo `slurmdbd.conf`. 

### 3. Intervenção Potencial: Resolução de Erros
* A automação não lida com a resolução de problemas.  Se um comando falhar por qualquer motivo (problema de rede, conflito de pacotes, etc.), o script irá parar.  Isso exigirá sua intervenção manual para corrigir o erro e reiniciar o processo. 

## 🚀 Como Executar os Scripts

### Passo 1: Conceder Permissão de Execução
Primeiro, torne todos os scripts executáveis com o comando `chmod +x`.

```bash
chmod +x 01-Configurar-ambiente-base.sh
chmod +x 02-Instalar-munge.sh
chmod +x 03-Instalar-slurm-mestre.sh
chmod +x 04-Instalar-slurm-no-computacao.sh
chmod +x 05-Compilar-openmpi.sh
```

### Passo 2: Executar na Ordem Correta
Execute os scripts com `sudo` e na sequência numérica correta, prestando atenção em quais nós cada script deve ser executado. 

```bash
# Execute o script 01 em TODOS os nós
sudo ./01-Configurar-ambiente-base.sh

# Execute o script 02 em TODOS os nós
sudo ./02-Instalar-munge.sh

# Execute o script 03 APENAS no nó Mestre
sudo ./03-Instalar-slurm-mestre.sh

# Execute o script 04 APENAS nos nós de Computação
sudo ./04-Instalar-slurm-no-computacao.sh

# Execute o script 05 em TODOS os nós
sudo ./05-Compilar-openmpi.sh
```

## 🏁 Conclusão

O uso destes scripts elimina a necessidade de digitar centenas de comandos manualmente, o que reduz drasticamente o tempo de instalação e a chance de erros de digitação. No entanto, eles ainda exigem um administrador para prepará-los, fornecer as senhas iniciais e supervisionar o processo.
