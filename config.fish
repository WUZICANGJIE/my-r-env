set fish_greeting ""

# Locale configuration with runtime switching support
# Check if LOCALE env var is set, otherwise use default
if test -n "$LOCALE"
    set -gx LANG $LOCALE
    set -gx LC_ALL $LOCALE
else
    set -gx LANG en_US.UTF-8
    set -gx LC_ALL en_US.UTF-8
end

# Set other locale-related environment variables
set -gx LANGUAGE en_US:en
set -gx LC_CTYPE $LC_ALL
set -gx LC_NUMERIC $LC_ALL
set -gx LC_TIME $LC_ALL
set -gx LC_COLLATE $LC_ALL
set -gx LC_MONETARY $LC_ALL
set -gx LC_MESSAGES $LC_ALL
set -gx LC_PAPER $LC_ALL
set -gx LC_NAME $LC_ALL
set -gx LC_ADDRESS $LC_ALL
set -gx LC_TELEPHONE $LC_ALL
set -gx LC_MEASUREMENT $LC_ALL
set -gx LC_IDENTIFICATION $LC_ALL

# Validate locale and show info
if test "$LANG" != "C"
    echo "🌐 Locale: $LANG"
else
    echo "⚠️  Warning: Locale fallback to C (POSIX)"
end

starship init fish | source
