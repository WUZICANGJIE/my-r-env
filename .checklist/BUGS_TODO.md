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


**Last Updated**: June 6, 2025
