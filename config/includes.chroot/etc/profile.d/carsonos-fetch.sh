#!/bin/sh

# carsonOS fetch defaults: use the custom Fastfetch profile whenever fastfetch is available.
# This also gives fetch-style tools a consistent carsonOS identity without replacing their binaries.

if command -v fastfetch >/dev/null 2>&1 && [ -z "${CARSONOS_FETCH_SHOWN:-}" ]; then
    export CARSONOS_FETCH_SHOWN=1
    fastfetch --config /etc/skel/.config/fastfetch/config.jsonc
fi
