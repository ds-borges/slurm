#!/bin/bash
#
# /etc/slurm/suspend.sh
# Script para suspender nós do Slurm via SSH com systemctl.
#

# -- Início da Configuração --

# Use 'set -e' para que o script saia imediatamente se um comando falhar.
set -e

# Arquivo de log. O usuário 'slurm' deve ter permissão de escrita.
LOG_FILE="/var/log/slurm/power_save.log"

# -- Fim da Configuração --


# Função para registrar mensagens com data e hora no arquivo de log
log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [SUSPEND] - $1" >> "${LOG_FILE}"
}

# --- Início da Execução ---

log_msg "Iniciando execução. Argumento recebido do Slurm: $1"

# Verifica se o Slurm passou um argumento. Se não, sai com erro.
if [[ -z "$1" ]]; then
    log_msg "ERRO: Nenhum nome de nó recebido do Slurm. Saindo."
    exit 1
fi

# Usa scontrol para expandir a hostlist do Slurm em nomes de nós individuais.
# Este é o método correto para processar o argumento $1.
HOSTS_TO_SUSPEND=$(scontrol show hostnames "$1")
log_msg "Nós a serem suspensos: ${HOSTS_TO_SUSPEND}"

# Itera sobre cada nome de nó expandido
for node in ${HOSTS_TO_SUSPEND}; do
    log_msg "Tentando suspender o nó: ${node}"

    # Comando para suspender via SSH.
    # A saída de erro do SSH (stderr) também será redirecionada para o log.
    # Usamos 'if !' para verificar se o comando ssh falhou.
    if ! ssh -o ConnectTimeout=10 slurm@${node} "sudo /sbin/poweroff " &>> "${LOG_FILE}"; then
        # Se o comando ssh falhou (ex: falha na conexão, permissão negada no sudo), registre o erro e saia.
        log_msg "ERRO: Falha ao executar o comando de suspensão no nó ${node}. Verifique a conectividade e as permissões do sudo."
        # Sair com status 1 informa ao Slurm que a operação de suspensão falhou.
        exit 1
    else
        # Se o comando foi bem-sucedido, registre o sucesso.
        log_msg "Sucesso: Comando de suspensão enviado para o nó ${node}."
    fi
done

log_msg "Finalizado com sucesso. Todos os nós solicitados foram suspensos."

# Saia com 0 para indicar ao Slurm que tudo ocorreu bem.
exit 0
