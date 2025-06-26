# PRD: Ansible Orchestration

## Overview
The Ansible orchestration system provides the primary configuration mechanism for OS initialization and user environment setup, replacing custom shell scripts with declarative, idempotent playbooks.

## Objectives
- Centralize all configuration through Ansible playbooks
- Provide OS-specific configuration through modular playbooks
- Ensure idempotent, repeatable configuration processes
- Minimize user intervention to a single command execution

## Requirements

### Functional Requirements

#### FR-1: Single Entry Point
- **Requirement**: All configuration accessible through a single Ansible command
- **Implementation**: `ansible-playbook -k playbook.yml` 
- **Acceptance Criteria**:
  - Single command configures entire system
  - Prompts for necessary credentials only
  - No additional manual steps required

#### FR-2: Modular Playbook Structure
- **Requirement**: Playbooks organized by OS type and functional scope
- **Structure Requirements**:
  - OS-specific playbooks (Linux, macOS)
  - Distribution-specific tasks (apt-based, apk-based)
  - Functional groupings (shell config, development tools, etc.)
- **Acceptance Criteria**:
  - Clear separation of concerns
  - Easy to maintain and extend
  - Reusable components across different configurations

#### FR-3: Package Manager Integration
- **Requirement**: Use native package managers through Ansible modules
- **Package Managers**:
  - `apt` for Debian, Ubuntu, Pop!_OS
  - `apk` for Alpine Linux  
  - `brew` for macOS
- **Acceptance Criteria**:
  - No direct shell commands for package installation
  - Leverage Ansible's built-in package modules
  - Handle package manager differences transparently

#### FR-4: Python Environment Management
- **Requirement**: All Python operations within project virtual environment
- **Implementation**: Use `.tool-versions` with asdf for Python version management
- **Acceptance Criteria**:
  - Python dependencies isolated to project environment
  - Ansible execution uses project Python environment
  - No global Python package installations

#### FR-5: Shell Configuration
- **Requirement**: Configure zsh as default user shell
- **Implementation**: Install and configure zsh with appropriate defaults
- **Acceptance Criteria**:
  - zsh installed on all systems
  - Set as user's default shell
  - Basic configuration applied

### Non-Functional Requirements

#### NFR-1: Idempotency
- All playbooks can be run multiple times safely
- State detection and conditional execution
- No unwanted side effects from repeat runs

#### NFR-2: Localhost Focus
- Initial implementation targets localhost only
- Architecture allows for future remote host expansion
- Inventory configuration supports extension

#### NFR-3: Cross-Platform Compatibility
- Playbooks work across supported Linux distributions
- macOS-specific tasks properly isolated
- Graceful handling of unsupported platforms

## Supported Platforms
- **Linux**: 
  - Debian-based (apt): Debian, Ubuntu, Pop!_OS
  - Alpine Linux (apk)
- **macOS**: Latest supported versions

## Architecture

### Playbook Organization
```
playbooks/
├── main.yml              # Entry point playbook
├── linux/
│   ├── common.yml        # Common Linux tasks
│   ├── apt-based.yml     # Debian/Ubuntu specific
│   └── apk-based.yml     # Alpine specific
├── macos/
│   └── common.yml        # macOS specific tasks
└── common/
    ├── shell.yml         # Shell configuration
    ├── development.yml   # Development tools
    └── python.yml        # Python environment
```

### Inventory Structure
```
inventory/
├── localhost.yml         # Local host configuration
└── group_vars/
    ├── all.yml          # Variables for all hosts
    ├── linux.yml       # Linux-specific variables
    └── macos.yml        # macOS-specific variables
```

## Dependencies
- Ansible (installed via Python virtual environment)
- Target system prepared by bootstrap script
- SSH access to localhost (for consistency)

## Success Metrics
- 100% of configuration tasks use Ansible modules
- Zero custom shell scripts for system configuration
- Complete system configuration in single command execution
- Support for all specified OS platforms and package managers 