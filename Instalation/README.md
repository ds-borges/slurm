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
* **Uso**: Funciona como um conjunto de "modelos" universais para a configuração final do cluster. Estes arquivos devem ser utilizados independentemente do método de instalação escolhido (manual ou via