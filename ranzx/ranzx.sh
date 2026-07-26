#!/bin/bash

# VPS Tools Dashboard v2.0
# Cek spesifikasi & install tools di VPS

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/vps-tools.log"

# Function for loading animation
loading_animation() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    local i=0
    local progress=0
    
    echo -ne "\n${CYAN}▓${NC}"
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        progress=$(( (progress + 1) % 10 ))
        echo -ne "\r${CYAN}▓${NC} ${WHITE}[${NC}"
        for ((j=0; j<10; j++)); do
            if [ $j -lt $progress ]; then
                echo -ne "${GREEN}▓${NC}"
            else
                echo -ne "░"
            fi
        done
        echo -ne "${WHITE}] ${NC}$((progress * 10))%  ${spinstr:$i:1}"
        sleep $delay
    done
    echo -ne "\r${GREEN}▓${NC} ${WHITE}[${GREEN}▓▓▓▓▓▓▓▓▓▓${WHITE}] ${GREEN}100% ✓${NC}\n"
}

# Function for progress bar
progress_bar() {
    local duration=$1
    local steps=20
    local delay=$(echo "scale=2; $duration / $steps" | bc)
    
    echo -ne "\n${CYAN}▓${NC} "
    for ((i=0; i<=steps; i++)); do
        local percent=$((i * 100 / steps))
        local filled=$((i * 50 / steps))
        local empty=$((50 - filled))
        
        printf "\r${CYAN}▓${NC} ${WHITE}[${NC}"
        printf "%${filled}s" | tr ' ' '▓'
        printf "%${empty}s" | tr ' ' '░'
        printf "${WHITE}] ${NC}%3d%%" $percent
        sleep $delay
    done
    echo -e "\n"
}

clear

show_header() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║           🚀 VPS TOOLS DASHBOARD v2.0                 ║"
    echo "║     System Info & Installation Tools 🔧               ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_system_info() {
    clear
    show_header
    
    echo -e "${BLUE}📊 MENGUMPULKAN INFORMASI SISTEM...${NC}"
    progress_bar 2
    
    HOSTNAME=$(hostname)
    OS=$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
    KERNEL=$(uname -r)
    CPU_CORES=$(nproc)
    CPU_MODEL=$(lscpu | grep "Model name" | cut -d':' -f2 | xargs)
    RAM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
    RAM_USED=$(free -h | awk '/^Mem:/ {print $3}')
    RAM_AVAILABLE=$(free -h | awk '/^Mem:/ {print $7}')
    DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
    DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
    DISK_AVAILABLE=$(df -h / | awk 'NR==2 {print $4}')
    UPTIME=$(uptime -p | sed 's/up //')
    SHELL=$(echo $SHELL)
    LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | xargs)
    
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}               ${WHITE}📊 INFORMASI SISTEM${NC}                   ${BLUE}║${NC}"
    echo -e "${BLUE}╠════════════════════════════════════════════════════════╣${NC}"
    
    echo -e "${BLUE}║${NC} ${CYAN}Hostname${NC}        : ${WHITE}${HOSTNAME}${NC}"
    echo -e "${BLUE}║${NC} ${CYAN}OS${NC}              : ${WHITE}${OS}${NC}"
    echo -e "${BLUE}║${NC} ${CYAN}Kernel${NC}          : ${WHITE}${KERNEL}${NC}"
    echo -e "${BLUE}║${NC} ${CYAN}Shell${NC}           : ${WHITE}${SHELL}${NC}"
    echo -e "${BLUE}║${NC} ${CYAN}Load Average${NC}    : ${WHITE}${LOAD_AVG}${NC}"
    
    echo -e "${BLUE}╠════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC}               ${WHITE}💾 HARDWARE INFO${NC}                      ${BLUE}║${NC}"
    echo -e "${BLUE}╠════════════════════════════════════════════════════════╣${NC}"
    
    echo -e "${BLUE}║${NC} ${CYAN}CPU Model${NC}       : ${WHITE}${CPU_MODEL}${NC}"
    echo -e "${BLUE}║${NC} ${CYAN}CPU Cores${NC}       : ${WHITE}${CPU_CORES}${NC}"
    
    # RAM Usage Bar (fixed: integer-safe calc, no bc dependency, guard div-by-zero)
    RAM_PERCENT=$(awk '/^Mem:/ {printf "%.0f", ($3/$2)*100}' <(free))
    [ -z "$RAM_PERCENT" ] && RAM_PERCENT=0
    RAM_FILLED=$((RAM_PERCENT / 2))
    [ "$RAM_FILLED" -gt 50 ] && RAM_FILLED=50
    RAM_EMPTY_LEN=$((50 - RAM_FILLED))
    RAM_BAR=""
    [ "$RAM_FILLED" -gt 0 ] && RAM_BAR=$(printf "%0.s▓" $(seq 1 $RAM_FILLED))
    RAM_EMPTY=""
    [ "$RAM_EMPTY_LEN" -gt 0 ] && RAM_EMPTY=$(printf "%0.s░" $(seq 1 $RAM_EMPTY_LEN))
    echo -e "${BLUE}║${NC} ${CYAN}RAM Usage${NC}       : ${WHITE}${RAM_USED} / ${RAM_TOTAL}${NC}"
    echo -e "${BLUE}║${NC}                     ${WHITE}[${GREEN}${RAM_BAR}${RED}${RAM_EMPTY}${WHITE}] ${YELLOW}${RAM_PERCENT}%${NC}"
    
    # Disk Usage Bar (fixed: guard div-by-zero / overflow)
    DISK_PERCENT=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
    [ -z "$DISK_PERCENT" ] && DISK_PERCENT=0
    DISK_FILLED=$((DISK_PERCENT / 2))
    [ "$DISK_FILLED" -gt 50 ] && DISK_FILLED=50
    DISK_EMPTY_LEN=$((50 - DISK_FILLED))
    DISK_BAR=""
    [ "$DISK_FILLED" -gt 0 ] && DISK_BAR=$(printf "%0.s▓" $(seq 1 $DISK_FILLED))
    DISK_EMPTY=""
    [ "$DISK_EMPTY_LEN" -gt 0 ] && DISK_EMPTY=$(printf "%0.s░" $(seq 1 $DISK_EMPTY_LEN))
    echo -e "${BLUE}║${NC} ${CYAN}Disk Usage${NC}      : ${WHITE}${DISK_USED} / ${DISK_TOTAL}${NC}"
    echo -e "${BLUE}║${NC}                     ${WHITE}[${GREEN}${DISK_BAR}${YELLOW}${DISK_EMPTY}${WHITE}] ${YELLOW}${DISK_PERCENT}%${NC}"
    
    echo -e "${BLUE}╠════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC}               ${WHITE}⏱️  UPTIME${NC}                           ${BLUE}║${NC}"
    echo -e "${BLUE}╠════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC} ${GREEN}${UPTIME}${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "\n${GREEN}✓ VPS Status: RUNNING OPTIMAL ${NC}🟢"
    echo ""
    
    read -p "Tekan ENTER untuk kembali ke menu..."
}

# Function untuk install Nginx (fixed: check exit status instead of always claiming success)
install_nginx() {
    clear
    show_header
    
    echo -e "${CYAN}🌐 INSTALL NGINX WEB SERVER${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Nginx adalah web server yang powerful untuk hosting aplikasi"
    echo ""
    
    echo -e "${YELLOW}Command yang akan dijalankan:${NC}"
    echo ""
    echo -e "${WHITE}1/4${NC} Update package list..."
    echo -e "${CYAN}\$ sudo apt update${NC}"
    echo ""
    echo -e "${WHITE}2/4${NC} Install Nginx..."
    echo -e "${CYAN}\$ sudo apt install -y nginx${NC}"
    echo ""
    echo -e "${WHITE}3/4${NC} Enable and start Nginx..."
    echo -e "${CYAN}\$ sudo systemctl enable nginx${NC}"
    echo -e "${CYAN}\$ sudo systemctl start nginx${NC}"
    echo ""
    echo -e "${WHITE}4/4${NC} Cek status Nginx..."
    echo -e "${CYAN}\$ sudo systemctl status nginx${NC}"
    echo ""
    
    read -p "Mulai instalasi? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}[*] Memulai instalasi Nginx...${NC}"
        
        (
            set -e
            sudo apt update
            sudo apt install -y nginx
            sudo systemctl enable nginx
            sudo systemctl start nginx
        ) &
        pid=$!
        loading_animation $pid
        wait $pid
        status=$?
        
        echo ""
        if [ $status -ne 0 ]; then
            echo -e "${RED}[✗] Instalasi gagal! Cek pesan error di atas.${NC}"
            read -p "Tekan ENTER untuk kembali ke menu..."
            return
        fi
        
        echo -e "${GREEN}[✓] Instalasi selesai!${NC}"
        echo -e "${CYAN}🌐 Nginx version:${NC}"
        nginx -v
        echo ""
        echo -e "${GREEN}✓ Nginx berjalan di:${NC}"
        PUBLIC_IP=$(curl -s --max-time 5 ifconfig.me)
        [ -n "$PUBLIC_IP" ] && echo -e "  - ${WHITE}http://${PUBLIC_IP}${NC}"
        echo -e "  - ${WHITE}http://localhost${NC}"
        echo ""
        read -p "Tekan ENTER untuk kembali ke menu..."
    fi
}

# Function untuk install Git dan clone repository (fixed: quote vars, check status)
install_git_clone() {
    clear
    show_header
    
    echo -e "${CYAN}📦 INSTALL GIT & CLONE REPOSITORY${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Git untuk version control dan clone project dari GitHub"
    echo ""
    
    echo -e "${YELLOW}Step 1: Install Git${NC}"
    echo ""
    
    read -p "Install Git? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        (
            set -e
            sudo apt update
            sudo apt install -y git
        ) &
        pid=$!
        loading_animation $pid
        wait $pid
        if [ $? -ne 0 ]; then
            echo -e "${RED}[✗] Gagal install Git!${NC}"
            read -p "Tekan ENTER untuk kembali..."
            return
        fi
        echo -e "${GREEN}[✓] Git installed!${NC}"
        git --version
    fi
    
    echo ""
    echo -e "${YELLOW}Step 2: Clone Repository${NC}"
    echo ""
    echo -e "${CYAN}Contoh repository populer:${NC}"
    echo -e "  ${WHITE}1${NC}) Laravel:      ${CYAN}https://github.com/laravel/laravel.git${NC}"
    echo -e "  ${WHITE}2${NC}) Node.js App:  ${CYAN}https://github.com/expressjs/express.git${NC}"
    echo -e "  ${WHITE}3${NC}) React App:    ${CYAN}https://github.com/facebook/create-react-app.git${NC}"
    echo -e "  ${WHITE}4${NC}) Custom URL"
    echo ""
    
    read -p "Pilih repository (1-4): " repo_choice
    
    case $repo_choice in
        1)
            REPO_URL="https://github.com/laravel/laravel.git"
            REPO_NAME="laravel"
            ;;
        2)
            REPO_URL="https://github.com/expressjs/express.git"
            REPO_NAME="express"
            ;;
        3)
            REPO_URL="https://github.com/facebook/create-react-app.git"
            REPO_NAME="react-app"
            ;;
        4)
            read -p "Masukkan URL repository: " REPO_URL
            if [ -z "$REPO_URL" ]; then
                echo -e "${RED}URL tidak boleh kosong!${NC}"
                read -p "Tekan ENTER untuk kembali..."
                return
            fi
            REPO_NAME=$(basename "$REPO_URL" .git)
            ;;
        *)
            echo -e "${RED}Pilihan tidak valid!${NC}"
            read -p "Tekan ENTER untuk kembali..."
            return
            ;;
    esac
    
    echo ""
    read -p "Clone repository ${REPO_NAME}? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -d "$REPO_NAME" ]; then
            echo -e "${RED}[✗] Folder '${REPO_NAME}' sudah ada di direktori ini!${NC}"
            read -p "Tekan ENTER untuk kembali..."
            return
        fi
        echo -e "${GREEN}[*] Cloning ${REPO_NAME}...${NC}"
        (
            set -e
            git clone "$REPO_URL"
        ) &
        pid=$!
        loading_animation $pid
        wait $pid
        if [ $? -ne 0 ]; then
            echo -e "${RED}[✗] Clone gagal! Cek URL repository.${NC}"
            read -p "Tekan ENTER untuk kembali..."
            return
        fi
        
        echo ""
        echo -e "${GREEN}[✓] Repository cloned!${NC}"
        echo -e "${CYAN}📁 Lokasi: ${WHITE}$(pwd)/${REPO_NAME}${NC}"
        echo ""
        ls -la "$REPO_NAME" | head -10
        echo ""
        echo -e "${YELLOW}💡 Langkah selanjutnya:${NC}"
        echo -e "  cd ${REPO_NAME}"
        echo -e "  # Ikuti petunjuk instalasi dari repository"
        echo ""
        read -p "Tekan ENTER untuk kembali ke menu..."
    fi
}

# Function untuk install Node.js (fixed: check status)
install_nodejs() {
    clear
    show_header
    
    echo -e "${CYAN}⚡ INSTALL NODE.JS${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Node.js adalah runtime JavaScript untuk server applications"
    echo ""
    
    echo -e "${YELLOW}Versi yang tersedia:${NC}"
    echo -e "  ${WHITE}1${NC}) Node.js 20.x (Stable)"
    echo -e "  ${WHITE}2${NC}) Node.js 18.x (LTS)"
    echo -e "  ${WHITE}3${NC}) Node.js 16.x"
    echo ""
    
    read -p "Pilih versi (1-3): " version_choice
    
    case $version_choice in
        1) NODE_VERSION="20.x" ;;
        2) NODE_VERSION="18.x" ;;
        3) NODE_VERSION="16.x" ;;
        *) NODE_VERSION="20.x" ;;
    esac
    
    echo ""
    echo -e "${YELLOW}Command yang akan dijalankan:${NC}"
    echo ""
    echo -e "${WHITE}1/3${NC} Menambah NodeSource repository..."
    echo -e "${CYAN}\$ curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION} | sudo -E bash -${NC}"
    echo ""
    echo -e "${WHITE}2/3${NC} Install Node.js..."
    echo -e "${CYAN}\$ sudo apt-get install -y nodejs${NC}"
    echo ""
    echo -e "${WHITE}3/3${NC} Verifikasi instalasi..."
    echo -e "${CYAN}\$ node --version${NC}"
    echo ""
    
    read -p "Mulai instalasi? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}[*] Memulai instalasi Node.js ${NODE_VERSION}...${NC}"
        (
            set -e
            curl -fsSL "https://deb.nodesource.com/setup_${NODE_VERSION}" | sudo -E bash -
            sudo apt-get install -y nodejs
        ) &
        pid=$!
        loading_animation $pid
        wait $pid
        if [ $? -ne 0 ]; then
            echo -e "${RED}[✗] Instalasi Node.js gagal!${NC}"
            read -p "Tekan ENTER untuk kembali..."
            return
        fi
        
        echo ""
        echo -e "${GREEN}[✓] Instalasi selesai!${NC}"
        echo -e "${CYAN}📦 Node version:${NC} $(node --version)"
        echo -e "${CYAN}📦 NPM version:${NC} $(npm --version)"
        echo ""
        
        echo -e "${YELLOW}💡 Install global packages?${NC}"
        read -p "Install PM2 dan Nodemon? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            (
                set -e
                sudo npm install -g pm2 nodemon
            ) &
            pid=$!
            loading_animation $pid
            wait $pid
            if [ $? -ne 0 ]; then
                echo -e "${RED}[✗] Gagal install global packages!${NC}"
            else
                echo -e "${GREEN}[✓] Global packages installed!${NC}"
            fi
        fi
        read -p "Tekan ENTER untuk kembali ke menu..."
    fi
}

# Function untuk install NVM (fixed: check status)
install_nvm() {
    clear
    show_header
    
    echo -e "${CYAN}📦 INSTALL NVM (Node Version Manager)${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "NVM memungkinkan Anda kelola multiple versi Node.js dengan mudah"
    echo ""
    
    echo -e "${YELLOW}Command yang akan dijalankan:${NC}"
    echo ""
    echo -e "${WHITE}1/4${NC} Download NVM installer..."
    echo -e "${CYAN}\$ curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash${NC}"
    echo ""
    echo -e "${WHITE}2/4${NC} Setup NVM environment..."
    echo -e "${CYAN}\$ export NVM_DIR=\"\$HOME/.nvm\"${NC}"
    echo ""
    echo -e "${WHITE}3/4${NC} Source NVM..."
    echo -e "${CYAN}\$ [ -s \"\$NVM_DIR/nvm.sh\" ] && \\. \"\$NVM_DIR/nvm.sh\"${NC}"
    echo ""
    echo -e "${WHITE}4/4${NC} Verifikasi instalasi..."
    echo -e "${CYAN}\$ nvm --version${NC}"
    echo ""
    
    read -p "Mulai instalasi? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}[*] Memulai instalasi NVM...${NC}"
        (
            set -e
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        ) &
        pid=$!
        loading_animation $pid
        wait $pid
        if [ $? -ne 0 ]; then
            echo -e "${RED}[✗] Instalasi NVM gagal!${NC}"
            read -p "Tekan ENTER untuk kembali..."
            return
        fi
        
        echo ""
        echo -e "${GREEN}[✓] Instalasi NVM selesai!${NC}"
        echo ""
        echo -e "${YELLOW}⚠️  PENTING: Logout dan login ulang (atau buka terminal baru) untuk menggunakan nvm${NC}"
        echo ""
        echo -e "${CYAN}💡 Setelah restart terminal, jalankan:${NC}"
        echo -e "  nvm install --lts"
        echo -e "  nvm use --lts"
        echo ""
        read -p "Tekan ENTER untuk kembali ke menu..."
    fi
}

# Function untuk install Neofetch (fixed: check status)
install_neofetch() {
    clear
    show_header
    
    echo -e "${CYAN}🎨 INSTALL NEOFETCH${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Neofetch menampilkan system information dengan ASCII art yang keren"
    echo ""
    
    echo -e "${YELLOW}Command yang akan dijalankan:${NC}"
    echo ""
    echo -e "${WHITE}1/2${NC} Install Neofetch..."
    echo -e "${CYAN}\$ sudo apt install -y neofetch${NC}"
    echo ""
    echo -e "${WHITE}2/2${NC} Jalankan Neofetch..."
    echo -e "${CYAN}\$ neofetch${NC}"
    echo ""
    
    read -p "Mulai instalasi? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}[*] Memulai instalasi Neofetch...${NC}"
        (
            set -e
            sudo apt update
            sudo apt install -y neofetch
        ) &
        pid=$!
        loading_animation $pid
        wait $pid
        if [ $? -ne 0 ]; then
            echo -e "${RED}[✗] Instalasi Neofetch gagal!${NC}"
            read -p "Tekan ENTER untuk kembali..."
            return
        fi
        
        echo ""
        echo -e "${GREEN}[✓] Instalasi selesai!${NC}"
        echo ""
        echo -e "${YELLOW}📊 Output Neofetch:${NC}"
        echo ""
        neofetch
        echo ""
        read -p "Tekan ENTER untuk kembali ke menu..."
    fi
}

# Function untuk install Pterodactyl (fixed: quoting, cd inside subshell doesn't leak, status check)
install_pterodactyl() {
    clear
    show_header
    
    echo -e "${CYAN}🎮 INSTALL PTERODACTYL PANEL${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Pterodactyl adalah game server & application panel yang powerful"
    echo ""
    
    echo -e "${YELLOW}⚠️  REQUIREMENT:${NC}"
    echo "- PHP 8.0 atau lebih tinggi"
    echo "- MySQL/MariaDB"
    echo "- Composer"
    echo "- Redis (optional)"
    echo ""
    
    echo -e "${YELLOW}Command yang akan dijalankan:${NC}"
    echo ""
    echo -e "${WHITE}1/9${NC} Buat direktori Pterodactyl..."
    echo -e "${CYAN}\$ mkdir -p /var/www/pterodactyl${NC}"
    echo ""
    echo -e "${WHITE}2/9${NC} Navigate ke direktori..."
    echo -e "${CYAN}\$ cd /var/www/pterodactyl${NC}"
    echo ""
    echo -e "${WHITE}3/9${NC} Download panel..."
    echo -e "${CYAN}\$ curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz${NC}"
    echo ""
    echo -e "${WHITE}4/9${NC} Extract files..."
    echo -e "${CYAN}\$ tar -xzvf panel.tar.gz${NC}"
    echo ""
    echo -e "${WHITE}5/9${NC} Set permissions..."
    echo -e "${CYAN}\$ chmod -R 755 storage bootstrap/cache${NC}"
    echo ""
    echo -e "${WHITE}6/9${NC} Copy .env..."
    echo -e "${CYAN}\$ cp .env.example .env${NC}"
    echo ""
    echo -e "${WHITE}7/9${NC} Install dependencies..."
    echo -e "${CYAN}\$ composer install --no-dev --optimize-autoloader${NC}"
    echo ""
    echo -e "${WHITE}8/9${NC} Generate key..."
    echo -e "${CYAN}\$ php artisan key:generate --force${NC}"
    echo ""
    echo -e "${WHITE}9/9${NC} Setup database..."
    echo -e "${CYAN}\$ php artisan migrate --seed --force${NC}"
    echo ""
    
    read -p "Mulai instalasi? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}[*] Memulai instalasi Pterodactyl...${NC}"
        (
            set -e
            mkdir -p /var/www/pterodactyl
            cd /var/www/pterodactyl
            curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
            tar -xzvf panel.tar.gz
            chmod -R 755 storage bootstrap/cache
            cp .env.example .env
            composer install --no-dev --optimize-autoloader
            php artisan key:generate --force
        ) &
        pid=$!
        loading_animation $pid
        wait $pid
        if [ $? -ne 0 ]; then
            echo -e "${RED}[✗] Instalasi Pterodactyl gagal! Cek requirement PHP/Composer.${NC}"
            read -p "Tekan ENTER untuk kembali..."
            return
        fi
        
        echo ""
        echo -e "${YELLOW}⚠️  Database Setup:${NC}"
        echo "Sebelum menjalankan migration, setup database Anda terlebih dahulu"
        echo ""
        read -p "Database sudah siap? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            (
                set -e
                cd /var/www/pterodactyl
                php artisan migrate --seed --force
            ) &
            pid=$!
            loading_animation $pid
            wait $pid
            if [ $? -ne 0 ]; then
                echo -e "${RED}[✗] Migration gagal! Cek koneksi database.${NC}"
            else
                echo -e "${GREEN}[✓] Instalasi Pterodactyl selesai!${NC}"
            fi
        fi
        echo ""
        read -p "Tekan ENTER untuk kembali ke menu..."
    fi
}

show_menu() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}              ${WHITE}📋 MAIN MENU${NC}                           ${BLUE}║${NC}"
    echo -e "${BLUE}╠════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}1${NC}) 📊 Cek System Information               ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}2${NC}) 🌐 Install Nginx Web Server            ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}3${NC}) 📦 Install Git & Clone Repository      ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}4${NC}) ⚡ Install Node.js                      ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}5${NC}) 📦 Install NVM                         ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}6${NC}) 🎮 Install Pterodactyl Panel           ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}7${NC}) 🎨 Install Neofetch                    ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}8${NC}) 🔧 Install Multiple Tools              ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}0${NC}) ❌ Exit                                ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

install_multiple() {
    clear
    show_header
    
    echo -e "${CYAN}🔧 INSTALL MULTIPLE TOOLS${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}Pilih tools yang ingin diinstall:${NC}"
    echo ""
    echo -e "  ${CYAN}a${NC}) 🌐 Nginx"
    echo -e "  ${CYAN}b${NC}) 📦 Git"
    echo -e "  ${CYAN}c${NC}) ⚡ Node.js 20.x"
    echo -e "  ${CYAN}d${NC}) 🎨 Neofetch"
    echo -e "  ${CYAN}e${NC}) All Tools"
    echo ""
    
    read -p "Pilihan (a/b/c/d/e): " multi_choice
    
    case $multi_choice in
        a)
            install_nginx
            ;;
        b)
            (
                set -e
                sudo apt update
                sudo apt install -y git
            ) &
            pid=$!
            loading_animation $pid
            wait $pid
            if [ $? -ne 0 ]; then
                echo -e "${RED}[✗] Gagal install Git!${NC}"
            else
                echo -e "${GREEN}[✓] Git installed!${NC}"
                git --version
            fi
            read -p "Tekan ENTER untuk kembali..."
            ;;
        c)
            install_nodejs
            ;;
        d)
            install_neofetch
            ;;
        e)
            echo -e "${GREEN}[*] Menginstall semua tools...${NC}"
            (
                set -e
                sudo apt update
                sudo apt install -y nginx git neofetch
                curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
                sudo apt-get install -y nodejs
            ) &
            pid=$!
            loading_animation $pid
            wait $pid
            if [ $? -ne 0 ]; then
                echo -e "${RED}[✗] Sebagian atau semua instalasi gagal! Cek pesan error di atas.${NC}"
                read -p "Tekan ENTER untuk kembali..."
                return
            fi
            echo -e "${GREEN}[✓] Semua tools terinstall!${NC}"
            echo ""
            echo -e "${CYAN}📦 Versi terinstall:${NC}"
            nginx -v 2>&1
            git --version
            node --version
            npm --version
            neofetch --version
            read -p "Tekan ENTER untuk kembali..."
            ;;
        *)
            echo -e "${RED}Pilihan tidak valid!${NC}"
            sleep 2
            ;;
    esac
}

# Check if running as root for installations
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}⚠️  Script ini perlu dijalankan sebagai root untuk install tools${NC}"
        echo -e "${YELLOW}Silakan jalankan: sudo bash vps-tools.sh${NC}"
        exit 1
    fi
}

# Main loop
main() {
    while true; do
        clear
        show_header
        show_menu
        
        read -p "Pilih menu (0-8): " choice
        
        case $choice in
            1)
                show_system_info
                ;;
            2)
                install_nginx
                ;;
            3)
                install_git_clone
                ;;
            4)
                install_nodejs
                ;;
            5)
                install_nvm
                ;;
            6)
                install_pterodactyl
                ;;
            7)
                install_neofetch
                ;;
            8)
                install_multiple
                ;;
            0)
                echo -e "${GREEN}Terima kasih telah menggunakan VPS Tools Dashboard!${NC}"
                echo -e "${CYAN}Bye bye! 👋${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Menu tidak valid! Coba lagi.${NC}"
                sleep 2
                ;;
        esac
    done
}

# Fixed: check_root was defined but never called before — script would let
# non-root users click through installs that then failed with permission errors.
check_root
main
