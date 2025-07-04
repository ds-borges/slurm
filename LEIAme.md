# Repositório de Instalação e Testes de Cluster Slurm

![Gerenciador](https://img.shields.io/badge/Gerenciador-Slurm-blue.svg)
![Paralelismo](https://img.shields.io/badge/Paralelismo-Open%20MPI-orange.svg)
![Linguagem](https://img.shields.io/badge/Linguagem-C%20%7C%20Bash-yellow.svg)
![Plataforma](https://img.shields.io/badge/Plataforma-Linux-green.svg)

Bem-vindo a este repositório, cujo principal objetivo é **auxiliar na implementação de um cluster com Slurm**, desde a criação e configuração até a validação funcional. O conteúdo está organizado para ser um guia completo para a construção de um ambiente de computação de alto desempenho (HPC), dividido em duas seções principais: **Instalação** e **Testes**.

## 📁 Estrutura do Repositório

O conteúdo está organizado em duas pastas principais para facilitar o uso:

### 1. `/Instalation`
Esta pasta contém tudo o que você precisa para construir um cluster Slurm funcional do zero. Dentro dela, você encontrará três abordagens diferentes, cada uma com sua própria documentação detalhada:

* **`/Arquivos do Slurm`**: Contém os arquivos de configuração finalizados (`slurm.conf`, `cgroup.conf`, `slurmdbd.conf`, etc.). Eles servem como modelos que devem ser customizados para o seu ambiente antes da instalação. Consulte o `README.md` técnico dentro desta pasta para um guia de customização.
* **`/Comandos`**: Oferece um guia para a **instalação manual** do cluster. É a abordagem ideal para quem deseja aprender cada etapa do processo e ter controle total.
* **`/Script`**: Oferece scripts para uma **instalação semi-automática**. Esta abordagem é mais rápida e reduz a chance de erros, mas ainda exige a intervenção do administrador em pontos-chave.

### 2. `/Tests`
Após a instalação bem-sucedida do cluster, esta pasta oferece os recursos para validar seu funcionamento.

* **Objetivo**: Verificar se o cluster está operacional, se os jobs são submetidos corretamente e se o ambiente de computação paralela (MPI) está funcionando como esperado.
* **Conteúdo**: Inclui um exemplo de código em C com MPI para **calcular o valor de Pi** usando o método de Monte Carlo. Este é um teste clássico de HPC que utiliza múltiplos nós para realizar um cálculo intensivo.
* **Instruções**: Dentro desta pasta, você encontrará um `README.md` com instruções detalhadas sobre como compilar e executar o teste de validação no seu novo cluster.

## 🚀 Como Usar Este Repositório

Siga este fluxo de trabalho para obter os melhores resultados:

1.  **Comece pela Instalação**: Navegue até a pasta `/Instalation` para iniciar a construção do seu cluster.
2.  **Escolha seu Método**: Decida entre a abordagem manual (`/Comandos`) ou a semi-automática (`/Script`) e siga as instruções do `README.md` correspondente.
3.  **Valide o Cluster**: Uma vez que o cluster esteja online e os serviços do Slurm estejam rodando, vá para a pasta `/Tests`.
4.  **Execute o Teste**: Siga as instruções para executar o programa de cálculo de Pi. Um resultado bem-sucedido confirma que seu cluster está pronto para processar trabalhos de alto desempenho.
