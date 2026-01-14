# Building and Packaging RDAP Client

This document explains how to install, build, and package the RDAP client for various Linux distributions.

## Table of Contents

1. [Quick Installation](#quick-installation)
2. [Building from Source](#building-from-source)
3. [Creating a Debian/Ubuntu Package](#creating-a-debianubuntu-package)
4. [Creating an RPM Package](#creating-an-rpm-package)
5. [Creating an Alpine Package](#creating-an-alpine-package)
6. [Distribution via Script Repository](#distribution-via-script-repository)

---

## Quick Installation

### Option 1: Direct Download (Simplest)

```bash
# System-wide installation (requires sudo)
sudo curl -o /usr/local/bin/rdap https://raw.githubusercontent.com/your-repo/rdap/main/rdap
sudo chmod +x /usr/local/bin/rdap

# User installation (no sudo required)
mkdir -p ~/.local/bin
curl -o ~/.local/bin/rdap https://raw.githubusercontent.com/your-repo/rdap/main/rdap
chmod +x ~/.local/bin/rdap
export PATH="$HOME/.local/bin:$PATH"  # Add to ~/.bashrc for persistence
```

### Option 2: Using Make

```bash
# Clone the repository
git clone https://github.com/Osir-Inc/rdap.git
cd rdap

# System-wide installation
sudo make install

# Or user installation
make install-user
```

### Install Optional Dependency

```bash
# For better formatted output, install jq
sudo apt install jq        # Debian/Ubuntu
sudo dnf install jq        # Fedora/RHEL
sudo pacman -S jq          # Arch Linux
```

---

## Building from Source

Since rdap is a pure bash script, there's no compilation required. "Building" simply means verifying the script and preparing it for distribution.

### Prerequisites

- bash (for syntax checking)
- make (optional, for using Makefile)
- gzip (for man page compression)

### Steps

```bash
# Clone repository
git clone https://github.com/Osir-Inc/rdap.git
cd rdap

# Verify syntax
bash -n rdap
echo $?  # Should output 0

# Test basic functionality
./rdap --help
./rdap example.com

# Install
sudo make install
```

---

## Creating a Debian/Ubuntu Package

### Prerequisites

```bash
sudo apt update
sudo apt install build-essential devscripts debhelper dh-make
```

### Method 1: Quick .deb Build (Recommended)

```bash
# Create build directory
mkdir -p ~/rdap-build
cd ~/rdap-build

# Create package structure
mkdir -p rdap-1.3.5/DEBIAN
mkdir -p rdap-1.3.5/usr/bin
mkdir -p rdap-1.3.5/usr/share/man/man1
mkdir -p rdap-1.3.5/usr/share/doc/rdap

# Copy files (adjust paths as needed)
cp /path/to/rdap rdap-1.3.5/usr/bin/
chmod 755 rdap-1.3.5/usr/bin/rdap

cp /path/to/rdap.1 rdap-1.3.5/usr/share/man/man1/
gzip rdap-1.3.5/usr/share/man/man1/rdap.1

cp /path/to/README.md rdap-1.3.5/usr/share/doc/rdap/

# Create control file
cat > rdap-1.3.5/DEBIAN/control << 'EOF'
Package: rdap
Version: 1.3.5
Section: net
Priority: optional
Architecture: all
Depends: curl
Recommends: jq
Maintainer: Your Name <support@osir.com>
Description: Simple RDAP client for Linux
 A lightweight RDAP client that queries registration data for
 domains, IP addresses, and autonomous system numbers.
 Requires only curl, with optional jq for formatted output.
EOF

# Build the package
dpkg-deb --build rdap-1.3.5

# Result: rdap-1.3.5.deb
```

### Method 2: Full Debian Package Build

```bash
# Create source directory
mkdir -p ~/rdap-1.3.5
cd ~/rdap-1.3.5

# Copy source files
cp /path/to/rdap .
cp /path/to/rdap.1 .
cp /path/to/README.md .
cp /path/to/Makefile .

# Copy debian directory
cp -r /path/to/debian .

# Make rules executable
chmod +x debian/rules

# Build package
dpkg-buildpackage -us -uc -b

# Result: ../rdap_1.3.5-1_all.deb
```

### Installing the .deb Package

```bash
# Install
sudo dpkg -i rdap_1.3.5-1_all.deb

# If there are dependency issues
sudo apt --fix-broken install

# Or use apt directly (handles dependencies)
sudo apt install ./rdap_1.3.5-1_all.deb
```

### Uninstalling

```bash
sudo apt remove rdap
# Or
sudo dpkg -r rdap
```

---

## Creating an RPM Package (Fedora/RHEL/CentOS)

### Prerequisites

```bash
sudo dnf install rpm-build rpmdevtools
```

### Setup RPM Build Environment

```bash
rpmdev-setuptree
```

### Create Spec File

```bash
cat > ~/rpmbuild/SPECS/rdap.spec << 'EOF'
Name:           rdap
Version:        1.3.5
Release:        1%{?dist}
Summary:        Simple RDAP client for Linux

License:        MIT
URL:            https://github.com/Osir-Inc/rdap
Source0:        %{name}-%{version}.tar.gz

BuildArch:      noarch
Requires:       curl
Recommends:     jq

%description
A lightweight RDAP (Registration Data Access Protocol) client that queries
registration data for domains, IP addresses, and autonomous system numbers.

%prep
%setup -q

%install
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_mandir}/man1
mkdir -p %{buildroot}%{_docdir}/%{name}

install -m 755 rdap %{buildroot}%{_bindir}/rdap
install -m 644 rdap.1 %{buildroot}%{_mandir}/man1/rdap.1
install -m 644 README.md %{buildroot}%{_docdir}/%{name}/README.md

%files
%{_bindir}/rdap
%{_mandir}/man1/rdap.1*
%{_docdir}/%{name}/README.md

%changelog
* Tue Jan 14 2025 Your Name <support@osir.com> - 1.3.5-1
- Initial RPM release
EOF
```

### Create Source Tarball

```bash
mkdir -p ~/rpmbuild/SOURCES
mkdir rdap-1.3.5
cp rdap rdap.1 README.md Makefile rdap-1.3.5/
tar czvf ~/rpmbuild/SOURCES/rdap-1.3.5.tar.gz rdap-1.3.5
rm -rf rdap-1.3.5
```

### Build RPM

```bash
rpmbuild -ba ~/rpmbuild/SPECS/rdap.spec

# Result: ~/rpmbuild/RPMS/noarch/rdap-1.3.5-1.*.noarch.rpm
```

### Installing the RPM

```bash
sudo dnf install ~/rpmbuild/RPMS/noarch/rdap-1.3.5-1.*.noarch.rpm
# Or
sudo rpm -i ~/rpmbuild/RPMS/noarch/rdap-1.3.5-1.*.noarch.rpm
```

---

## Creating an Alpine Package (APK)

### Prerequisites

```bash
sudo apk add alpine-sdk
```

### Create APKBUILD

```bash
mkdir -p ~/aports/testing/rdap
cd ~/aports/testing/rdap

cat > APKBUILD << 'EOF'
# Maintainer: Your Name <support@osir.com>
pkgname=rdap
pkgver=1.3.5
pkgrel=0
pkgdesc="Simple RDAP client for Linux"
url="https://github.com/Osir-Inc/rdap"
arch="noarch"
license="MIT"
depends="curl bash"
makedepends=""
source="rdap rdap.1 README.md"

package() {
    install -Dm755 "$srcdir"/rdap "$pkgdir"/usr/bin/rdap
    install -Dm644 "$srcdir"/rdap.1 "$pkgdir"/usr/share/man/man1/rdap.1
    install -Dm644 "$srcdir"/README.md "$pkgdir"/usr/share/doc/$pkgname/README.md
}
EOF
```

### Build APK

```bash
abuild -r

# Result: ~/packages/testing/x86_64/rdap-1.3.5-r0.apk
```

---

## Distribution via Script Repository

For simple distribution, you can host the script and provide a one-liner install:

### Create Install Script

```bash
cat > install.sh << 'EOF'
#!/bin/bash
set -e

VERSION="1.3.5"
INSTALL_DIR="${1:-/usr/local/bin}"

echo "Installing rdap v${VERSION} to ${INSTALL_DIR}..."

# Check for curl
command -v curl >/dev/null 2>&1 || { echo "Error: curl is required"; exit 1; }

# Download and install
if [ -w "$INSTALL_DIR" ]; then
    curl -fsSL "https://raw.githubusercontent.com/your-repo/rdap/v${VERSION}/rdap" -o "${INSTALL_DIR}/rdap"
    chmod +x "${INSTALL_DIR}/rdap"
else
    sudo curl -fsSL "https://raw.githubusercontent.com/your-repo/rdap/v${VERSION}/rdap" -o "${INSTALL_DIR}/rdap"
    sudo chmod +x "${INSTALL_DIR}/rdap"
fi

echo "Installed successfully!"
echo "Run 'rdap --help' to get started"

# Suggest jq installation
if ! command -v jq >/dev/null 2>&1; then
    echo ""
    echo "Tip: Install jq for better formatted output:"
    echo "  apt install jq   # Debian/Ubuntu"
    echo "  dnf install jq   # Fedora/RHEL"
fi
EOF
```

### One-liner Installation

Users can then install with:

```bash
# System-wide
curl -fsSL https://raw.githubusercontent.com/your-repo/rdap/main/install.sh | sudo bash

# User installation
curl -fsSL https://raw.githubusercontent.com/your-repo/rdap/main/install.sh | bash -s ~/.local/bin
```

---

## Package Signing (Optional)

For production distribution, sign your packages:

### Debian (.deb)

```bash
# Generate GPG key
gpg --gen-key

# Sign the package
dpkg-sig --sign builder rdap_1.3.5-1_all.deb
```

### RPM

```bash
# Import your GPG key
rpm --import your-public-key.asc

# Sign the RPM
rpm --addsign rdap-1.3.5-1.noarch.rpm
```

---

## CI/CD Integration

Example GitHub Actions workflow for automated releases:

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Build .deb package
        run: |
          mkdir -p build/rdap-${{ github.ref_name }}/DEBIAN
          mkdir -p build/rdap-${{ github.ref_name }}/usr/bin
          cp rdap build/rdap-${{ github.ref_name }}/usr/bin/
          chmod 755 build/rdap-${{ github.ref_name }}/usr/bin/rdap
          # ... create control file
          dpkg-deb --build build/rdap-${{ github.ref_name }}
      
      - name: Upload Release Assets
        uses: softprops/action-gh-release@v1
        with:
          files: |
            build/*.deb
            rdap
```

---

## Verification

After installation, verify everything works:

```bash
# Check installation
which rdap
rdap --help

# Check man page (if installed)
man rdap

# Test functionality
rdap example.com
rdap 8.8.8.8
rdap AS13335
```

---

## Troubleshooting

### "bash: rdap: command not found"

The installation directory is not in your PATH:

```bash
# Check where rdap is installed
find /usr -name rdap 2>/dev/null

# Add to PATH
export PATH="/usr/local/bin:$PATH"
```

### Man page not found

```bash
# Update man database
sudo mandb
```

### Package build fails

Check for missing dependencies:

```bash
# Debian
sudo apt install build-essential debhelper

# Fedora
sudo dnf install rpm-build
```
