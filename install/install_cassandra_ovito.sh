#!/usr/bin/env bash
set -e

# ============================================================
# Instalação do Cassandra + OVITO Basic no Ubuntu
#
# - Usa Conda existente, se disponível.
# - Caso contrário, instala Miniforge em ~/miniforge3.
# - Cria um único ambiente Conda chamado "cassandra".
# - Instala Cassandra e OVITO Basic no mesmo ambiente.
#
# Uso:
#   chmod +x install_cassandra_ovito.sh
#   ./install_cassandra_ovito.sh
# ============================================================

ENV_NAME="cassandra"
OVITO_VERSION="3.16.1"
MINIFORGE_DIR="$HOME/miniforge3"

echo "======================================"
echo " Instalando Cassandra + OVITO"
echo "======================================"
echo

# ------------------------------------------------------------
# 1. Procurar Conda
# ------------------------------------------------------------

echo "[1/4] Procurando Conda..."

if command -v conda >/dev/null 2>&1; then
    CONDA="$(command -v conda)"

elif [ -x "$MINIFORGE_DIR/bin/conda" ]; then
    CONDA="$MINIFORGE_DIR/bin/conda"

elif [ -x "$HOME/miniconda3/bin/conda" ]; then
    CONDA="$HOME/miniconda3/bin/conda"

elif [ -x "$HOME/anaconda3/bin/conda" ]; then
    CONDA="$HOME/anaconda3/bin/conda"

else
    CONDA=""
fi

# ------------------------------------------------------------
# 2. Instalar Miniforge, se necessário
# ------------------------------------------------------------

if [ -z "$CONDA" ]; then

    echo
    echo "[2/4] Conda não encontrado. Instalando Miniforge..."

    sudo apt update
    sudo apt install -y curl

    ARCH=$(uname -m)
    INSTALLER="/tmp/Miniforge3.sh"

    curl -L \
        "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-${ARCH}.sh" \
        -o "$INSTALLER"

    bash "$INSTALLER" -b -p "$MINIFORGE_DIR"
    rm -f "$INSTALLER"

    CONDA="$MINIFORGE_DIR/bin/conda"

    "$CONDA" init bash
    "$CONDA" config --set auto_activate_base false

    echo
    echo "Miniforge instalado em:"
    echo "  $MINIFORGE_DIR"

else
    echo "Conda encontrado:"
    echo "  $CONDA"
fi

echo
"$CONDA" --version

# ------------------------------------------------------------
# 3. Instalar Cassandra + OVITO no mesmo ambiente
# ------------------------------------------------------------

echo
echo "[3/4] Instalando Cassandra + OVITO no ambiente '$ENV_NAME'..."

# Bibliotecas gráficas úteis para OVITO em máquinas sem GPU dedicada
sudo apt update
sudo apt install -y \
    libvulkan1 \
    mesa-vulkan-drivers

if "$CONDA" env list | awk '{print $1}' | grep -qx "$ENV_NAME"; then

    echo "Ambiente '$ENV_NAME' já existe."
    echo "Atualizando/instalando Cassandra + OVITO..."

    "$CONDA" install -y \
        -n "$ENV_NAME" \
        -c conda-forge \
        cassandra \
        "ovito=$OVITO_VERSION"

else

    "$CONDA" create -y \
        -n "$ENV_NAME" \
        -c conda-forge \
        cassandra \
        "ovito=$OVITO_VERSION"
fi

# ------------------------------------------------------------
# 4. Verificação
# ------------------------------------------------------------

echo
echo "[4/4] Verificando a instalação..."
echo

echo "Cassandra:"
"$CONDA" run -n "$ENV_NAME" which cassandra.exe
"$CONDA" run -n "$ENV_NAME" which mcfgen.py
"$CONDA" run -n "$ENV_NAME" which library_setup.py

echo
echo "OVITO:"
"$CONDA" run -n "$ENV_NAME" which ovito

echo
echo "======================================"
echo " Instalação concluída!"
echo "======================================"
echo
echo "Para usar Cassandra e OVITO:"
echo
echo "  conda activate $ENV_NAME"
echo
echo "Depois:"
echo
echo "  cassandra.exe"
echo "  ovito"
echo
echo "Para usar 6 threads no Cassandra:"
echo
echo "  export OMP_NUM_THREADS=6"
echo "  cassandra.exe"
echo
echo "Se o Miniforge foi instalado agora, abra um novo terminal"
echo "antes de executar 'conda activate $ENV_NAME'."
