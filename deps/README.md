# Dependency Management

This folder contains centralized dependency definitions for the R environment container. All dependencies are organized into separate files for better maintainability and optimized Docker builds.

## 📋 Files

### Dependency Lists
- `build.txt` - Build-time dependencies that can be removed after installation
- `removable.txt` - Development libraries that can be safely removed (R doesn't directly depend on most)
- `required.txt` - Development libraries that R actually needs (keep these)
- `runtime.txt` - Runtime dependencies that should always be kept

### 🔧 Scripts
- `load.sh` - Helper script to load dependencies for shell scripts
- `gen-args.sh` - Generates ARG definitions for Containerfile
- `update.sh` - Updates Containerfile with latest dependency definitions
- `load-docker.sh` - Docker-specific dependency loader (runs inside container during build)
- `validate.sh` - Validates all dependency files and checks for duplicates

## 🚀 Usage

### For Shell Scripts (like debug.sh)
```bash
# Load all dependency variables
source deps/load.sh

# Now you can use these variables:
echo "Build deps: $BUILD_DEPS"
echo "Removable dev libs: $DEV_LIBS_REMOVABLE"
echo "Required dev libs: $DEV_LIBS_REQUIRED"
echo "Runtime deps: $RUNTIME_DEPS"
```

### For Containerfile Updates
After modifying any dependency file:
```bash
./deps/update.sh
```

Or manually regenerate the ARG definitions:
```bash
./deps/gen-args.sh
```

### Validation and Quality Checks
Before building your container:
```bash
./deps/validate.sh  # Check for duplicates and validate files
```

### Adding New Dependencies
1. **Choose the right category**:
   - `build.txt` - Tools needed only during build (removed after)
   - `runtime.txt` - Always needed packages
   - `required.txt` - Dev libraries that R base packages depend on
   - `removable.txt` - Dev libraries that can be removed to save space

2. **Edit the appropriate `.txt` file** in this folder
3. **Update and validate**:
   ```bash
   ./deps/validate.sh    # Check for issues
   ./deps/update.sh      # Update Containerfile
   ```
4. **Test with your container**:
   ```bash
   ./build.sh           # Rebuild container
   ./debug.sh           # Verify the changes
   ```

## 📂 Dependency Categories Explained

### `build.txt` - Build-time Tools
**Purpose**: Tools needed only during package compilation and installation
**Lifecycle**: Installed → Used during build → Removed to save space
**Examples**: `make`, `cmake`, `gcc`, `software-properties-common`

### `runtime.txt` - Always Required
**Purpose**: Essential packages needed for normal container operation
**Lifecycle**: Installed → Kept permanently
**Examples**: `curl`, `git`, `ca-certificates`, `pandoc`

### `required.txt` - R Dependencies
**Purpose**: Development libraries that R base packages directly depend on
**Lifecycle**: Installed → Kept permanently (critical for R functionality)
**Examples**: `libpng-dev`, `libjpeg-dev` (required by grDevices)

### `removable.txt` - Optional Dev Libraries
**Purpose**: Development libraries that extend R capabilities but aren't essential
**Lifecycle**: Installed → Available for R packages → Can be removed to save space
**Examples**: `libssl-dev`, `libxml2-dev`, `libcurl4-openssl-dev`

## 🔧 Troubleshooting

### Common Issues

**"Package not found" during build:**
```bash
# Check if package exists in repositories
apt-cache search package-name

# Validate your files
./deps/validate.sh
```

**Build fails after adding dependencies:**
```bash
# Test dependency loading
./deps/validate.sh

# Check Containerfile was updated
./deps/gen-args.sh  # Should show your new packages
```

**Container size too large:**
- Move packages from `required.txt` to `removable.txt` if safe
- Ensure build tools are in `build.txt` (they get removed)
- Use `docker images` to check size impact

**R package installation fails:**
```bash
# Check if required dev libraries are missing
# Move packages from `removable.txt` to `required.txt`
# Common culprits: libssl-dev, libxml2-dev, libcurl4-openssl-dev
```

### Debugging Commands

```bash
# Check current dependency counts
./deps/validate.sh

# See what would be in Containerfile
./deps/gen-args.sh

# Test container with debug info
./debug.sh

# Check for file issues
ls -la deps/*.txt
```

## 📝 File Format

Each `.txt` file contains one dependency per line. Lines starting with `#` are comments and blank lines are ignored.

**Example:**
```
# This is a comment describing the section
package-name
another-package
# Another comment
final-package
```

**Why TXT format?**
- Simple and straightforward - no special syntax required
- Easy to read and edit by anyone
- Efficient parsing with shell scripts
- Perfect for system package management (no version constraints needed)
- Lightweight and fast processing

## 🔍 Validation Features

The `validate.sh` script provides:
- ✅ **File existence checks** - Ensures all required files are present
- ✅ **Duplicate detection** - Finds packages listed in multiple categories
- ✅ **Package counting** - Shows how many packages in each category
- ✅ **Dependency loading test** - Verifies scripts can parse the files

## 🏗️ Build Integration

The dependency system integrates with Docker builds through:

1. **ARG generation** (`gen-args.sh`):
   - Creates Containerfile ARG definitions
   - Formats packages for Docker build context

2. **Container loading** (`load-docker.sh`):
   - Runs inside container during build
   - Loads dependencies from `/tmp/deps/` location
   - Exports variables for RUN commands

3. **Automatic updates** (`update.sh`):
   - Regenerates Containerfile dependency sections
   - Maintains proper formatting and comments

## 🎯 Best Practices

1. **Start conservative** - Put new packages in `required.txt` first
2. **Test thoroughly** - Build and test R packages after changes
3. **Document changes** - Use comments in `.txt` files to explain additions
4. **Validate regularly** - Run `./deps/validate.sh` before building
5. **Monitor size** - Check `docker images` after builds to track container size

---

**Need help?** Run `./deps/validate.sh` to check your files, or `./debug.sh` to test dependency loading in your container.
