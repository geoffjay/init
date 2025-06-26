# PRD: Bootstrap Script

## Overview
The bootstrap script provides a minimal installation mechanism that can be executed on a fresh operating system installation to prepare the environment for the full initialization process.

## Objectives
- Enable zero-setup initialization on fresh OS installations
- Install only the absolute minimum required tools
- Provide a secure, reliable installation method via web

## Requirements

### Functional Requirements

#### FR-1: Web-based Installation
- **Requirement**: The bootstrap script must be installable via `wget` or `curl`
- **Implementation**: Script available at `scripts/prepare` and accessible via URL pattern: `wget -q -O - https://github.com/geoffjay/init/tree/main/scripts/prepare | sudo /bin/bash`
- **Acceptance Criteria**: 
  - Script can be downloaded and executed in a single command
  - Works on both fresh Linux and macOS installations
  - Requires minimal prerequisites (only standard tools like wget/curl)

#### FR-2: Minimum Tool Installation
- **Requirement**: Install only essential tools needed for the full setup process
- **Tools Required**:
  - `git` (all systems)
  - `asdf` (all systems) 
  - `brew` (macOS only)
- **Acceptance Criteria**:
  - All specified tools are installed and functional
  - No additional tools are installed beyond requirements
  - Installation works across supported operating systems

#### FR-3: Environment Preparation
- **Requirement**: Prepare the environment for the main configuration process
- **Commands to Enable**:
  - `mkdir ~/Projects && git clone https://github.com/geoffjay/init ~/Projects/init && cd ~/Projects/init`
  - `direnv allow`
  - `asdf install`
- **Acceptance Criteria**:
  - All commands execute successfully after bootstrap
  - Project is cloned to correct location
  - Environment is ready for Ansible execution

### Non-Functional Requirements

#### NFR-1: Idempotency
- Script can be run multiple times without adverse effects
- Existing installations are detected and not reinstalled unnecessarily

#### NFR-2: Error Handling
- Graceful failure with meaningful error messages
- Network failures are handled appropriately
- Permission issues are clearly communicated

#### NFR-3: Security
- Script validates downloads where possible
- Uses secure download methods (HTTPS)
- Minimal privilege escalation (only when necessary)

## Supported Platforms
- **Linux**: Debian, Ubuntu, Pop!_OS (apt-based), Alpine Linux (apk-based)
- **macOS**: Latest supported versions

## Dependencies
- Standard system tools (wget/curl, bash, sudo)
- Internet connectivity
- Appropriate system permissions

## Success Metrics
- Script completes successfully on 100% of supported clean OS installations
- Average execution time under 5 minutes
- Zero manual intervention required after execution 