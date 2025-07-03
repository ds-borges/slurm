#!/bin/bash
# Guia: 05-compilar-openmpi
# Objetivo: Compilar e instalar o Open MPI com integração com o Slurm.

# --- VERSÃO CORRIGIDA PARA 4.1.5 ---
VERSION="4.1.5"
INSTALL_PREFIX="/opt/openmpi-${VERSION}"
TARBALL="openmpi-${VERSION}.tar.gz"

# --- 1. DOWNLOAD E DESCOMPACTAÇÃO ---
echo "Baixando e descompactando Open MPI ${VERSION}..."
if [ ! -f "$TARBALL" ]; then
    # O link de download para a versão 4.1.5
    wget "https://download.open-mpi.org/release/open-mpi/v4.1/$TARBALL"
fi
tar -xzf "$TARBALL"
cd "openmpi-${VERSION}"

# --- 2. CONFIGURAÇÃO, COMPILAÇÃO E INSTALAÇÃO ---
echo "Configurando, compilando e instalando Open MPI..."
# As flags são as mesmas e compatíveis com a versão 4.1.5 
./configure --prefix=${INSTALL_PREFIX} --with-pmix --with-slurm --with-pmi
make -j $(nproc) all
sudo make install

# --- 3. CONFIGURAÇÃO DO AMBIENTE ---
echo "Configurando variáveis de ambiente no /etc/profile.d para todos os usuários..."
sudo tee "/etc/profile.d/openmpi.sh" > /dev/null <<EOT
export MPI_HOME=${INSTALL_PREFIX}
export PATH="\$MPI_HOME/bin:\$PATH"
export LD_LIBRARY_PATH="\$MPI_HOME/lib:\$LD_LIBRARY_PATH"
EOT


echo "Open MPI ${VERSION} instalado com sucesso. Abra um novo terminal para usar."

# Verificação
source /etc/profile.d/openmpi.sh
mpirun --version