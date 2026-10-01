#!/usr/bin/env bash
set -e

# ============================================================
# Instalação do LAMMPS + WHAM no Ubuntu
# Uso: chmod +x install_lammps_wham.sh
#      ./install_lammps_wham.sh
# ============================================================

LAMMPS_REF="patch_2Sep2026"
WHAM_REF="main"
NPROC=$(nproc)

BUILD_DIR="$HOME/.cache/lammps_wham_build"

echo "======================================"
echo " Instalando LAMMPS + WHAM"
echo "======================================"
echo "Núcleos disponíveis: $NPROC"
echo

# ------------------------------------------------------------
# 1. Dependências
# ------------------------------------------------------------

echo "[1/5] Instalando dependências..."

sudo apt update
sudo apt install -y \
    build-essential \
    cmake \
    git \
    openmpi-bin \
    libopenmpi-dev \
    libfftw3-dev

# Diretório temporário de compilação
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# ------------------------------------------------------------
# 2. LAMMPS
# ------------------------------------------------------------

echo
echo "[2/5] Baixando e configurando o LAMMPS..."

git clone --depth 1 --branch "$LAMMPS_REF" \
    https://github.com/lammps/lammps.git

cd lammps

cmake -S cmake -B build \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D BUILD_MPI=on \
    -D BUILD_OMP=on \
    -D FFT=FFTW3 \
    -D PKG_OPENMP=on \
    -D PKG_MOLECULE=on \
    -D PKG_KSPACE=on \
    -D PKG_RIGID=on \
    -D PKG_MC=on \
    -D PKG_COLVARS=on \
    -D PKG_LEPTON=on

echo
echo "[3/5] Compilando e instalando o LAMMPS..."

cmake --build build --parallel "$NPROC"
sudo cmake --install build
sudo ldconfig

# ------------------------------------------------------------
# 3. WHAM
# ------------------------------------------------------------

echo
echo "[4/5] Baixando e instalando o WHAM..."

cd "$BUILD_DIR"

git clone --depth 1 --branch "$WHAM_REF" \
    https://github.com/agrossfield/wham.git

cd wham

cmake -S . -B build \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=/usr/local

cmake --build build --parallel "$NPROC"
sudo cmake --install build

# ------------------------------------------------------------
# 4. Verificação
# ------------------------------------------------------------

echo
echo "[5/5] Verificando a instalação..."
echo

echo "LAMMPS:"
which lmp
lmp -h | head -n 6

echo
echo "Pacotes importantes:"
lmp -h | grep -E "COLVARS|LEPTON|MOLECULE|KSPACE|RIGID|MC|OPENMP"

echo
echo "MPI:"
mpirun --version | head -n 1

echo
echo "WHAM:"
which wham
which wham-2d

echo
echo "======================================"
echo " Instalação concluída!"
echo "======================================"
echo
echo "Teste do LAMMPS:"
echo "  lmp -h"
echo
echo "Exemplo com todos os núcleos:"
echo "  mpirun -np $NPROC lmp -in input.lmp"
echo
echo "WHAM:"
echo "  wham"
echo "  wham-2d"
