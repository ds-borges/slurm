#!/bin/bash
# Guia: 04-instalar-slurm-no-computacao
# Objetivo: Instalar e configurar o daemon do Slurm (slurmd).

# --- 1. INSTALAÇÃO ---
echo "Instalando pacotes do Slurm..."
[cite_start]sudo apt-get install -y slurm-wlm [cite: 2]

# --- 2. CONFIGURAÇÃO ---
echo "Copiando arquivos de configuração do NFS..."
[cite_start]sudo cp /nfs/slurm/slurm.conf /etc/slurm/ [cite: 3]
[cite_start]sudo cp /nfs/slurm/slurmdbd.conf /etc/slurm/ [cite: 3]

# --- 3. CRIAÇÃO DE DIRETÓRIOS ---
echo "Criando diretórios e definindo permissões..."
[cite_start]sudo mkdir -p /var/spool/slurmd /var/log/slurm /var/run/slurm [cite: 3, 6]
[cite_start]sudo chown slurm:slurm /var/spool/slurmd [cite: 3]
[cite_start]sudo chmod 755 /var/spool/slurmd [cite: 3]
[cite_start]sudo touch /var/log/slurm/slurmd.log [cite: 3]
[cite_start]sudo chown slurm:slurm /var/log/slurm/slurmd.log [cite: 3]

# --- 4. DEPENDÊNCIAS E INICIALIZAÇÃO ---
echo "Configurando dependência de tempo para o slurmd..."
sudo systemctl edit slurmd.service <<EOF
[Unit]
Wants=chrony-wait.service
After=chrony-wait.service
EOF
[cite_start][cite: 1]

echo "Iniciando serviço do nó de computação..."
sudo systemctl daemon-reload
[cite_start]sudo systemctl enable slurmd [cite: 8]
[cite_start]sudo systemctl restart slurmd [cite: 9]

# Verificação final
sleep 5
[cite_start]sudo systemctl status slurmd [cite: 3]
echo "Nó de computação configurado."