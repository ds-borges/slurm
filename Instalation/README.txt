============================================================
GUIA GERAL DO PROJETO DE INSTALAÇÃO DO CLUSTER SLURM
============================================================

Bem-vindo a este projeto de instalação e configuração de um cluster Slurm. O repositório está organizado em três subpastas distintas para oferecer flexibilidade na forma como você aborda a instalação.

Este guia descreve o conteúdo de cada subpasta para que você possa escolher o método que melhor se adapta às suas necessidades.


--- ESTRUTURA DAS SUBPASTAS ---

**1. Subpasta: `Arquivos do Slurm/`**

* **Conteúdo:** Esta pasta contém todos os arquivos de configuração finais e funcionais do Slurm, como `slurm.conf`, `slurmdbd.conf`, `cgroup.conf`, e os scripts de energia `resume.sh` e `suspend.sh`.
* **Uso:** Estes são os arquivos "modelo" que devem ser utilizados como a configuração final do cluster. Dentro desta pasta, há um `README_Tecnico.txt` que detalha todas as alterações necessárias para adaptar estes arquivos a um novo ambiente de hardware (novos IPs, nós, senhas, etc.).
* **IMPORTANTE:** Os arquivos de configuração nesta pasta são universais. Eles devem ser usados independentemente de você escolher o método de instalação manual (pasta `Comandos`) ou o método por scripts (pasta `Script`).


**2. Subpasta: `Comandos/`**

* **Conteúdo:** Contém cinco arquivos de texto (`.txt`), cada um com uma lista de comandos para uma etapa específica da instalação (Ambiente Base, Munge, Slurm Mestre, etc.).
* **Uso:** Este método é ideal para quem deseja realizar uma instalação **manual e controlada**, executando e verificando cada bloco de comandos passo a passo. É excelente para fins de aprendizado ou para depurar problemas em uma etapa específica. A pasta inclui um `README.txt` que descreve o objetivo de cada um dos cinco arquivos.


**3. Subpasta: `Script/`**

* **Conteúdo:** Contém cinco arquivos de script executáveis (`.sh`) que automatizam a execução dos comandos de cada etapa da instalação.
* **Uso:** Este método é ideal para quem busca uma instalação **semi-automática** mais rápida. Os scripts executam os comandos em sequência, mas ainda exigem intervenção para pontos específicos (como digitar senhas). A pasta inclui um `README.txt` que explica como dar permissão aos scripts e os pontos de intervenção manual.