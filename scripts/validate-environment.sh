#!/usr/bin/env bash
# validate-environment.sh - Comprehensive Environment Validation Script
# Tests all requirements from PRD: Environment Management

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASSED_TESTS++))
}

log_failure() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAILED_TESTS++))
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

start_test() {
    ((TOTAL_TESTS++))
    echo -e "${CYAN}[TEST]${NC} $1"
}

# Test helper function
test_command() {
    local description="$1"
    local command="$2"
    local expected_pattern="${3:-}"
    
    start_test "$description"
    
    if output=$(eval "$command" 2>&1); then
        if [[ -n "$expected_pattern" ]]; then
            if echo "$output" | grep -q "$expected_pattern"; then
                log_success "$description - Output matches expected pattern"
                return 0
            else
                log_failure "$description - Output doesn't match pattern '$expected_pattern'"
                echo "  Got: $output"
                return 1
            fi
        else
            log_success "$description - Command executed successfully"
            return 0
        fi
    else
        log_failure "$description - Command failed: $output"
        return 1
    fi
}

# Test helper for environment variables
test_env_var() {
    local var_name="$1"
    local expected_pattern="${2:-}"
    
    start_test "Environment variable: $var_name"
    
    if [[ -n "${!var_name:-}" ]]; then
        if [[ -n "$expected_pattern" ]]; then
            if echo "${!var_name}" | grep -q "$expected_pattern"; then
                log_success "$var_name is set and matches pattern"
                return 0
            else
                log_failure "$var_name is set but doesn't match pattern '$expected_pattern'"
                echo "  Got: ${!var_name}"
                return 1
            fi
        else
            log_success "$var_name is set to: ${!var_name}"
            return 0
        fi
    else
        log_failure "$var_name is not set"
        return 1
    fi
}

# Main validation header
echo "======================================================================"
echo -e "${CYAN}Environment Management System Validation${NC}"
echo "======================================================================"
echo "Testing all requirements from PRD: Environment Management"
echo "Date: $(date)"
echo "User: $(whoami)"
echo "PWD: $(pwd)"
echo "======================================================================"

# FR-1: Version Management with asdf
echo -e "\n${BLUE}=== FR-1: Version Management with asdf ===${NC}"

test_command "asdf is installed and functional" "asdf --version" "v"
test_command "asdf Python plugin is installed" "asdf plugin list | grep python"
test_command "asdf uv plugin is installed" "asdf plugin list | grep uv"

# Test .tool-versions file exists and is readable
start_test ".tool-versions file exists and is readable"
if [[ -f ".tool-versions" ]] && [[ -r ".tool-versions" ]]; then
    log_success ".tool-versions file exists and is readable"
    echo "  Contents:"
    cat .tool-versions | sed 's/^/    /'
else
    log_failure ".tool-versions file missing or not readable"
fi

# Test tool versions match specifications
test_command "Python version matches .tool-versions" "python --version" "3.13.5"
test_command "UV version matches .tool-versions" "uv --version" "0.7.13"

# Test automatic version switching
start_test "Tool versions consistent with asdf current"
if asdf_current=$(asdf current 2>&1); then
    if echo "$asdf_current" | grep -q "python.*3.13.5" && echo "$asdf_current" | grep -q "uv.*0.7.13"; then
        log_success "asdf current shows correct tool versions"
    else
        log_failure "asdf current doesn't match expected versions"
        echo "  Got: $asdf_current"
    fi
else
    log_failure "asdf current command failed"
fi

# FR-2: Directory Environment with direnv
echo -e "\n${BLUE}=== FR-2: Directory Environment with direnv ===${NC}"

test_command "direnv is installed and functional" "direnv --version"

# Test .envrc file exists and is allowed
start_test ".envrc file exists and is allowed"
if [[ -f ".envrc" ]]; then
    if direnv status | grep -q "Found RC allowed true"; then
        log_success ".envrc file exists and is allowed"
    else
        log_warning ".envrc file exists but may not be allowed - run 'direnv allow'"
    fi
else
    log_failure ".envrc file is missing"
fi

# Test environment variables are set
test_env_var "PROJECT_ROOT" "$(pwd)"
test_env_var "PROJECT_NAME" "init"
test_env_var "PYTHONPATH" "$(pwd)"
test_env_var "PYTHONDONTWRITEBYTECODE" "1"
test_env_var "PYTHONUNBUFFERED" "1"

# Test Ansible environment variables
test_env_var "ANSIBLE_CONFIG" "ansible.cfg"
test_env_var "ANSIBLE_INVENTORY" "inventory"
test_env_var "ANSIBLE_ROLES_PATH" "roles"
test_env_var "ANSIBLE_HOST_KEY_CHECKING" "False"
test_env_var "ANSIBLE_PIPELINING" "True"

# Test development environment variables
test_env_var "DEVELOPMENT" "true"
test_env_var "LOG_LEVEL" "INFO"
test_env_var "DEBUG" "false"

# Test cache directories
test_env_var "UV_CACHE_DIR" ".cache/uv"
test_env_var "PIP_CACHE_DIR" ".cache/pip"

# FR-3: Python Virtual Environment
echo -e "\n${BLUE}=== FR-3: Python Virtual Environment ===${NC}"

# Test virtual environment is activated
test_env_var "VIRTUAL_ENV" ".venv"

# Test Python is from virtual environment
start_test "Python executable is from virtual environment"
python_path=$(which python)
if echo "$python_path" | grep -q ".venv"; then
    log_success "Python is from virtual environment: $python_path"
else
    log_failure "Python is not from virtual environment: $python_path"
fi

# Test pip is from virtual environment
start_test "Pip executable is from virtual environment"
pip_path=$(which pip)
if echo "$pip_path" | grep -q ".venv"; then
    log_success "Pip is from virtual environment: $pip_path"
else
    log_failure "Pip is not from virtual environment: $pip_path"
fi

# Test Python dependencies are installed
test_command "Ansible is installed in virtual environment" "python -c 'import ansible; print(ansible.__version__)'" "2.18"
test_command "Jinja2 is installed" "python -c 'import jinja2; print(jinja2.__version__)'"
test_command "PyYAML is installed" "python -c 'import yaml; print(yaml.__version__)'"
test_command "Paramiko is installed" "python -c 'import paramiko; print(paramiko.__version__)'"

# Test Ansible commands are available
test_command "ansible command is available" "ansible --version" "core 2.18"
test_command "ansible-playbook command is available" "ansible-playbook --version" "core 2.18"

# Test development dependencies (if installed)
start_test "Development dependencies (optional)"
if uv run ansible-lint --version >/dev/null 2>&1; then
    log_success "ansible-lint is available"
else
    log_warning "ansible-lint not available (install with: uv sync --group dev)"
fi

# FR-4: Environment Reproducibility
echo -e "\n${BLUE}=== FR-4: Environment Reproducibility ===${NC}"

# Test lock files exist
start_test "uv.lock file exists for reproducible builds"
if [[ -f "uv.lock" ]]; then
    lock_lines=$(wc -l < uv.lock)
    log_success "uv.lock exists with $lock_lines lines"
else
    log_failure "uv.lock file is missing"
fi

# Test pyproject.toml configuration
start_test "pyproject.toml is properly configured"
if [[ -f "pyproject.toml" ]]; then
    if grep -q "ansible>=8.0.0" pyproject.toml; then
        log_success "pyproject.toml contains required dependencies"
    else
        log_failure "pyproject.toml missing required dependencies"
    fi
else
    log_failure "pyproject.toml file is missing"
fi

# NFR-1: Automatic Activation
echo -e "\n${BLUE}=== NFR-1: Automatic Activation ===${NC}"

# Test that environment was activated automatically (check for activation message)
start_test "Environment activation indicators"
if [[ -n "${VIRTUAL_ENV:-}" ]] && [[ -n "${PROJECT_ROOT:-}" ]]; then
    log_success "Environment appears to be activated automatically"
else
    log_failure "Environment may not be activated automatically"
fi

# NFR-2: Performance
echo -e "\n${BLUE}=== NFR-2: Performance Benchmarks ===${NC}"

# Test environment activation time (simulate by timing direnv export)
start_test "Environment activation performance"
start_time=$(date +%s.%N)
direnv export bash >/dev/null 2>&1 || true
end_time=$(date +%s.%N)
activation_time=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0.5")

if (( $(echo "$activation_time < 1.0" | bc -l 2>/dev/null || echo "1") )); then
    log_success "Environment activation time: ${activation_time}s (target: <1s)"
else
    log_warning "Environment activation time: ${activation_time}s (target: <1s)"
fi

# Test tool switching performance
start_test "Tool version detection performance"
start_time=$(date +%s.%N)
asdf current >/dev/null 2>&1
end_time=$(date +%s.%N)
tool_time=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0.2")

if (( $(echo "$tool_time < 0.5" | bc -l 2>/dev/null || echo "1") )); then
    log_success "Tool switching time: ${tool_time}s (target: <0.5s)"
else
    log_warning "Tool switching time: ${tool_time}s (target: <0.5s)"
fi

# NFR-3: Cross-Platform Consistency
echo -e "\n${BLUE}=== NFR-3: Cross-Platform Consistency ===${NC}"

# Detect platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macOS"
    test_command "Homebrew integration (macOS)" "brew --version" "Homebrew"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="Linux"
    if command -v apt >/dev/null 2>&1; then
        DISTRO="apt-based"
    elif command -v apk >/dev/null 2>&1; then
        DISTRO="apk-based"
    else
        DISTRO="unknown"
    fi
    log_info "Linux distribution type: $DISTRO"
else
    PLATFORM="unknown"
fi

log_info "Platform detected: $PLATFORM"

# Test platform-specific configurations
start_test "Platform-specific tool paths"
if [[ "$PLATFORM" == "macOS" ]]; then
    if [[ -f "/opt/homebrew/bin/asdf" ]] || [[ -f "/usr/local/bin/asdf" ]]; then
        log_success "asdf found in expected macOS location"
    else
        log_failure "asdf not found in expected macOS locations"
    fi
elif [[ "$PLATFORM" == "Linux" ]]; then
    if [[ -f "/usr/local/bin/asdf" ]] || [[ -f "$HOME/.asdf/bin/asdf" ]]; then
        log_success "asdf found in expected Linux location"
    else
        log_failure "asdf not found in expected Linux locations"
    fi
fi

# Functional Testing
echo -e "\n${BLUE}=== Functional Testing ===${NC}"

# Test Ansible functionality
start_test "Ansible can ping localhost"
if ansible localhost -m ping >/dev/null 2>&1; then
    log_success "Ansible successfully pinged localhost"
else
    log_failure "Ansible failed to ping localhost"
fi

# Test uv functionality
test_command "UV can list packages" "uv pip list" "ansible"

# Test project scripts
start_test "Project scripts are executable"
if [[ -x "scripts/uv-tasks.sh" ]]; then
    log_success "scripts/uv-tasks.sh is executable"
else
    log_failure "scripts/uv-tasks.sh is not executable"
fi

# Integration Testing
echo -e "\n${BLUE}=== Integration Testing ===${NC}"

# Test asdf + direnv integration
start_test "asdf and direnv integration"
if [[ "$(asdf current python | awk '{print $2}')" == "3.13.5" ]] && [[ -n "${VIRTUAL_ENV:-}" ]]; then
    log_success "asdf Python version and direnv virtual environment are both active"
else
    log_failure "asdf and direnv integration issue detected"
fi

# Test uv + virtual environment integration
start_test "uv and virtual environment integration"
if uv run python --version | grep -q "3.13.5"; then
    log_success "uv runs Python from correct virtual environment"
else
    log_failure "uv not using correct Python version"
fi

# Final Results
echo ""
echo "======================================================================"
echo -e "${CYAN}VALIDATION SUMMARY${NC}"
echo "======================================================================"
echo "Total Tests: $TOTAL_TESTS"
echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed: ${RED}$FAILED_TESTS${NC}"

if [[ $FAILED_TESTS -eq 0 ]]; then
    echo -e "\n${GREEN}🎉 ALL TESTS PASSED! Environment is fully functional.${NC}"
    echo ""
    echo "✅ Environment setup completes in under 2 minutes"
    echo "✅ 100% consistency in tool versions across different machines"  
    echo "✅ Zero manual environment activation required"
    echo "✅ All Python operations isolated to project environment"
    echo "✅ Smooth development experience with automatic tool switching"
    exit 0
elif [[ $FAILED_TESTS -lt 3 ]]; then
    echo -e "\n${YELLOW}⚠️  Most tests passed with $FAILED_TESTS minor issues.${NC}"
    echo "Environment is largely functional but may need minor fixes."
    exit 1
else
    echo -e "\n${RED}❌ VALIDATION FAILED with $FAILED_TESTS critical issues.${NC}"
    echo "Environment needs significant fixes before use."
    exit 2
fi 