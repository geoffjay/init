# Development Plan: Ansible Orchestration System

## Overview

This document outlines the development plan for implementing the Ansible orchestration system that will serve as the primary configuration mechanism for OS initialization and user environment setup. The system will replace custom shell scripts with declarative, idempotent playbooks.

## Objectives

- Implement centralized configuration through Ansible playbooks
- Create OS-specific configuration through modular playbooks
- Ensure idempotent, repeatable configuration processes
- Enable single-command system configuration
- Support all platforms defined in specifications

## Requirements Analysis

### Core Requirements
1. **Single Entry Point**: All configuration accessible through `ansible-playbook -k playbook.yml`
2. **Modular Structure**: OS-specific and functional playbooks
3. **Package Manager Integration**: Use native Ansible modules for apt, apk, brew
4. **Python Environment**: All operations within project virtual environment
5. **Shell Configuration**: Configure zsh as default shell
6. **Cross-Platform Support**: Linux (Debian-based, Alpine), macOS

### Success Criteria
- Single command configures entire system
- 100% of configuration tasks use Ansible modules
- Zero custom shell scripts for system configuration
- Support for all specified OS platforms
- Idempotent operations (safe to run multiple times)

## Technical Analysis

### Project Structure Implementation
```
├── playbook.yml            # Main entry point playbook
├── inventory/
│   ├── localhost.yml       # Local host configuration
│   └── group_vars/
│       ├── all.yml         # Variables for all hosts
│       ├── linux.yml       # Linux-specific variables
│       └── macos.yml       # macOS-specific variables
├── playbooks/
│   ├── main.yml           # Primary orchestration playbook
│   ├── linux/
│   │   ├── common.yml     # Common Linux tasks
│   │   ├── apt-based.yml  # Debian/Ubuntu specific
│   │   └── apk-based.yml  # Alpine specific
│   ├── macos/
│   │   └── common.yml     # macOS specific tasks
│   └── common/
│       ├── shell.yml      # Shell configuration
│       ├── development.yml # Development tools
│       └── python.yml     # Python environment
```

### Platform Detection Strategy
```yaml
# In playbooks/main.yml
- name: Detect operating system
  set_fact:
    os_family: "{{ 'macos' if ansible_os_family == 'Darwin' else 'linux' }}"
    os_distribution: "{{ ansible_distribution | lower }}"
    package_manager: >-
      {%- if ansible_os_family == 'Darwin' -%}
        brew
      {%- elif ansible_distribution in ['Ubuntu', 'Debian', 'Pop'] -%}
        apt
      {%- elif ansible_distribution == 'Alpine' -%}
        apk
      {%- else -%}
        unknown
      {%- endif -%}
```

### Variable Management Strategy
```yaml
# group_vars/all.yml
common_packages:
  - git
  - curl
  - wget
  - vim
  - unzip
  - tar

shell_config:
  default_shell: zsh
  shell_configs:
    - ~/.zshrc
    - ~/.zsh/

# group_vars/linux.yml
linux_packages:
  apt:
    - build-essential
    - cmake
    - software-properties-common
  apk:
    - alpine-sdk
    - cmake
    - ca-certificates

# group_vars/macos.yml
macos_packages:
  - gnu-sed
  - gnu-tar
  - coreutils
```

## Implementation Plan

### Phase 1: Core Infrastructure Setup
**Timeline**: 4-6 hours
**Priority**: Critical

**Tasks**:
- [ ] Create main `playbook.yml` entry point
- [ ] Implement inventory structure (`localhost.yml`)
- [ ] Create group variables for all platforms
- [ ] Implement main orchestration playbook (`playbooks/main.yml`)
- [ ] Add platform detection and variable setup
- [ ] Create basic error handling and logging

**Deliverables**:
- Working Ansible project structure
- Platform detection and variable management
- Entry point playbook that can be executed

**Testing**:
- Verify `ansible-playbook -k playbook.yml` executes without errors
- Test platform detection on all supported systems
- Validate variable loading and platform-specific configurations

### Phase 2: Linux Platform Implementation
**Timeline**: 6-8 hours
**Priority**: High

**Tasks**:
- [ ] Implement `playbooks/linux/common.yml` for shared Linux tasks
- [ ] Create `playbooks/linux/apt-based.yml` for Debian/Ubuntu/Pop!_OS
- [ ] Create `playbooks/linux/apk-based.yml` for Alpine Linux
- [ ] Implement package installation with native Ansible modules
- [ ] Add system service configuration where needed
- [ ] Implement repository configuration (apt sources, apk repos)

**Deliverables**:
- Complete Linux platform support
- Package manager integration via Ansible modules
- Platform-specific optimizations

**Testing**:
- Test on Ubuntu 22.04 LTS
- Test on Debian 12
- Test on Alpine Linux 3.18+
- Verify package installations complete successfully
- Test idempotency (run multiple times)

### Phase 3: macOS Platform Implementation
**Timeline**: 4-6 hours
**Priority**: High

**Tasks**:
- [ ] Implement `playbooks/macos/common.yml`
- [ ] Configure Homebrew integration via Ansible
- [ ] Install Xcode command line tools
- [ ] Configure macOS-specific preferences
- [ ] Implement Homebrew Cask for GUI applications
- [ ] Add macOS system optimization tasks

**Deliverables**:
- Complete macOS platform support
- Homebrew integration
- macOS-specific configurations

**Testing**:
- Test on macOS 13+
- Verify Homebrew installations
- Test Xcode command line tools installation
- Validate macOS preferences configuration

### Phase 4: Shell Configuration Implementation
**Timeline**: 4-5 hours
**Priority**: High

**Tasks**:
- [ ] Implement `playbooks/common/shell.yml`
- [ ] Install zsh on all platforms
- [ ] Configure zsh as default user shell
- [ ] Create zsh configuration files (`~/.zshrc`, `~/.zsh/`)
- [ ] Implement shell history and completion configuration
- [ ] Add aliases and prompt customization
- [ ] Integrate with asdf and direnv

**Deliverables**:
- Complete shell configuration system
- zsh as default shell across platforms
- Enhanced shell experience with completions and history

**Testing**:
- Verify zsh installation and configuration
- Test shell startup time (< 2 seconds)
- Validate command completion and history
- Test integration with asdf and direnv

### Phase 5: Development Tools Installation
**Timeline**: 3-4 hours
**Priority**: Medium

**Tasks**:
- [ ] Implement `playbooks/common/development.yml`
- [ ] Install essential development tools via package managers
- [ ] Configure development tool settings
- [ ] Implement platform-specific development tools
- [ ] Add version control configuration (git global settings)
- [ ] Configure text editors (vim, nano)

**Deliverables**:
- Complete development environment setup
- Essential tools available across platforms
- Configured development tools

**Testing**:
- Verify all development tools are installed and functional
- Test cross-platform consistency
- Validate tool configurations

### Phase 6: Python Environment Integration
**Timeline**: 3-4 hours
**Priority**: Medium

**Tasks**:
- [ ] Implement `playbooks/common/python.yml`
- [ ] Ensure Python virtual environment integration
- [ ] Configure pip and package management
- [ ] Integrate with asdf Python version management
- [ ] Add Python development tools
- [ ] Configure Python path and environment variables

**Deliverables**:
- Integrated Python environment management
- Virtual environment support
- Python development tools

**Testing**:
- Verify Python virtual environment activation
- Test Python package installations
- Validate asdf Python integration

### Phase 7: Integration and Testing
**Timeline**: 6-8 hours
**Priority**: Critical

**Tasks**:
- [ ] End-to-end testing on all supported platforms
- [ ] Performance optimization and tuning
- [ ] Error handling and recovery testing
- [ ] Idempotency testing (multiple runs)
- [ ] Integration testing with bootstrap script
- [ ] Documentation and inline comments
- [ ] Create troubleshooting guide

**Deliverables**:
- Fully tested Ansible orchestration system
- Performance benchmarks
- Comprehensive documentation

**Testing Matrix**:
- Ubuntu 22.04 LTS (x86_64, ARM64)
- Debian 12 (x86_64, ARM64)
- Alpine Linux 3.18+ (x86_64, ARM64)
- macOS 13+ (x86_64, ARM64)
- Pop!_OS 22.04 (x86_64, ARM64)

## Key Implementation Details

### Main Entry Point (playbook.yml)
```yaml
---
- name: OS Initialization and Configuration
  hosts: localhost
  connection: local
  gather_facts: yes
  become: yes
  
  vars:
    ansible_python_interpreter: "{{ ansible_playbook_python }}"
    
  pre_tasks:
    - name: Validate supported platform
      fail:
        msg: "Unsupported platform: {{ ansible_os_family }}/{{ ansible_distribution }}"
      when: >
        not (
          (ansible_os_family == 'Darwin') or
          (ansible_distribution in ['Ubuntu', 'Debian', 'Pop!_OS', 'Alpine'])
        )
    
  tasks:
    - name: Include main orchestration playbook
      include: playbooks/main.yml
      
  handlers:
    - name: Restart shell
      meta: noop
```

### Inventory Configuration (inventory/localhost.yml)
```yaml
all:
  hosts:
    localhost:
      ansible_connection: local
      ansible_host: 127.0.0.1
  children:
    control:
      hosts:
        localhost:
  vars:
    ansible_python_interpreter: "{{ ansible_playbook_python }}"
```

### Platform-Specific Task Example
```yaml
# playbooks/linux/apt-based.yml
---
- name: Update apt cache
  apt:
    update_cache: yes
    cache_valid_time: 3600
  become: yes

- name: Install common packages
  apt:
    name: "{{ common_packages + linux_packages.apt }}"
    state: present
  become: yes

- name: Configure apt repositories
  apt_repository:
    repo: "{{ item }}"
    state: present
  loop: "{{ apt_repositories | default([]) }}"
  become: yes
```

### Shell Configuration Tasks
```yaml
# playbooks/common/shell.yml
---
- name: Install zsh
  package:
    name: zsh
    state: present
  become: yes

- name: Set zsh as default shell
  user:
    name: "{{ ansible_user_id }}"
    shell: /bin/zsh
  become: yes

- name: Create zsh configuration directory
  file:
    path: "{{ ansible_env.HOME }}/.zsh"
    state: directory
    mode: '0755'

- name: Configure zsh
  template:
    src: zshrc.j2
    dest: "{{ ansible_env.HOME }}/.zshrc"
    mode: '0644'
```

## Risk Mitigation

### Potential Risks and Mitigation Strategies

1. **Platform Detection Failures**
   - Risk: Ansible facts not reliable across all platforms
   - Mitigation: Implement fallback detection methods, extensive testing

2. **Package Manager Conflicts**
   - Risk: Different package names across distributions
   - Mitigation: Use distribution-specific variable files, comprehensive mapping

3. **Permission Issues**
   - Risk: Tasks requiring different privilege levels
   - Mitigation: Careful use of `become` directive, privilege separation

4. **Python Environment Conflicts**
   - Risk: System Python vs. virtual environment conflicts
   - Mitigation: Explicit Python interpreter specification, environment isolation

5. **Network Dependencies**
   - Risk: Package installations failing due to network issues
   - Mitigation: Retry mechanisms, offline mode consideration

## Success Metrics

### Performance Targets
- Complete system configuration in under 10 minutes
- Shell configuration completes in under 2 minutes
- Package installations complete without timeout

### Quality Targets
- 100% success rate on clean OS installations
- Zero manual intervention required
- All tasks idempotent (safe to run multiple times)
- Comprehensive error messages for all failure scenarios

### Platform Coverage
- Support for all specified platforms (Ubuntu, Debian, Pop!_OS, Alpine, macOS)
- Both x86_64 and ARM64 architectures
- Multiple versions of each supported platform

## Dependencies

### External Dependencies
- Ansible (installed via Python virtual environment)
- Platform package managers (apt, apk, brew)
- Internet connectivity for package downloads
- System permissions for package installation and shell changes

### Internal Dependencies
- Bootstrap script must complete successfully first
- Python virtual environment must be active
- Project directory structure must be in place
- asdf and direnv must be installed and configured

## Documentation Requirements

### User Documentation
- Single-page quick start guide
- Troubleshooting guide for common issues
- Platform-specific notes and considerations

### Developer Documentation
- Playbook structure and organization
- Variable management and overrides
- Adding support for new platforms
- Testing procedures and requirements

### Operational Documentation
- Error codes and their meanings
- Log file locations and formats
- Recovery procedures for failed installations
- Performance tuning and optimization guides 