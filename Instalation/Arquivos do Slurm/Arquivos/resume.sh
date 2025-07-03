#!/bin/bash
#
# /etc/slurm/resume.sh
# Script para "acordar" (resume) nós do Slurm via Wake-on-LAN (etherwake),
# lendo os endereços MAC de um arquivo externo.
#

# -- Início da Configuração --
set -e # Faz o script sair imediatamente se um comando falhar.

# Arquivos de configuração e log
MAC_LIST_FILE="/etc/slurm/mac_addresses.list"
LOG_FILE="/var/log/slurm/power_save.log"

# A interface de rede a partir da qual o "magic packet" será enviado.
# Use o comando 'ip a' ou 'ifconfig' no seu nó de controle para encontrar o nome correto.
WOL_INTERFACE="enp2s0"

# -- Fim da Configuração --


# Função para registrar mensagens no arquivo de log
log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [RESUME] - $1" >> "${LOG_FILE}"
}


# --- Início da Execução ---

log_msg "Iniciando execução. Argumento recebido do Slurm: $1"

# Verifica se o Slurm passou um argumento.
if [[ -z "$1" ]]; then
    log_msg "ERRO: Nenhum nome de nó recebido do Slurm. Saindo."
    exit 1
fi

# Expande a hostlist do Slurm para nomes de nós individuais.
HOSTS_TO_RESUME=$(scontrol show hostnames "$1")
log_msg "Nós a serem reativados: ${HOSTS_TO_RESUME}"

for node in ${HOSTS_TO_RESUME}; do
    log_msg "Processando nó: ${node}"

    # Extrai o endereço MAC do arquivo, procurando pela correspondência exata do nome do nó.
    MAC_ADDRESS=$(grep -w "${node}" "${MAC_LIST_FILE}" | awk '{print $2}')

    # Verifica se um endereço MAC foi encontrado
    if [[ -n "${MAC_ADDRESS}" ]]; then
        log_msg "MAC encontrado para ${node}: ${MAC_ADDRESS}. Tentando enviar Wake-on-LAN via interface ${WOL_INTERFACE}."

        # Comando para enviar o "magic packet".
        # Verificamos se o comando falha para reportar ao Slurm.
        if ! sudo /usr/sbin/etherwake -i "${WOL_INTERFACE}" "${MAC_ADDRESS}" &>> "${LOG_FILE}"; then
            log_msg "ERRO: O comando etherwake falhou para o nó ${node} (MAC: ${MAC_ADDRESS}). Verifique o log."
            exit 1
        else
            log_msg "Sucesso: Pacote Wake-on-LAN enviado para o nó ${node}."
        fi
    else
        # Se o nó não foi encontrado no arquivo de MACs, registra um erro e sai.
        log_msg "ERRO: Nó ${node} não encontrado no arquivo ${MAC_LIST_FILE}. Impossível reativar."
        exit 1
    fi
done

log_msg "Finalizado com sucesso. Pacotes de reativação enviados para todos os nós solicitados."
exit 0
