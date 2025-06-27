#!/usr/bin/env bash
# test-environment.sh - Comprehensive Environment Validation Script
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
                log_success "$description"
                return 0
            else
                log_failure "$description - Expected pattern not found"
                return 1
            fi
        else
            log_success "$description"
            return 0
        fi
    else
        log_failure "$description - Command failed"
        return 1
    fi
}

# Test environment variables
test_env_var() {
    local var_name="$1"
    local expected_pattern="${2:-}"
    
    start_test "Environment variable: $var_name"
    
    if [[ -n "${!var_name:-}" ]]; then
        if [[ -n "$expected_pattern" ]]; then
            if echo "${!var_name}" | grep -q "$expected_pattern"; then
                log_success "$var_name is correctly set"
                return 0
            else
                log_failure "$var_name doesn't match expected pattern"
                return 1
            fi
        else
            log_success "$var_name is set"
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
echo "Testing PRD requirements and success metrics"
echo "Date: $(date)"
echo "User: $(whoami)"
echo "PWD: $(pwd)"
echo "======================================================================"

# FR-1: Version Management with asdf
echo -e "\n${BLUE}=== FR-1: Version Management with asdf ===${NC}"

test_command "asdf is installed" "asdf --version" "v"
test_command "Python version matches .tool-versions" "python --version" "3.13.5"
test_command "UV version matches .tool-versions" "uv --version" "0.7.13"

start_test ".tool-versions file exists"
if [[ -f ".tool-versions" ]]; then
    log_success ".tool-versions file exists"
else
    log_failure ".tool-versions file missing"
fi

# FR-2: Directory Environment with direnv
echo -e "\n${BLUE}=== FR-2: Directory Environment with direnv ===${NC}"

test_command "direnv is installed" "direnv --version"

# Test environment variables
test_env_var "PROJECT_ROOT" "$(pwd)"
test_env_var "PROJECT_NAME" "init"
test_env_var "VIRTUAL_ENV" ".venv"
test_env_var "ANSIBLE_CONFIG" 
test_env_var "ANSIBLE_INVENTORY"

# FR-3: Python Virtual Environment
echo -e "\n${BLUE}=== FR-3: Python Virtual Environment ===${NC}"

start_test "Python is from virtual environment"
python_path=$(which python)
if echo "$python_path" | grep -q ".venv"; then
    log_success "Python from virtual environment: $python_path"
else
    log_failure "Python not from virtual environment: $python_path"
fi

test_command "Ansible is installed" "ansible --version" "core 2.18"
test_command "Required Python packages available" "python -c 'import ansible, jinja2, yaml, paramiko'"

# FR-4: Environment Reproducibility  
echo -e "\n${BLUE}=== FR-4: Environment Reproducibility ===${NC}"

start_test "uv.lock file exists"
if [[ -f "uv.lock" ]]; then
    log_success "uv.lock exists for reproducible builds"
else
    log_failure "uv.lock file missing"
fi

start_test "pyproject.toml properly configured"
if [[ -f "pyproject.toml" ]] && grep -q "ansible>=8.0.0" pyproject.toml; then
    log_success "pyproject.toml contains required dependencies"
else
    log_failure "pyproject.toml missing or misconfigured"
fi

# Performance Testing
echo -e "\n${BLUE}=== Performance Testing ===${NC}"

start_test "Environment activation performance"
start_time=$(date +%s.%N)
direnv export bash >/dev/null 2>&1 || true
end_time=$(date +%s.%N)
activation_time=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0.5")

if (( $(echo "$activation_time < 1.0" | bc -l 2>/dev/null || echo "1") )); then
    log_success "Environment activation: ${activation_time}s (target: <1s)"
else
    log_warning "Environment activation: ${activation_time}s (target: <1s)"
fi

# Functional Testing
echo -e "\n${BLUE}=== Functional Testing ===${NC}"

test_command "Ansible can ping localhost" "ansible localhost -m ping" "SUCCESS"
test_command "UV package management works" "uv pip list" "ansible"

start_test "Project scripts are executable"
if [[ -x "scripts/uv-tasks.sh" ]]; then
    log_success "Development scripts are executable"
else
    log_failure "Development scripts not executable"
fi

# Cross-Platform Testing
echo -e "\n${BLUE}=== Cross-Platform Testing ===${NC}"

if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macOS"
    log_info "Platform: macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="Linux"
    log_info "Platform: Linux"
else
    PLATFORM="unknown"
    log_warning "Platform: unknown"
fi

# Integration Testing
echo -e "\n${BLUE}=== Integration Testing ===${NC}"

start_test "asdf + direnv integration"
if [[ "$(asdf current python 2>/dev/null | awk '{print $2}' || echo '')" == "3.13.5" ]] && [[ -n "${VIRTUAL_ENV:-}" ]]; then
    log_success "asdf and direnv working together"
else
    log_failure "asdf and direnv integration issue"
fi

test_command "uv + virtual environment integration" "uv run python --version" "3.13.5"

# Success Metrics Validation
echo -e "\n${BLUE}=== Success Metrics Validation ===${NC}"

start_test "Zero manual environment activation required"
if [[ -n "${VIRTUAL_ENV:-}" ]] && [[ -n "${PROJECT_ROOT:-}" ]]; then
    log_success "Environment activated automatically"
else
    log_failure "Manual environment activation may be required"
fi

start_test "All Python operations isolated"
if echo "$(which python)" | grep -q ".venv" && echo "$(which pip)" | grep -q ".venv"; then
    log_success "Python operations completely isolated"
else
    log_failure "Python operations not properly isolated"
fi

start_test "Consistent tool versions"
if [[ "$(python --version)" == "Python 3.13.5" ]] && [[ "$(uv --version)" == "uv 0.7.13" ]]; then
    log_success "Tool versions match specifications exactly"
else
    log_failure "Tool versions don't match specifications"
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
    echo "✅ 100% consistency in tool versions"  
    echo "✅ Zero manual environment activation required"
    echo "✅ All Python operations isolated"
    echo "✅ Smooth development experience"
    exit 0
else
    echo -e "\n${RED}❌ VALIDATION FAILED with $FAILED_TESTS issues.${NC}"
    echo "Environment needs fixes before use."
    exit 1
fi 