# Guia de Instalação de Cluster Slurm

![Plataforma](https://img.shields.io/badge/Plataforma-Linux-green.svg)
![Gerenciador](https://img.shields.io/badge/Gerenciador-Slurm-blue.svg)
![Linguagem](https://img.shields.io/badge/Scripts-Bash-orange.svg)

Bem-vindo a este projeto de instalação e configuração de um cluster com o Slurm Workload Manager. Este repositório está organizado para oferecer flexibilidade, permitindo que você escolha o método de instalação que melhor se adapta às suas necessidades.

## 📁 Estrutura do Repositório

O projeto é dividido em três subpastas principais, cada uma com um propósito específico.

### 1. `Arquivos do Slurm/`
Esta pasta contém os arquivos de configuração finalizados e prontos para serem adaptados.

* **Conteúdo**: Inclui os arquivos essenciais como `slurm.conf`, `slurmdbd.conf`, `cgroup.conf` e os scripts de gerenciamento de energia (`resume.sh`, `suspend.sh`).
* **Uso**: Funciona como um conjunto de "modelos" universais para a configuração final do cluster. Estes arquivos devem ser utilizados independentemente do método de instalação escolhido (manual ou via script).
* **Adaptação**: Contém um `LEIAme.md` que serve como um guia detalhado para customizar os arquivos (ajustar IPs, nomes dos nós, senhas, etc.) para o seu ambiente específico.

### 2. `Comandos/`
Esta pasta oferece uma abordagem de instalação manual e detalhada.

* **Conteúdo**: Cinco arquivos `.txt`, cada um contendo uma lista de comandos para uma etapa específica da instalação (ex: Ambiente Base, Munge, Slurm Mestre).
* **Uso**: Ideal para quem deseja realizar uma instalação **manual e controlada**, executando e validando cada comando passo a passo. É uma excelente abordagem para fins de aprendizado ou para depurar problemas em etapas específicas do processo.
* **Guia**: Inclui um `LEIAme.md` que explica o objetivo de cada um dos cinco arquivos de comandos.

### 3. `Script/`
Esta pasta oferece uma abordagem de instalação mais rápida e automatizada.

* **Conteúdo**: Cinco scripts executáveis (`.sh`) que automatizam a execução dos comandos de cada etapa da instalação.
* **Uso**: Ideal para quem busca uma instalação **semi-automática** e mais ágil. Os scripts ainda exigem intervenção manual em pontos específicos, como a digitação de senhas.
* **Guia**: Inclui um `LEIAme.md` que detalha como conceder permissões de execução aos scripts e aponta os momentos que exigem intervenção do usuário.

## 🤔 Qual Método Escolher?

* **Opção 1: Instalação Manual (`Comandos/`)**
    * **Vantagem**: Controle total sobre o processo, ideal para entender cada detalhe da instalação e para solucionar problemas de forma granular.

* **Opção 2: Instalação Semi-Automática (`Script/`)**
    * **Vantagem**: Maior velocidade e conveniência, automatizando tarefas repetitivas.

## 🚀 Começando

1.  **Configure os Arquivos Base**: Antes de tudo, vá para a pasta `Arquivos do Slurm/`. Leia o `LEIAme.md` e edite os arquivos de configuração (`.conf`) para que correspondam ao hardware e à rede do seu cluster.
2.  **Escolha seu Método**: Decida se prefere a instalação manual (`Comandos/`) ou a semi-automática (`Script.
3.  **Siga as Instruções**: Navegue até a pasta escolhida e siga as instruções contidas no `LEIAme.md` local para iniciar a instalação.