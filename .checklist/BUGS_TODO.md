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

---

**Last Updated**: June 6, 2025
