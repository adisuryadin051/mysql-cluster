
#!/bin/bash

# ==========================================================
# KONFIGURASI (Ubah NODE_NAME sesuai server yang dipakai)
# ==========================================================
NODE_NAME="cluster-1"  # Ganti jadi cluster-2, cluster-3 di server lain
REPO_URL="https://github.com/adisuryadin051/mysql-cluster.git"
BACKUP_DIR="/root/mysql-cluster"

GIT_NAME="Adi Suryadin"
GIT_EMAIL="adisuryadin051@email.com"

echo "=== Memulai Backup MySQL Cluster: $NODE_NAME ==="

# 1. Siapkan Struktur Folder
mkdir -p $BACKUP_DIR/$NODE_NAME/mysql
mkdir -p $BACKUP_DIR/$NODE_NAME/haproxy
mkdir -p $BACKUP_DIR/$NODE_NAME/keepalived
mkdir -p $BACKUP_DIR/$NODE_NAME/system

# 2. Ambil File Konfigurasi
cp /etc/mysql/mysql.conf.d/mysqld.cnf $BACKUP_DIR/$NODE_NAME/mysql/ 2>/dev/null
cp /etc/haproxy/haproxy.cfg $BACKUP_DIR/$NODE_NAME/haproxy/ 2>/dev/null
cp /etc/keepalived/keepalived.conf $BACKUP_DIR/$NODE_NAME/keepalived/ 2>/dev/null
cp /etc/hosts $BACKUP_DIR/$NODE_NAME/system/ 2>/dev/null

# 3. Sinkronisasi dengan GitHub
cd $BACKUP_DIR || exit

# Set Identitas Git
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

# Inisialisasi jika belum ada
if [ ! -d ".git" ]; then
    git init
    git branch -M main
    git remote add origin $REPO_URL
fi

# Tarik data terbaru dari GitHub (PENTING agar tidak rejected)
echo "[*] Sinkronisasi data dari GitHub..."
git pull origin main --allow-unrelated-histories --no-rebase > /dev/null 2>&1

# Tambah, Commit, dan Push
git add .
if git commit -m "Auto-backup MySQL $NODE_NAME pada $(date +'%Y-%m-%d %H:%M:%S')"; then
    echo "[*] Mengirim perubahan ke GitHub..."
    git push origin main
else
    echo "[!] Tidak ada perubahan data. Skip push."
fi

echo "=== Selesai Backup MySQL ==="
