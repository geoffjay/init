# Environment Management Troubleshooting Guide

## Quick Diagnosis

Run the validation script to identify issues:
```bash
./scripts/test-environment.sh
```

This will test all requirements and provide specific error messages for any problems.

## Common Issues and Solutions

### 1. Environment Not Activating

**Symptoms:**
- No activation message when entering project directory
- Environment variables not set (`echo $PROJECT_ROOT` shows nothing)
- Tools not found (`python: command not found`)

**Diagnosis:**
```bash
# Check if direnv is installed
direnv --version

# Check if .envrc is allowed
direnv status

# Check shell integration
echo $DIRENV_CONFIG_DIR
```

**Solutions:**

#### A. Allow .envrc file
```bash
direnv allow
```

#### B. Install direnv shell integration
Add to your shell profile (`.zshrc`, `.bashrc`):
```bash
eval "$(direnv hook zsh)"    # for zsh
eval "$(direnv hook bash)"   # for bash
```

#### C. Reload shell configuration
```bash
source ~/.zshrc    # or ~/.bashrc
```

### 2. Tool Versions Incorrect

**Symptoms:**
- `python --version` shows wrong version
- `uv --version` shows wrong version
- Tools not matching `.tool-versions`

**Diagnosis:**
```bash
# Check what asdf sees
asdf current

# Check tool-versions file
cat .tool-versions

# Check if tools are installed
asdf list python
asdf list uv
```

**Solutions:**

#### A. Install missing tools
```bash
asdf install
```

#### B. Refresh asdf shims
```bash
asdf reshim python
asdf reshim uv
```

#### C. Check asdf shell integration
Add to shell profile:
```bash
. "$HOME/.asdf/asdf.sh"
```

### 3. Python Dependencies Missing

**Symptoms:**
- `ansible: command not found`
- Import errors when running Python
- Empty output from `pip list`

**Diagnosis:**
```bash
# Check virtual environment
echo $VIRTUAL_ENV
which python
which pip

# Check if dependencies are installed
uv pip list
```

**Solutions:**

#### A. Install dependencies
```bash
uv sync
```

#### B. Recreate virtual environment
```bash
rm -rf .venv
uv sync
```

#### C. Use uv run for commands
```bash
uv run ansible --version
uv run python script.py
```

### 4. Performance Issues

**Symptoms:**
- Slow environment activation (>2 seconds)
- Slow directory switching
- High CPU usage when entering directory

**Diagnosis:**
```bash
# Time environment activation
time eval "$(direnv export zsh)"

# Check cache sizes
du -sh ~/.cache/uv
du -sh ~/.cache/pip
```

**Solutions:**

#### A. Clear caches
```bash
./scripts/uv-tasks.sh clean
```

#### B. Check disk space
```bash
df -h ~
df -h ~/.cache
```

#### C. Optimize shell startup
Remove unnecessary items from shell profile that slow startup.

### 5. Cross-Platform Issues

**Symptoms:**
- Different behavior between Linux and macOS
- Tools not found on specific platforms
- Path issues

**Platform-Specific Solutions:**

#### Linux
```bash
# Check package manager
which apt || which apk

# Verify asdf location
ls /usr/local/bin/asdf

# Check PATH
echo $PATH | grep asdf
```

#### macOS
```bash
# Check Homebrew
brew --version

# Verify asdf location
ls /opt/homebrew/bin/asdf || ls /usr/local/bin/asdf

# Check PATH
echo $PATH | grep -E "(homebrew|asdf)"
```

### 6. Permission Issues

**Symptoms:**
- Permission denied errors
- Cannot write to directories
- Cannot execute scripts

**Solutions:**

#### A. Fix script permissions
```bash
chmod +x scripts/*.sh
```

#### B. Fix directory permissions
```bash
chmod 755 ~/Projects/init
```

#### C. Check ownership
```bash
ls -la ~/Projects/init
# Should be owned by your user
```

### 7. Network/Connectivity Issues

**Symptoms:**
- Package installation failures
- Download timeouts
- SSL certificate errors

**Solutions:**

#### A. Check internet connectivity
```bash
ping -c 1 pypi.org
```

#### B. Use different index
```bash
uv sync --index-url https://pypi.org/simple/
```

#### C. Work offline
```bash
# If packages already cached
uv sync --offline
```

## Validation Commands

### Basic Environment Check
```bash
echo "=== Basic Environment Check ==="
echo "Python: $(python --version 2>/dev/null || echo 'Not found')"
echo "UV: $(uv --version 2>/dev/null || echo 'Not found')"
echo "Ansible: $(ansible --version 2>/dev/null | head -1 || echo 'Not found')"
echo "VIRTUAL_ENV: ${VIRTUAL_ENV:-'Not set'}"
echo "PROJECT_ROOT: ${PROJECT_ROOT:-'Not set'}"
```

### Comprehensive Validation
```bash
# Run full test suite
./scripts/test-environment.sh

# Run specific uv tasks
./scripts/uv-tasks.sh env-check
```

### Manual Validation Steps
```bash
# 1. Check file existence
ls -la .tool-versions .envrc pyproject.toml uv.lock

# 2. Test tool versions
asdf current
python --version
uv --version

# 3. Test virtual environment
echo $VIRTUAL_ENV
which python | grep .venv

# 4. Test Ansible
ansible localhost -m ping

# 5. Test dependencies
python -c "import ansible, jinja2, yaml, paramiko; print('All imports successful')"
```

## Recovery Procedures

### Complete Environment Reset
If all else fails, completely reset the environment:

```bash
# 1. Remove virtual environment
rm -rf .venv

# 2. Clear caches
rm -rf ~/.cache/uv ~/.cache/pip

# 3. Reinstall tools
asdf install

# 4. Recreate environment
direnv allow
uv sync

# 5. Validate
./scripts/test-environment.sh
```

### Partial Reset (Dependencies Only)
If only Python dependencies are problematic:

```bash
# 1. Remove virtual environment
rm -rf .venv

# 2. Reinstall dependencies
uv sync

# 3. Test functionality
ansible --version
```

### Tool Version Reset
If tool versions are incorrect:

```bash
# 1. Uninstall current versions
asdf uninstall python 3.13.5
asdf uninstall uv 0.7.13

# 2. Reinstall from .tool-versions
asdf install

# 3. Refresh shell
asdf reshim python
asdf reshim uv
```

## Getting Help

### Error Message Interpretation

#### "direnv: error .envrc is blocked"
**Solution:** Run `direnv allow`

#### "python: command not found"
**Likely causes:**
1. asdf not installed or not in PATH
2. Python version not installed (`asdf install`)
3. Shell integration missing

#### "No module named 'ansible'"
**Likely causes:**
1. Dependencies not installed (`uv sync`)
2. Wrong Python interpreter (check `which python`)
3. Virtual environment not activated

#### "uv: command not found"
**Likely causes:**
1. asdf not managing uv (`asdf install`)
2. uv not in PATH
3. Shell integration issues

### Debug Information Collection

When seeking help, provide this information:

```bash
echo "=== Debug Information ==="
echo "OS: $(uname -a)"
echo "Shell: $SHELL"
echo "PWD: $(pwd)"
echo "User: $(whoami)"
echo ""
echo "=== Tool Versions ==="
echo "asdf: $(asdf --version 2>/dev/null || echo 'Not found')"
echo "direnv: $(direnv --version 2>/dev/null || echo 'Not found')"
echo "Python: $(python --version 2>/dev/null || echo 'Not found')"
echo "UV: $(uv --version 2>/dev/null || echo 'Not found')"
echo ""
echo "=== Environment Variables ==="
echo "VIRTUAL_ENV: ${VIRTUAL_ENV:-'Not set'}"
echo "PROJECT_ROOT: ${PROJECT_ROOT:-'Not set'}"
echo "PATH: $PATH"
echo ""
echo "=== File Status ==="
ls -la .tool-versions .envrc pyproject.toml uv.lock 2>/dev/null || echo "Some files missing"
```

### Support Resources

1. **Run validation script:** `./scripts/test-environment.sh`
2. **Check environment:** `./scripts/uv-tasks.sh env-check`
3. **Review logs:** Check `ansible.log` for Ansible-specific issues
4. **Platform documentation:** 
   - asdf: https://asdf-vm.com/
   - direnv: https://direnv.net/
   - uv: https://docs.astral.sh/uv/

Remember: The environment management system is designed to be self-healing. Most issues can be resolved by re-running the setup commands or using the reset procedures above. 