# Development Plan: Bootstrap Script (`scripts/prepare`)

## Overview

This document outlines the development plan for the `scripts/prepare` bootstrap script, which serves as the entry point for OS initialization. The script must be web-installable and prepare a minimal environment for the full configuration process.

## Objectives

- Create a robust, cross-platform bootstrap script
- Enable zero-setup installation on fresh OS installations
- Install minimal required tooling (git, asdf, brew on macOS)
- Prepare environment for subsequent Ansible-based configuration
- Ensure script is idempotent and handles errors gracefully

## Requirements Analysis

### Core Requirements
1. **Web Installation**: Must be installable via `wget -q -O - https://github.com/geoffjay/init/tree/main/scripts/prepare | sudo /bin/bash`
2. **Minimal Tooling**: Install git, asdf, and brew (macOS only)
3. **Environment Preparation**: Enable execution of:
   - `mkdir ~/Projects && git clone https://github.com/geoffjay/init ~/Projects/init && cd ~/Projects/init`
   - `direnv allow`
   - `asdf install`
4. **Platform Support**: Linux (Debian/Ubuntu/Pop!_OS, Alpine) and macOS
5. **Idempotency**: Safe to run multiple times
6. **Error Handling**: Graceful failure with meaningful messages

### Success Criteria
- Script completes successfully on clean OS installations
- All required tools are functional after execution
- Environment is ready for Ansible execution
- Execution time under 5 minutes
- No manual intervention required

## Technical Analysis

### Platform Detection Strategy
```bash
# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ -f /etc/os-release ]]; then
    # Linux detection
    . /etc/os-release
    case $ID in
        ubuntu|debian|pop)
            OS="debian-based"
            PKG_MGR="apt"
            ;;
        alpine)
            OS="alpine"
            PKG_MGR="apk"
            ;;
        *)
            echo "Unsupported Linux distribution: $ID"
            exit 1
            ;;
    esac
else
    echo "Unsupported operating system: $OSTYPE"
    exit 1
fi
```

### Tool Installation Approach

#### Git Installation
- **Debian/Ubuntu**: `apt update && apt install -y git`
- **Alpine**: `apk update && apk add git`
- **macOS**: Usually pre-installed, verify and install via Xcode command line tools if needed

#### asdf Installation
- Download from official repository: `https://github.com/asdf-vm/asdf.git`
- Clone to `~/.asdf`
- Add to shell profile (temporary for script execution)
- Install required plugins (python, direnv)

#### Homebrew Installation (macOS only)
- Use official installation script: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- Configure PATH for immediate use

### Error Handling Strategy

#### Network Connectivity
```bash
check_connectivity() {
    if ! curl -s --head https://github.com >/dev/null; then
        echo "Error: No internet connectivity or GitHub is unreachable"
        exit 1
    fi
}
```

#### Permission Handling
```bash
check_permissions() {
    if [[ $EUID -eq 0 ]] && [[ "$ALLOW_ROOT" != "true" ]]; then
        echo "Warning: Running as root. Set ALLOW_ROOT=true if intentional."
        exit 1
    fi
}
```

#### Installation Verification
```bash
verify_installation() {
    local tool=$1
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "Error: $tool installation failed or not in PATH"
        return 1
    fi
    echo "✓ $tool installed successfully"
}
```

## Implementation Plan

### Phase 1: Core Structure and Platform Detection
**Timeline**: 1-2 hours
**Tasks**:
- [ ] Create basic script structure with proper shebang
- [ ] Implement OS and distribution detection
- [ ] Add logging functions (info, warn, error)
- [ ] Implement basic error handling framework
- [ ] Add connectivity checks

**Deliverables**:
- Working script skeleton with platform detection
- Basic error handling and logging

### Phase 2: Tool Installation Implementation
**Timeline**: 3-4 hours
**Tasks**:
- [ ] Implement git installation for all platforms
- [ ] Implement asdf installation with proper PATH setup
- [ ] Implement Homebrew installation for macOS
- [ ] Add installation verification functions
- [ ] Implement idempotency checks (skip if already installed)

**Deliverables**:
- Complete tool installation functionality
- Verification and idempotency features

### Phase 3: Environment Preparation
**Timeline**: 2-3 hours
**Tasks**:
- [ ] Implement project directory creation and cloning
- [ ] Add direnv installation and setup
- [ ] Configure shell integration for installed tools
- [ ] Implement post-installation verification
- [ ] Add cleanup functions for failed installations

**Deliverables**:
- Complete environment preparation functionality
- Robust error recovery mechanisms

### Phase 4: Testing and Refinement
**Timeline**: 4-6 hours
**Tasks**:
- [ ] Test on Ubuntu 22.04 LTS (clean VM)
- [ ] Test on Debian 12 (clean VM)
- [ ] Test on Alpine Linux (clean container)
- [ ] Test on macOS (clean system)
- [ ] Test idempotency (run script multiple times)
- [ ] Test error scenarios (network failures, permission issues)
- [ ] Performance optimization
- [ ] Documentation and inline comments

**Deliverables**:
- Fully tested, production-ready script
- Test results documentation
- Performance benchmarks

## Script Structure

```bash
#!/bin/bash
# scripts/prepare - Bootstrap script for OS initialization
set -euo pipefail

# Configuration
readonly SCRIPT_VERSION="1.0.0"
readonly ASDF_VERSION="v0.14.0"
readonly PROJECT_REPO="https://github.com/geoffjay/init"
readonly PROJECTS_DIR="$HOME/Projects"
readonly PROJECT_DIR="$PROJECTS_DIR/init"

# Logging functions
log_info() { echo "[INFO] $*"; }
log_warn() { echo "[WARN] $*" >&2; }
log_error() { echo "[ERROR] $*" >&2; }

# Main functions
detect_platform() { ... }
check_prerequisites() { ... }
install_git() { ... }
install_asdf() { ... }
install_homebrew() { ... }
setup_project() { ... }
verify_environment() { ... }
cleanup_on_error() { ... }

# Main execution
main() {
    log_info "Starting OS bootstrap process (version $SCRIPT_VERSION)"
    
    detect_platform
    check_prerequisites
    
    install_git
    install_asdf
    [[ "$OS" == "macos" ]] && install_homebrew
    
    setup_project
    verify_environment
    
    log_info "Bootstrap completed successfully!"
    log_info "Next steps:"
    log_info "  cd $PROJECT_DIR"
    log_info "  direnv allow"
    log_info "  asdf install"
    log_info "  ansible-playbook -k playbook.yml"
}

# Execute main function with error handling
trap cleanup_on_error ERR
main "$@"
```

## Testing Strategy

### Test Environments
1. **Ubuntu 22.04 LTS** - Primary Debian-based testing
2. **Debian 12** - Alternative Debian-based testing
3. **Alpine Linux 3.18+** - apk-based testing
4. **macOS 13+** - macOS testing
5. **Pop!_OS 22.04** - Ubuntu derivative testing

### Test Scenarios
1. **Clean Installation**: Fresh OS with minimal packages
2. **Partial Installation**: Some tools already installed
3. **Complete Re-run**: Script executed on already-configured system
4. **Network Failure**: Simulated network connectivity issues
5. **Permission Issues**: Non-sudo execution, read-only directories
6. **Disk Space**: Limited disk space scenarios

### Automated Testing
```bash
# test/test-prepare.sh
#!/bin/bash
# Automated testing framework for prepare script

test_clean_ubuntu() { ... }
test_clean_alpine() { ... }
test_idempotency() { ... }
test_error_handling() { ... }
```

## Security Considerations

### Download Security
- Use HTTPS for all downloads
- Verify checksums where possible
- Validate downloaded content before execution

### Permission Model
- Minimize sudo usage
- Install user-level tools in home directory where possible
- Clear documentation of required permissions

### Input Validation
- Validate environment variables
- Sanitize paths and user inputs
- Prevent command injection

## Deployment Strategy

### Script Distribution
- Host script in GitHub repository
- Ensure raw file access via GitHub
- Consider CDN for improved performance

### Version Management
- Include version information in script
- Maintain backwards compatibility
- Clear upgrade path for future versions

## Monitoring and Maintenance

### Success Metrics
- Installation success rate across platforms
- Average execution time
- Error rates and common failure points
- User feedback and issue reports

### Maintenance Tasks
- Regular testing on new OS versions
- Dependency updates (asdf version, etc.)
- Performance optimizations
- Documentation updates

## Risk Mitigation

### High-Risk Areas
1. **Network Dependencies**: Script fails without internet
   - *Mitigation*: Clear error messages, connectivity checks
2. **Platform Changes**: OS updates break compatibility
   - *Mitigation*: Regular testing, version detection
3. **Tool Updates**: asdf or Homebrew API changes
   - *Mitigation*: Pin versions, test before releases

### Rollback Strategy
- Document manual cleanup procedures
- Provide uninstall script for development/testing
- Clear documentation of all system changes

## Success Definition

The `scripts/prepare` bootstrap script will be considered complete when:

1. ✅ It successfully installs on all supported platforms
2. ✅ Execution time is consistently under 5 minutes
3. ✅ All post-installation commands execute successfully
4. ✅ Script handles errors gracefully with meaningful messages
5. ✅ Idempotency is verified across all test scenarios
6. ✅ Security review is completed and approved
7. ✅ Documentation is complete and accurate
8. ✅ Automated testing covers all critical scenarios

## Next Steps

After completion of this script:
1. Integration testing with subsequent Ansible playbooks
2. User acceptance testing with fresh OS installations
3. Performance optimization based on real-world usage
4. Documentation of common issues and troubleshooting
5. Preparation for Phase 2: Ansible orchestration development 