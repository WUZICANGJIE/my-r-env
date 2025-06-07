# 🐛 Bug TODO List


## 🧪 Cache Layer Testing

### 2. **Docker Build Cache Layers**
- **Priority**: Medium
- **Status**: Open

**Test tasks**:
- [ ] **Docker BuildKit cache**: Test `--mount=type=cache` for pip and renv
- [ ] **APT cache**: Verify `apt-get update` layer caching works properly
- [ ] **PIP cache**: Test `PIP_CACHE_DIR=/var/cache/buildkit/pip` functionality
- [ ] **CRAN/renv cache**: Test `RENV_PATHS_CACHE=/renv/cache` with `renv::restore()`

**Cache validation steps**:
- [ ] Build container twice and measure time difference
- [ ] Check if cache directories are populated after first build
- [ ] Verify cache reuse when only changing later layers
- [ ] Test cache invalidation when dependency files change


sudo apt install gsfonts libnode-dev


## 🔧 VS Code Extensions Installation

### 1. **Extension Installation Script Not Working**
- **Priority**: High
- **Status**: Open
- **File**: `install-extensions.sh`

**Issue Description**:
The VS Code extensions installation script (`install-extensions.sh`) is currently not working properly. The script is designed to pre-install VS Code extensions during Docker build but appears to have issues with the installation process.

**Affected Components**:
- [ ] Extension installation during Docker build
- [ ] User data directory configuration (`${USER_HOME}/.vscode-server`)
- [ ] Extension force installation flag
- [ ] All extensions in the EXTENSIONS array (30+ extensions)

**Investigation needed**:
- [ ] Check if `code` command is available in the container
- [ ] Verify user permissions for `.vscode-server` directory
- [ ] Test extension installation manually
- [ ] Check if VS Code server is properly configured
- [ ] Validate Docker build context and timing

**Extensions affected**: 30+ extensions including GitHub Copilot, Python, R, Jupyter, Docker, and Remote development extensions.


**Last Updated**: June 6, 2025
