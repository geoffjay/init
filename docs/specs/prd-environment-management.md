# PRD: Environment Management

## Overview
The environment management system provides consistent, reproducible development environments across different machines and operating systems using modern tooling like asdf, direnv, and Python virtual environments.

## Objectives
- Provide consistent development tool versions across environments
- Automate environment setup and activation
- Isolate project dependencies from system-wide installations
- Enable seamless switching between different project environments

## Requirements

### Functional Requirements

#### FR-1: Version Management with asdf
- **Requirement**: Use asdf for managing development tool versions
- **Tools to Manage**:
  - Python (as specified in `.tool-versions`)
  - uv (as specified in `.tool-versions`)
  - Additional tools as needed (Node.js, Ruby, etc.)
- **Acceptance Criteria**:
  - `.tool-versions` file defines all tool versions
  - `asdf install` command installs all specified versions
  - Tool versions are consistent across different machines
  - Automatic version switching when entering project directory

#### FR-2: Directory Environment with direnv
- **Requirement**: Automatic environment activation using direnv
- **Implementation**: `.envrc` file configures project environment
- **Acceptance Criteria**:
  - Environment variables automatically set when entering directory
  - Python virtual environment automatically activated
  - PATH modifications applied automatically
  - `direnv allow` enables environment after bootstrap

#### FR-3: Python Virtual Environment
- **Requirement**: Isolated Python environment for all project dependencies
- **Implementation**: Use project-specific virtual environment
- **Dependencies**:
  - Ansible and related tools
  - Python development dependencies
  - Tools for project maintenance
- **Acceptance Criteria**:
  - Virtual environment created automatically
  - All Python dependencies isolated from system
  - Ansible runs within virtual environment
  - Dependencies managed via uv.lock file

#### FR-4: Environment Reproducibility
- **Requirement**: Exact environment reproduction across machines
- **Implementation**: 
  - Pin all tool versions in `.tool-versions`
  - Lock Python dependencies
  - Document environment setup process
- **Acceptance Criteria**:
  - Same environment can be recreated on any supported system
  - No version drift between different installations
  - Fast environment setup (< 2 minutes after bootstrap)

### Non-Functional Requirements

#### NFR-1: Automatic Activation
- Environment activates without manual intervention
- Seamless switching between projects with different environments
- No manual source commands required

#### NFR-2: Performance
- Fast environment activation (< 1 second)
- Minimal overhead when working in project
- Efficient tool version switching

#### NFR-3: Cross-Platform Consistency
- Same environment behavior on Linux and macOS
- Tool versions work across supported platforms
- Environment configuration platform-agnostic where possible

## Configuration Files

### .tool-versions
```
python 3.13.5
uv 0.7.13
# Additional tools as needed
```

### .envrc
```bash
# Activate asdf tools
use asdf

# Activate Python virtual environment
layout python

# Additional environment variables as needed
export PROJECT_ROOT=$PWD
```

### Requirements Management
- `pyproject.toml` - Project configuration and dependencies

## Supported Platforms
- **Linux**: All distributions supported by bootstrap script
- **macOS**: Latest supported versions
- **Windows**: Future consideration (WSL2 support)

## Integration Points

### Bootstrap Script Integration
- Bootstrap script installs asdf
- Ensures direnv is available
- Prepares system for environment management

### Ansible Integration
- Ansible runs within managed Python environment
- Playbooks can reference tool versions from `.tool-versions`
- Environment management tasks in Ansible playbooks

## Dependencies
- asdf (installed by bootstrap script)
- direnv (installed by bootstrap script or Ansible)
- Python (managed by asdf)
- uv (managed by asdf, for fast Python package management)

## Success Metrics
- Environment setup completes in under 2 minutes
- 100% consistency in tool versions across different machines  
- Zero manual environment activation required
- All Python operations isolated to project environment
- Smooth development experience with automatic tool switching 