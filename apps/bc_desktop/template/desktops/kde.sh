if command -v startplasma-x11 > /dev/null 2>&1; then
    exec startplasma-x11
elif command -v startkde > /dev/null 2>&1; then
    exec startkde
else
    echo "Error: Neither startplasma-x11 nor startkde found in PATH." >&2
    exit 1
fi
