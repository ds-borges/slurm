#!/bin/bash
# Guia: 01-configurar-ambiente-base
# Objetivo: Preparar o ambiente base com rede, tempo (NTP),
#           compartilhamento de arquivos (NFS) e SSH sem senha.

# --- 1. RESOLUÇÃO DE NOMES (EXECUTAR EM TODOS OS NÓS) ---
# Edite este arquivo para que todos os nós saibam os IPs dos outros.
# É crucial que o nome (ex: "Master", "Node01") corresponda ao comando 'hostname'.
echo "Configurando /etc/hosts..."
sudo tee -a /etc/hosts > /dev/null <<EOT

# Mapeamento do Cluster Slurm
192.168.1.99     Master    # IP do Nó Mestre/Controlador
192.168.1.1      Node01    # IP do Nó de Computação 1
192.168.1.2      Node02    # IP do Nó de Computação 2
192.168.1.3      Node03    # IP do Nó de Computação 3
# Adicione mais nós aqui conforme necessário
EOT

# --- 2. SINCRONIZAÇÃO DE TEMPO COM CHRONY (EXECUTAR EM TODOS OS NÓS) ---
echo "Instalando e configurando Chrony para sincronização de tempo..."
sudo apt-get update
sudo apt-get install -y chrony
sudo systemctl enable --now chrony
echo "Aguardando a sincronização inicial do tempo..."
sleep 10 # Pequena pausa para o chrony iniciar
chronyc sources

# --- 3. CONFIGURAÇÃO DO NFS ---

# 3.1 NO NÓ MESTRE (Servidor NFS)
if [[ $(hostname) == "Master" ]]; then
  echo "Configurando o servidor NFS no Master..."
  sudo apt-get install -y nfs-server
  sudo mkdir -p /nfs/execution /nfs/return /nfs/configuration /nfs/slurm
  sudo chown root:root /nfs
  sudo chmod 755 /nfs /nfs/configuration /nfs/execution
  sudo chmod 777 /nfs/return
  
  # A rede no /etc/exports foi atualizada para 192.168.1.0/24
  sudo tee /etc/exports > /dev/null <<EOT
/nfs 192.168.1.0/24(rw,sync,no_subtree_check,all_squash)
EOT
 
  sudo exportfs -ra
  sudo systemctl restart nfs-server
fi

# 3.2 NOS NÓS DE COMPUTAÇÃO (Clientes NFS)
if [[ $(hostname) != "Master" ]]; then
  echo "Configurando o cliente NFS no $(hostname)..."
  sudo apt-get install -y nfs-client
  sudo mkdir -p /nfs
  # Monta o diretório do IP do Mestre
  sudo mount 192.168.1.99:/nfs/ /nfs/
  
  # Torna a montagem permanente
  sudo tee -a /etc/fstab > /dev/null <<EOT
Master:/nfs /nfs nfs defaults 0 0
EOT
 
fi

# --- 4. CONFIGURAÇÃO DE SSH SEM SENHA (EXECUTAR EM TODOS OS NÓS) ---
echo "Configurando SSH sem senha..."
# Gera a chave se não existir
[ -f ~/.ssh/id_rsa ] || ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

# Copia a chave para todos os nós do cluster (requer senha na primeira vez)
# Lista de nós atualizada
NODES=("Master" "Node01" "Node02" "Node03")
for node in "${NODES[@]}"; do
    echo "Copiando chave para $node..."
    ssh-copy-id "$USER@$node"
done

echo "Ambiente base configurado com sucesso!"