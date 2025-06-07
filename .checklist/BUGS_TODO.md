# 🐛 Bug TODO List

## 🔴 Script Execution Problems

### 1. **Containerfile Debug Logging Issue**
- **File**: `Containerfile` (lines 78-92)  
- **Problem**: Debug logging doesn't output to logs folder but stops script
- **Priority**: Medium
- **Status**: Open

**Fix tasks**:
- [ ] Check if `/project/logs` directory creation works
- [ ] Test `tee -a` command in Docker context
- [ ] Verify `rdeps` variable is populated
- [ ] Add error handling for log file creation

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

## 🧹 Code Cleanup Tasks

### 3. **Unnecessary Scripts in deps/ Folder**
- **Files**: `deps/gen-args.sh`, `deps/update.sh`
- **Problem**: Scripts from earlier implementation approach not used by current build
- **Priority**: Low
- **Status**: Open

**Analysis**:
- `gen-args.sh` - Generates ARG definitions for Containerfile, but current build uses direct file reading
- `update.sh` - Updates Containerfile using ARG approach, incompatible with current implementation
- Current `Containerfile` reads dependency files directly via `load-docker.sh`

**Cleanup tasks**:
- [ ] Verify scripts are not referenced in any active builds
- [ ] Remove `deps/gen-args.sh`
- [ ] Remove `deps/update.sh`
- [ ] Update `deps/README.md` to remove references to removed scripts
- [ ] Test build process after removal to ensure no breakage

---

sudo apt install gsfonts libnode-dev


**Last Updated**: June 6, 2025
