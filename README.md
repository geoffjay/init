# OS Initialization and Configuration

A comprehensive system for initializing and configuring Linux and macOS operating systems with minimal setup requirements. This project provides automated tools to transform a fresh OS installation into a fully configured development environment.

## 🎯 Purpose

This project provides the tools needed to perform Linux or macOS operating system initialization and configuration, including user environment setup. It's designed to require little to no setup to fully run on a brand new installation of an operating system.

## ✨ Key Features

- **Zero-Setup Bootstrap**: Single command installation via `wget`/`curl`
- **Ansible-Driven Configuration**: Declarative, idempotent system configuration  
- **Cross-Platform Support**: Linux (Ubuntu/Debian/Pop!_OS/Alpine) and macOS
- **Environment Management**: Consistent tool versions via `asdf` and `direnv`
- **Shell Integration**: Automated zsh configuration and setup
- **Minimal Dependencies**: Only requires standard system tools to get started

## 🚀 Quick Start

### Web Installation (Recommended)

For a fresh OS installation, run:

```bash
wget -q -O - https://raw.githubusercontent.com/geoffjay/init/main/scripts/prepare | bash
```

Or with curl:

```bash
curl -fsSL https://raw.githubusercontent.com/geoffjay/init/main/scripts/prepare | bash
```

### Local Installation

If you already have the repository cloned:

```bash
cd ~/Projects/init
./scripts/prepare
```

### Complete Setup Workflow

After the bootstrap script completes:

```bash
# If you selected a different shell (e.g., --shell=zsh), you need to switch to it:
exec zsh      # if you configured zsh
exec bash     # if you configured bash
# OR log out and log back in (recommended)

# If no shell was selected, source the configuration:
source ~/.bash_profile  # for bash
source ~/.zshrc         # for zsh

# Navigate to project directory
cd ~/Projects/init

# Allow direnv to manage the environment
direnv allow

# Install project tools (Python, uv, etc.)
asdf install

# Run full system configuration
ansible-playbook -k playbook.yml
```

## 🖥️ Supported Platforms

| Platform | Package Manager | Status |
|----------|----------------|---------|
| Ubuntu 20.04+ | apt | ✅ Supported |
| Debian 11+ | apt | ✅ Supported |
| Pop!_OS 22.04+ | apt | ✅ Supported |
| Alpine Linux 3.18+ | apk | ✅ Supported |
| macOS 13+ | brew | ✅ Supported |

Both x86_64 and ARM64 architectures are supported.

## 🛠️ What Gets Installed

### Bootstrap Phase (`scripts/prepare`)
- **Shell configuration**: Install and configure bash or zsh (optional, with `--shell` option)
- **git**: Version control system
- **asdf**: Version manager for development tools (installed via Homebrew on macOS, git clone on Linux)
- **Homebrew**: Package manager (macOS only)
- **Project repository**: Cloned to `~/Projects/init`
- **PATH configuration**: asdf shims automatically added to shell PATH

### Full Configuration Phase (Ansible)
- **zsh**: Default shell with configuration
- **Development tools**: vim, curl, wget, build tools
- **Python environment**: Managed via virtual environment
- **System optimizations**: Platform-specific improvements

## 📋 Prerequisites

### Minimal Requirements
- Internet connectivity
- One of the supported operating systems
- Basic system tools (`curl` or `wget`, `bash`, `sudo` on Linux)

### Recommended
- At least 1GB free disk space
- Administrator/sudo access (Linux) or admin user (macOS)

## 🏗️ Project Structure

```
init/
├── .tool-versions           # Tool version definitions
├── .envrc                   # Environment configuration
├── README.md               # This file
├── playbook.yml            # Main Ansible playbook
├── requirements.txt        # Python dependencies
├── scripts/
│   └── prepare             # Bootstrap script
├── docs/
│   ├── plans/              # Development planning documents
│   └── specs/              # Product requirements documents
├── playbooks/              # Ansible playbooks (future)
├── inventory/              # Ansible inventory (future)
└── roles/                  # Custom Ansible roles (future)
```

## 🔧 Advanced Usage

### Bootstrap Script Options

```bash
# Show help information
./scripts/prepare --help

# Preview what would be installed (dry run)
./scripts/prepare --dry-run

# Install, set as default, and configure zsh
./scripts/prepare --shell=zsh
# Note: If different from current shell, you'll be prompted to continue in zsh

# Install, set as default, and configure bash  
./scripts/prepare --shell=bash
# Note: If different from current shell, you'll be prompted to continue in bash

# Enable debug output
./scripts/prepare --debug

# Show version information
./scripts/prepare --version
```

### Shell Switching

When you specify a shell that's different from your current shell, the script provides intelligent shell switching:

1. **Detection**: Automatically detects if the requested shell differs from your current shell
2. **Installation**: Installs the requested shell if not already present
3. **Default Shell**: Uses `chsh` to set the new shell as your system default
4. **User Choice**: Prompts you with two options:
   - **Option A (Recommended)**: Continue the bootstrap process in the new shell
   - **Option B**: Complete bootstrap in current shell, then logout/login

**Option A** is recommended because:
- Ensures all configuration is applied to the correct shell
- Makes tools like `asdf` immediately accessible
- Provides a seamless transition to your new shell environment

### Environment Variables

- `ALLOW_ROOT=true`: Allow running as root (not recommended)
- `PROJECT_REPO`: Override the default repository URL

### Custom Configuration

The system is designed to be extensible:

- **OS Support**: Add new playbooks in `playbooks/` directory
- **Package Managers**: Extend Ansible tasks for additional package managers
- **Custom Tools**: Add plugins to `asdf` or create custom Ansible roles
- **User Preferences**: Modify inventory variables for personalization

## 🎯 Design Philosophy

### Principles

1. **Idempotency**: All operations can be run multiple times safely
2. **Declarative**: Configuration is described, not scripted
3. **Cross-Platform**: Consistent experience across different operating systems
4. **Minimal Setup**: Works on fresh OS installations with minimal prerequisites
5. **Version Controlled**: All configurations are tracked and reproducible
6. **User-Friendly**: Clear output, helpful error messages, comprehensive documentation

### Technology Choices

- **Bash**: Universal availability for bootstrap script
- **Ansible**: Industry-standard configuration management
- **asdf**: Consistent tool version management across platforms
- **direnv**: Automatic environment management
- **Python**: Modern package management with virtual environments

## 🚦 Development Status

| Component | Status | Description |
|-----------|--------|-------------|
| Bootstrap Script | ✅ Complete | Web-installable preparation script |
| Environment Management | ✅ Complete | asdf and direnv integration |
| Platform Detection | ✅ Complete | Multi-OS and architecture support |
| Documentation | ✅ Complete | Comprehensive specs and plans |
| Ansible Playbooks | 🚧 Planned | Full system configuration |
| Testing Framework | 🚧 Planned | Automated testing across platforms |

## 🐛 Troubleshooting

### Common Issues

**Script fails with network error**:
```bash
# Check internet connectivity
curl -I https://github.com

# Try with different DNS
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
```

**Permission denied errors**:
```bash
# Ensure proper permissions
chmod +x scripts/prepare

# Check if running as appropriate user (not root unless necessary)
whoami
```

**asdf commands not found after installation**:
```bash
# Restart your shell or source the appropriate configuration file
source ~/.bash_profile  # for bash users
source ~/.zshrc         # for zsh users
```

### Debug Mode

Enable detailed logging for troubleshooting:

```bash
./scripts/prepare --debug
```

### Getting Help

1. Check the [documentation](docs/specs/) for detailed specifications
2. Run `./scripts/prepare --help` for usage information
3. Open an issue on GitHub with debug output
4. Review the [development plans](docs/plans/) for technical details

## 🤝 Contributing

We welcome contributions! Areas where help is needed:

- **Testing**: Validation on different OS versions and configurations
- **Documentation**: Improvements to guides and troubleshooting
- **Platform Support**: Additional Linux distributions or package managers
- **Ansible Playbooks**: System configuration automation
- **Features**: New tools, configurations, or optimizations

### Development Setup

```bash
# Clone the repository
git clone https://github.com/geoffjay/init.git
cd init

# Run bootstrap script
./scripts/prepare

# Set up development environment
direnv allow
asdf install

# Make changes and test
./scripts/prepare --dry-run
```

## 📄 License

This project is open source. Please see the LICENSE file for details.

## 🙏 Acknowledgments

- **asdf-vm**: Excellent tool version management
- **Ansible**: Powerful automation platform
- **Homebrew**: macOS package management
- **direnv**: Seamless environment management

---

**Ready to transform your fresh OS installation into a fully configured development environment? Run the bootstrap script and get started!**

```bash
wget -q -O - https://raw.githubusercontent.com/geoffjay/init/main/scripts/prepare | bash
```
