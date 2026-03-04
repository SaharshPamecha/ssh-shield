#!/bin/bash
#
# SSH-Shield Installer
# One-line install: curl -sL https://raw.githubusercontent.com/SaharshPamecha/ssh-shield/main/install.sh | sudo bash
#

set -e

REPO_URL="https://raw.githubusercontent.com/SaharshPamecha/ssh-shield/main"
INSTALL_DIR="/usr/local/bin"
TOOL_NAME="ssh-shield"

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║              SSH-SHIELD INSTALLER                        ║"
echo "║         SSH Hardening & Compliance Tool                  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "⚠️  Warning: This installer needs root privileges"
   echo "   Run: curl -sL ... | sudo bash"
   echo ""
   exit 1
fi

echo "📦 Installing ssh-shield..."
echo ""

# Download the tool
echo "   → Downloading from GitHub..."
if command -v curl &> /dev/null; then
    curl -fsSL "${REPO_URL}/cli/ssh-shield" -o "${INSTALL_DIR}/${TOOL_NAME}"
elif command -v wget &> /dev/null; then
    wget -q "${REPO_URL}/cli/ssh-shield" -O "${INSTALL_DIR}/${TOOL_NAME}"
else
    echo "❌ Error: curl or wget is required"
    exit 1
fi

# Make executable
chmod +x "${INSTALL_DIR}/${TOOL_NAME}"

# Verify installation
echo "   → Verifying installation..."
if "${INSTALL_DIR}/${TOOL_NAME}" help &>/dev/null; then
    echo ""
    echo "✅ Installation successful!"
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "   Get started:"
    echo ""
    echo "   # Check current SSH status"
    echo "   ssh-shield audit"
    echo ""
    echo "   # Apply hardening (requires root)"
    echo "   sudo ssh-shield harden"
    echo ""
    echo "   # Generate compliance report"
    echo "   ssh-shield report"
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "   Documentation: https://github.com/SaharshPamecha/ssh-shield"
    echo "   Live Demo:     https://ssh-shield.vercel.app"
    echo ""
else
    echo "❌ Installation verification failed"
    exit 1
fi
