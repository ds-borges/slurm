#!/bin/bash
# Guia: 03-instalar-slurm-mestre
# Objetivo: Instalar e configurar o controlador do Slurm (slurmctld, slurmdbd).

# --- 1. INSTALAÇÃO DOS PACOTES E BANCO DE DADOS ---
echo "Instalando pacotes do controlador Slurm e MariaDB..."
sudo apt-get install -y mariadb-server slurm-wlm slurmdbd

# --- 2. CONFIGURAÇÃO DO BANCO DE DADOS ---
echo "Configurando banco de dados slurm_acct_db..."
sudo mysql <<EOF
CREATE DATABASE slurm_acct_db;
GRANT ALL ON slurm_acct_db.* TO 'slurm'@'localhost' IDENTIFIED BY 'bccufj07' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF


# --- 3. CRIAÇÃO DOS ARQUIVOS DE CONFIGURAÇÃO ---
echo "Criando slurmdbd.conf..."
sudo tee /etc/slurm/slurmdbd.conf > /dev/null <<EOT
AuthType=auth/munge
DbdHost=localhost
DbdPort=6819
SlurmUser=slurm
LogFile=/var/log/slurm/slurmdbd.log
PidFile=/run/slurm/slurmdbd.pid
StorageType=accounting_storage/mysql
StorageHost=localhost
StoragePass=bccufj07 # Senha definida no passo anterior
StorageUser=slurm
StorageLoc=slurm_acct_db
EOT


sudo chown slurm:slurm /etc/slurm/slurmdbd.conf
sudo chmod 600 /etc/slurm/slurmdbd.conf

echo "Criando um slurm.conf de exemplo (use o configurator online para uma versão completa)..."
# É altamente recomendado usar https://slurm.schedmd.com/configurator.html
# Este é um exemplo MÍNIMO com a lista de nós atualizada.
sudo tee /etc/slurm/slurm.conf > /dev/null <<EOT
# slurm.conf gerado para um cluster de exemplo
ClusterName=cluster
SlurmctldHost=Master
#
# DEFINIÇÕES DE LOG E PID
SlurmctldPidFile=/run/slurm/slurmctld.pid
SlurmdPidFile=/run/slurm/slurmd.pid
SlurmdLogFile=/var/log/slurm/slurmd.log
SlurmctldLogFile=/var/log/slurm/slurmctld.log
#
# NÓS DE COMPUTAÇÃO
NodeName=Node01 CPUs=2 State=UNKNOWN
NodeName=Node02 CPUs=2 State=UNKNOWN
NodeName=Node03 CPUs=2 State=UNKNOWN
#
# PARTIÇÕES
PartitionName=debug Nodes=Node01,Node02,Node03 Default=YES MaxTime=INFINITE State=UP
EOT

# Copia as configurações para o NFS para os nós de computação usarem
sudo cp /etc/slurm/slurm.conf /nfs/slurm/
sudo cp /etc/slurm/slurmdbd.conf /nfs/slurm/

# --- 4. CRIAÇÃO DE DIRETÓRIOS E PERMISSÕES ---
echo "Criando diretórios e definindo permissões..."
sudo mkdir -p /var/spool/slurmctld /var/log/slurm /var/run/slurm
sudo chown slurm:slurm /var/spool/slurmctld /var/log/slurm /var/run/slurm
sudo touch /var/log/slurm/slurmctld.log
sudo chown slurm:slurm /var/log/slurm/slurmctld.log

# --- 5. CONFIGURAÇÃO DE DEPENDÊNCIAS E INICIALIZAÇÃO ---
echo "Configurando dependências de tempo para os serviços do mestre..."
sudo systemctl edit slurmdbd.service <<EOF
[Unit]
Wants=chrony-wait.service
After=chrony-wait.service
EOF

sudo systemctl edit slurmctld.service <<EOF
[Unit]
Wants=chrony-wait.service
After=chrony-wait.service
EOF


echo "Iniciando serviços do controlador Slurm..."
sudo systemctl daemon-reload
sudo systemctl enable slurmdbd
sudo systemctl restart slurmdbd
sudo systemctl enable slurmctld
sudo systemctl restart slurmctld

# Verificação final
sleep 5
sudo systemctl status slurmdbd slurmctld
echo "Nó Mestre configurado."