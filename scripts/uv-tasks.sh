#!/usr/bin/env bash
# uv-tasks.sh - Development workflow scripts for the init project

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper function for colored output
log() {
    echo -e "${GREEN}[uv-tasks]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[uv-tasks]${NC} $1"
}

error() {
    echo -e "${RED}[uv-tasks]${NC} $1"
}

# Display help
show_help() {
    echo "uv-tasks.sh - Development workflow scripts"
    echo ""
    echo "Usage: ./scripts/uv-tasks.sh <command>"
    echo ""
    echo "Available commands:"
    echo "  lint          - Run ansible-lint on the project"
    echo "  test          - Run molecule tests"
    echo "  check         - Run ansible-playbook syntax check"
    echo "  syntax        - Check ansible syntax"
    echo "  env-check     - Check Python and Ansible versions"
    echo "  deps-update   - Update all dependencies"
    echo "  deps-install  - Install/sync all dependencies"
    echo "  deps-dev      - Install development dependencies"
    echo "  deps-export   - Show installed dependencies"
    echo "  clean         - Clean cache and temporary files"
    echo "  help          - Show this help message"
}

# Ansible linting
run_lint() {
    log "Running ansible-lint..."
    if command -v ansible-lint >/dev/null 2>&1; then
        uv run ansible-lint .
    else
        warn "ansible-lint not available, installing dev dependencies first..."
        uv sync --group dev
        uv run ansible-lint .
    fi
}

# Molecule testing
run_test() {
    log "Running molecule tests..."
    if command -v molecule >/dev/null 2>&1; then
        uv run molecule test
    else
        warn "molecule not available, installing dev dependencies first..."
        uv sync --group dev
        uv run molecule test
    fi
}

# Ansible syntax check
run_syntax_check() {
    log "Running ansible syntax check..."
    if [ -f "playbook.yml" ]; then
        uv run ansible-playbook --syntax-check playbook.yml
    elif [ -f "site.yml" ]; then
        uv run ansible-playbook --syntax-check site.yml
    else
        warn "No playbook.yml or site.yml found to check"
    fi
}

# Environment check
run_env_check() {
    log "Checking environment..."
    echo "Python Version:"
    uv run python --version
    echo ""
    echo "UV Version:"
    uv --version
    echo ""
    echo "Ansible Version:"
    uv run ansible --version | head -1
    echo ""
    echo "Virtual Environment:"
    echo "VIRTUAL_ENV: ${VIRTUAL_ENV:-'Not set'}"
    echo ""
    echo "Installed Packages:"
    uv pip list | head -10
}

# Update dependencies
run_deps_update() {
    log "Updating dependencies..."
    uv sync --upgrade
    log "Dependencies updated successfully"
}

# Install dependencies
run_deps_install() {
    log "Installing/syncing dependencies..."
    uv sync
    log "Dependencies installed successfully"
}

# Install dev dependencies
run_deps_dev() {
    log "Installing development dependencies..."
    uv sync --group dev
    log "Development dependencies installed successfully"
}

# Show dependencies
run_deps_export() {
    log "Showing installed dependencies..."
    echo "Dependencies from pyproject.toml:"
    uv pip list
    echo ""
    echo "Lock file status:"
    [ -f "uv.lock" ] && echo "✅ uv.lock exists ($(wc -l < uv.lock) lines)" || echo "❌ uv.lock missing"
}

# Clean cache and temporary files
run_clean() {
    log "Cleaning cache and temporary files..."
    
    # Clean uv cache
    if [ -d "$HOME/.cache/uv" ]; then
        rm -rf "$HOME/.cache/uv"
        log "Cleaned uv cache"
    fi
    
    # Clean pip cache
    if [ -d "$HOME/.cache/pip" ]; then
        rm -rf "$HOME/.cache/pip"
        log "Cleaned pip cache"
    fi
    
    # Clean Python cache
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    find . -name "*.pyc" -delete 2>/dev/null || true
    
    # Clean ansible logs
    [ -f "ansible.log" ] && rm ansible.log && log "Removed ansible.log"
    
    log "Cleanup completed"
}

# Main script logic
main() {
    if [ $# -eq 0 ]; then
        error "No command provided"
        show_help
        exit 1
    fi
    
    case "$1" in
        lint)
            run_lint
            ;;
        test)
            run_test
            ;;
        check|syntax)
            run_syntax_check
            ;;
        env-check)
            run_env_check
            ;;
        deps-update)
            run_deps_update
            ;;
        deps-install)
            run_deps_install
            ;;
        deps-dev)
            run_deps_dev
            ;;
        deps-export)
            run_deps_export
            ;;
        clean)
            run_clean
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@" 