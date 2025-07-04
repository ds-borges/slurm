#!/bin/bash
# Guia: 02-instalar-munge
# Objetivo: Instalar, configurar e proteger o Munge.

# --- 1. INSTALAÇÃO DE DEPENDÊNCIAS E CRIAÇÃO DE USUÁRIOS ---
echo "Instalando dependências e criando usuários munge/slurm..."
[cite_start]sudo apt-get install -y munge libpam0g-dev libmariadb-client-lgpl-dev [cite: 4]

export MUNGEUSER=1001
[cite_start]sudo groupadd -g $MUNGEUSER munge [cite: 10]
[cite_start]sudo useradd -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u $MUNGEUSER -g munge -s /sbin/nologin munge [cite: 10]

export SLURMUSER=1002
[cite_start]sudo groupadd -g $SLURMUSER slurm [cite: 10]
[cite_start]sudo useradd -m -c "SLURM workload manager" -d /var/lib/slurm -u $SLURMUSER -g slurm -s /bin/bash slurm [cite: 10]

# --- 2. GERAÇÃO E DISTRIBUIÇÃO DA CHAVE MUNGE ---
# Gera a chave apenas no Mestre e a copia para o NFS
if [[ $(hostname) == "Master" ]]; then
    echo "Gerando chave munge no Master..."
    [cite_start]sudo /usr/sbin/mungekey [cite: 4]
    [cite_start]sudo cp /etc/munge/munge.key /nfs/configuration/munge.key [cite: 10]
    sudo chown $USER:$USER /nfs/configuration/munge.key
fi

# Garante que todos os nós aguardem a chave existir no NFS
while [ ! -f /nfs/configuration/munge.key ]; do
  echo "Aguardando a munge.key ser criada no NFS..."
  sleep 5
done

# Todos os nós copiam a chave do NFS
echo "Copiando munge.key do NFS..."
[cite_start]sudo cp /nfs/configuration/munge.key /etc/munge/munge.key [cite: 2]

# --- 3. CONFIGURAÇÃO DE PERMISSÕES E DEPENDÊNCIAS ---
echo "Definindo permissões do Munge..."
[cite_start]sudo chown munge:munge /etc/munge/munge.key [cite: 2]
[cite_start]sudo chmod 400 /etc/munge/munge.key [cite: 2, 5]
[cite_start]sudo chown -R munge: /etc/munge/ /var/log/munge/ [cite: 5]
[cite_start]sudo chmod 0700 /etc/munge/ /var/log/munge/ [cite: 5]

echo "Configurando o Munge para aguardar o tempo estar sincronizado..."
sudo systemctl edit munge.service <<EOF
[Unit]
Wants=chrony-wait.service
After=chrony-wait.service
EOF
[cite_start][cite: 1]

# --- 4. INICIALIZAÇÃO E VERIFICAÇÃO ---
echo "Iniciando e habilitando o serviço Munge..."
[cite_start]sudo systemctl daemon-reload [cite: 1]
[cite_start]sudo systemctl enable munge [cite: 5]
[cite_start]sudo systemctl restart munge [cite: 6]
[cite_start]sudo systemctl status munge [cite: 6]

echo "Verificando a funcionalidade do Munge..."
munge -n | unmunge

# Do Mestre, teste a conexão com os nós de computação
if [[ $(hostname) == "Master" ]]; then
    echo "Testando Munge a partir do Master para o Node01..."
    ssh Node01 "munge -n | unmunge"
fi

echo "Munge instalado e configurado."