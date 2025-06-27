# Development Plan: Environment Management System

## Overview

This document outlines the development plan for implementing the environment management system that provides consistent, reproducible development environments across different machines and operating systems using asdf, direnv, and Python virtual environments.

## Objectives

- Provide consistent development tool versions across environments
- Automate environment setup and activation using modern tooling
- Isolate project dependencies from system-wide installations
- Enable seamless switching between different project environments
- Ensure reproducible environments across all supported platforms

## Requirements Analysis

### Core Requirements
1. **Version Management with asdf**: Manage Python, uv, and additional development tools
2. **Directory Environment with direnv**: Automatic environment activation
3. **Python Virtual Environment**: Isolated Python environment for project dependencies
4. **Environment Reproducibility**: Exact environment reproduction across machines
5. **Cross-Platform Consistency**: Same behavior on Linux and macOS

### Success Criteria
- Environment setup completes in under 2 minutes
- 100% consistency in tool versions across different machines
- Zero manual environment activation required
- All Python operations isolated to project environment
- Smooth development experience with automatic tool switching

## Technical Analysis

### Tool Integration Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                     Development Environment                 │
├─────────────────────────────────────────────────────────────┤
│  asdf (Tool Version Management)                            │
│  ├── Python 3.13.5                                        │
│  ├── uv 0.7.13                                            │
│  └── [Future tools: Node.js, Ruby, etc.]                  │
├─────────────────────────────────────────────────────────────┤
│  direnv (Environment Activation)                           │
│  ├── Auto-activate asdf tools                             │
│  ├── Auto-activate Python virtual environment             │
│  └── Set project-specific environment variables           │
├─────────────────────────────────────────────────────────────┤
│  Python Virtual Environment                                │
│  ├── Ansible and dependencies                             │
│  ├── Project development tools                            │
│  └── Isolated from system Python                          │
└─────────────────────────────────────────────────────────────┘
```

### Configuration File Strategy
```
Project Root/
├── .tool-versions          # asdf tool version specifications
├── .envrc                  # direnv environment configuration
├── requirements.txt        # Core project dependencies
├── requirements-dev.txt    # Development dependencies (future)
├── pyproject.toml         # Python project configuration
└── .python-version        # Python version for compatibility
```

### Performance Targets
- Environment activation time: < 1 second
- Tool installation time: < 2 minutes
- Directory switching time: < 0.5 seconds
- Virtual environment creation: < 10 seconds

## Current State (Completed by scripts/prepare)

The following components have been implemented and are working:

### ✅ Completed Components
- **asdf Installation**: Installed via Homebrew (macOS) or binary download (Linux)
- **asdf Plugins**: Python and uv plugins are installed and functional
- **direnv Installation**: Installed via system package managers (not asdf-managed)
- **Shell Integration**: asdf and direnv hooks configured in shell profiles
- **Tool Versions**: `.tool-versions` file exists with specified versions
- **Tool Installation**: `asdf install` works and installs specified tools

### ✅ Working Environment State
- asdf manages Python (3.13.5) and uv (0.7.13) versions
- direnv automatically activates environment when entering project directory
- Shell integration provides automatic tool switching
- Cross-platform compatibility tested and working

## Implementation Plan

### Phase 1: Python Virtual Environment and uv Integration
**Timeline**: 3-4 hours
**Priority**: High

**Tasks**:
- [ ] Create comprehensive `.envrc` configuration file
- [x] Configure Python virtual environment activation via direnv
- [x] Set up uv for dependency management (no requirements.txt files)
- [ ] Configure project-specific environment variables
- [ ] Set up Ansible-specific environment configuration
- [ ] Test environment activation and tool availability

**Deliverables**:
- Complete `.envrc` configuration with Python virtual environment
- uv-based dependency management
- Project-specific environment variables
- Ansible execution environment

**Key Implementation Details**:
```bash
# .envrc content
#!/usr/bin/env bash
# Environment configuration for direnv

# Enable strict error handling
set -euo pipefail

# Use asdf for tool version management
use asdf

# Activate Python virtual environment using layout python
layout python

# Project-specific environment variables
export PROJECT_ROOT="$PWD"
export PROJECT_NAME="init"

# Python environment configuration
export PYTHONPATH="$PROJECT_ROOT:${PYTHONPATH:-}"
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1

# Ansible configuration
export ANSIBLE_CONFIG="$PROJECT_ROOT/ansible.cfg"
export ANSIBLE_INVENTORY="$PROJECT_ROOT/inventory/"
export ANSIBLE_ROLES_PATH="$PROJECT_ROOT/roles"
export ANSIBLE_HOST_KEY_CHECKING=False

# Development environment settings
export DEVELOPMENT=true
export LOG_LEVEL=INFO
export DEBUG=false

# Performance optimizations
export ANSIBLE_PIPELINING=True
export ANSIBLE_SSH_PIPELINING=True

# Tool-specific configurations
export UV_CACHE_DIR="$HOME/.cache/uv"
export PIP_CACHE_DIR="$HOME/.cache/pip"

# Load additional environment files if they exist
if [[ -f "$PROJECT_ROOT/.env.local" ]]; then
    source "$PROJECT_ROOT/.env.local"
fi

echo "✅ Environment activated for $PROJECT_NAME"
echo "🐍 Python: $(python --version)"
echo "📦 UV: $(uv --version)"
echo "🏠 Project: $PROJECT_ROOT"
```

```toml
# pyproject.toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "init"
version = "1.0.0"
description = "OS Initialization and Configuration"
dependencies = [
    "ansible>=8.0.0",
    "ansible-core>=2.15.0",
    "jinja2>=3.1.0",
    "pyyaml>=6.0.0",
    "paramiko>=3.0.0",
]

[project.optional-dependencies]
dev = [
    "ansible-lint>=6.0.0",
    "molecule>=6.0.0",
]
```

**Testing**:
- Test Python virtual environment creation and activation
- Verify uv is available and functional within the environment
- Test dependency installation via uv (e.g., `uv add ansible`)
- Validate environment variables are correctly set
- Test Ansible execution within virtual environment
- Verify cross-platform compatibility (Linux and macOS)

### Phase 2: uv Dependency Management
**Timeline**: 2-3 hours
**Priority**: High

**Tasks**:
- [x] Initialize Python project with uv (`uv init`)
- [ ] Install core dependencies via uv (`uv add ansible ansible-core`)
- [ ] Configure development dependencies
- [ ] Set up uv scripts for common tasks
- [ ] Test dependency installation and management
- [ ] Verify Ansible is executable within the environment

**Deliverables**:
- Fully configured uv project
- Core dependencies installed via uv
- Development workflow using uv commands

**Key Implementation Details**:
```bash
# Initialize uv project and install dependencies
uv init --python 3.13.5
uv add ansible>=8.0.0
uv add ansible-core>=2.15.0
uv add jinja2>=3.1.0
uv add pyyaml>=6.0.0
uv add paramiko>=3.0.0

# Development dependencies
uv add --dev ansible-lint
uv add --dev molecule

# Verify installation
uv run ansible --version
uv run ansible-playbook --version
```

**Testing**:
- Test uv project initialization
- Verify dependency installation and resolution
- Test Ansible execution via `uv run`
- Validate development dependencies are separate
- Test dependency updates and management

### Phase 3: Documentation and Validation
**Timeline**: 3-4 hours
**Priority**: Critical

**Tasks**:
- [ ] Document the `.envrc` configuration and environment variables
- [ ] Create uv workflow documentation (no requirements.txt)
- [ ] Write environment troubleshooting guide
- [ ] Document integration with existing prepare script
- [ ] Create testing and validation procedures
- [ ] Document cross-platform considerations

**Deliverables**:
- Environment management documentation
- uv workflow and dependency management guide
- Troubleshooting and validation documentation

## Remaining Work Summary

The environment management implementation has been significantly simplified due to the foundation laid by the `scripts/prepare` script. The remaining work focuses on:

1. **Creating the `.envrc` file** - This is the primary configuration needed for direnv to activate the Python virtual environment and set project-specific environment variables.

2. **Setting up uv for dependency management** - Initialize the project with uv and install the necessary dependencies without using requirements.txt files.

3. **Documentation** - Document the environment setup and uv workflow for future reference.

## Estimated Timeline

With the bootstrap script completing most of the heavy lifting, the remaining environment management work is reduced to:

- **Phase 1**: 3-4 hours (`.envrc` configuration and testing)
- **Phase 2**: 2-3 hours (uv project setup and dependency management)  
- **Phase 3**: 3-4 hours (documentation and validation)

**Total**: 8-11 hours (reduced from the original 20+ hours)

## Configuration Files to Create

### .envrc (Primary deliverable)
```bash
#!/usr/bin/env bash
# Environment configuration for direnv

# Enable strict error handling
set -euo pipefail

# Use asdf for tool version management
use asdf

# Activate Python virtual environment using layout python
layout python

# Project-specific environment variables
export PROJECT_ROOT="$PWD"
export PROJECT_NAME="init"

# Python environment configuration
export PYTHONPATH="$PROJECT_ROOT:${PYTHONPATH:-}"
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1

# Ansible configuration
export ANSIBLE_CONFIG="$PROJECT_ROOT/ansible.cfg"
export ANSIBLE_INVENTORY="$PROJECT_ROOT/inventory/"
export ANSIBLE_ROLES_PATH="$PROJECT_ROOT/roles"
export ANSIBLE_HOST_KEY_CHECKING=False

# Development environment settings
export DEVELOPMENT=true
export LOG_LEVEL=INFO
export DEBUG=false

# Performance optimizations
export ANSIBLE_PIPELINING=True
export ANSIBLE_SSH_PIPELINING=True

# Tool-specific configurations
export UV_CACHE_DIR="$HOME/.cache/uv"
export PIP_CACHE_DIR="$HOME/.cache/pip"

# Load additional environment files if they exist
if [[ -f "$PROJECT_ROOT/.env.local" ]]; then
    source "$PROJECT_ROOT/.env.local"
fi

echo "✅ Environment activated for $PROJECT_NAME"
echo "🐍 Python: $(python --version)"
echo "📦 UV: $(uv --version)"
echo "🏠 Project: $PROJECT_ROOT"
```

### pyproject.toml (uv project configuration)
```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "init"
version = "1.0.0"
description = "OS Initialization and Configuration"
dependencies = [
    "ansible>=8.0.0",
    "ansible-core>=2.15.0",
    "jinja2>=3.1.0",
    "pyyaml>=6.0.0",
    "paramiko>=3.0.0",
]

[project.optional-dependencies]
dev = [
    "ansible-lint>=6.0.0",
    "molecule>=6.0.0",
]

[tool.uv]
dev-dependencies = [
    "ansible-lint>=6.0.0",
    "molecule>=6.0.0",
]
```

## Risk Management

### Potential Risks and Mitigation

1. **Tool Version Conflicts**
   - Risk: Conflicting tool versions between system and asdf
   - Mitigation: Clear installation order, system tool isolation, comprehensive testing

2. **Environment Activation Failures**
   - Risk: direnv not working correctly or not installed
   - Mitigation: Robust installation checks, fallback mechanisms, clear error messages

3. **Performance Degradation**
   - Risk: Slow environment activation affecting productivity
   - Mitigation: Performance monitoring, optimization strategies, lazy loading

4. **Cross-Platform Compatibility**
   - Risk: Environment behavior differences between Linux and macOS
   - Mitigation: Platform-specific testing, conditional configurations, comprehensive validation

5. **Dependency Management Issues**
   - Risk: Python package conflicts or installation failures
   - Mitigation: Virtual environment isolation, dependency pinning, alternative installation methods

## Quality Assurance

### Testing Strategy
```bash
# Automated testing script
#!/bin/bash
# test/test-environment.sh

set -euo pipefail

test_asdf_installation() {
    echo "Testing asdf tool installation..."
    asdf install
    asdf current python | grep "3.13.5"
    asdf current uv | grep "0.7.13"
}

test_direnv_activation() {
    echo "Testing direnv activation..."
    cd "$PROJECT_ROOT"
    direnv allow
    [[ -n "${VIRTUAL_ENV:-}" ]] || { echo "Virtual env not activated"; exit 1; }
}

test_python_environment() {
    echo "Testing Python environment..."
    python --version | grep "3.13.5"
    pip list | grep ansible
    which python | grep ".venv"
}

test_ansible_execution() {
    echo "Testing Ansible execution..."
    ansible --version
    ansible-playbook --version
    ansible localhost -m ping
}

# Run all tests
test_asdf_installation
test_direnv_activation  
test_python_environment
test_ansible_execution

echo "✅ All environment tests passed!"
```

### Performance Benchmarks
- Environment activation: < 1 second
- Tool switching: < 0.5 seconds
- Virtual environment creation: < 10 seconds
- Dependency installation: < 2 minutes

### Validation Criteria
- All specified tools available at correct versions
- Python virtual environment properly isolated
- Environment variables correctly set
- Ansible executable within virtual environment
- Cross-platform consistency maintained

## Success Metrics

### Performance Metrics
- **Environment Activation**: < 1 second when entering project directory
- **Dependency Installation**: uv dependency operations complete quickly
- **Memory Usage**: Minimal memory footprint for virtual environment
- **Cross-Platform**: Consistent behavior on Linux and macOS

### Functionality Metrics
- **Virtual Environment**: Python virtual environment activated automatically
- **Tool Availability**: Python, uv, and Ansible available within environment
- **Environment Variables**: All required variables set correctly
- **Integration**: Seamless integration with existing prepare script foundation

## Documentation Requirements

### User Documentation
- Environment setup guide
- Tool version management instructions
- Troubleshooting common issues
- Performance optimization tips
- Multi-project workflow guidance

### Developer Documentation
- Environment architecture overview
- Configuration file specifications
- Adding new tools and versions
- Testing and validation procedures
- Performance monitoring and profiling

### Operational Documentation
- Environment backup and restore procedures
- Monitoring and maintenance tasks
- Upgrade and migration procedures
- Security considerations and best practices 