# Locale Configuration Checklist

## Problem Statement
- Docker container shows LC_* locale warnings on startup
- Need support for English, Japanese, and Chinese
- Must work across different host systems (Linux, macOS, Windows)
- Should be configurable via environment variables

## Solution Components

### 1. System Packages (system-packages.txt)
- [x] Add locales package
- [x] Add locales-all package
- [ ] Verify all required locale packages are present

### 2. Dockerfile Modifications
- [ ] Add locale generation for EN, JA, CN locales
- [ ] Set default locale environment variables with fallback
- [ ] Configure locale generation before R installation
- [ ] Add environment variable support for runtime locale switching

### 3. Supported Locales
- [ ] English: en_US.UTF-8 (primary)
- [ ] Japanese: ja_JP.UTF-8
- [ ] Chinese (Simplified): zh_CN.UTF-8
- [ ] Chinese (Traditional): zh_TW.UTF-8

### 4. Environment Variables
- [ ] LOCALE (runtime locale selection)
- [ ] LANG (system language)
- [ ] LC_ALL (all locale categories)
- [ ] LC_* specific categories as needed

### 5. Shell Configuration
- [ ] Update fish shell config to respect locale env vars
- [ ] Add locale validation/fallback in shell startup

### 6. Testing
- [ ] Test with different LOCALE environment variable values
- [ ] Verify R starts without locale warnings
- [ ] Test on different host systems
- [ ] Validate multilingual text display

## Implementation Order
1. Update system packages
2. Modify Dockerfile locale configuration
3. Update shell configuration
4. Test and validate
