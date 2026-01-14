#!/bin/bash
#
# RDAP Client Installer
# Usage: ./install.sh [--user]
#
# Options:
#   --user    Install to ~/.local/bin (no sudo required)
#   (default) Install to /usr/local/bin (requires sudo)
#

set -e

VERSION="1.3.5"
REPO_URL="https://raw.githubusercontent.com/Osir-Inc/rdap/main"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

info() { printf "${GREEN}[INFO]${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
error() { printf "${RED}[ERROR]${NC} %s\n" "$1" >&2; exit 1; }

# Check for required commands
command -v curl >/dev/null 2>&1 || error "curl is required but not installed"

# Parse arguments
USER_INSTALL=0
if [ "$1" = "--user" ] || [ "$1" = "-u" ]; then
    USER_INSTALL=1
fi

if [ "$USER_INSTALL" = "1" ]; then
    INSTALL_DIR="$HOME/.local/bin"
    MAN_DIR="$HOME/.local/share/man/man1"
else
    INSTALL_DIR="/usr/local/bin"
    MAN_DIR="/usr/local/share/man/man1"
fi

info "Installing RDAP Client v${VERSION}"
info "Installation directory: ${INSTALL_DIR}"

# Create directories
if [ "$USER_INSTALL" = "1" ]; then
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$MAN_DIR"
else
    sudo mkdir -p "$INSTALL_DIR"
    sudo mkdir -p "$MAN_DIR"
fi

# Install script
if [ -f "$SCRIPT_DIR/rdap" ]; then
    # Install from local directory
    if [ "$USER_INSTALL" = "1" ]; then
        install -m 755 "$SCRIPT_DIR/rdap" "$INSTALL_DIR/rdap"
        [ -f "$SCRIPT_DIR/rdap.1" ] && install -m 644 "$SCRIPT_DIR/rdap.1" "$MAN_DIR/rdap.1"
    else
        sudo install -m 755 "$SCRIPT_DIR/rdap" "$INSTALL_DIR/rdap"
        [ -f "$SCRIPT_DIR/rdap.1" ] && sudo install -m 644 "$SCRIPT_DIR/rdap.1" "$MAN_DIR/rdap.1"
    fi
else
    error "rdap script not found in $SCRIPT_DIR"
fi

info "Installation complete!"
echo ""

# Check if install dir is in PATH
if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
    warn "$INSTALL_DIR is not in your PATH"
    echo ""
    echo "Add it to your PATH by running:"
    echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
    echo ""
    echo "Add to ~/.bashrc or ~/.zshrc for persistence"
    echo ""
fi

# Check for jq
if ! command -v jq >/dev/null 2>&1; then
    warn "jq is not installed (optional, for better formatting)"
    echo ""
    echo "Install jq with:"
    echo "  sudo apt install jq       # Debian/Ubuntu"
    echo "  sudo dnf install jq       # Fedora/RHEL"
    echo "  sudo pacman -S jq         # Arch Linux"
    echo ""
fi

info "Run 'rdap --help' to get started"
info "Try: rdap example.com"
