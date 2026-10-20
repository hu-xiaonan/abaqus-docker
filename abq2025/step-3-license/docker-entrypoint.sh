#!/bin/bash
# Entrypoint for abq2025 image.
# Guarantees Abaqus Standard/Explicit/CAE can check out a license on every
# container start, even if:
#   - EstablishedProductsConfig.ini already contains stale/duplicate keys
#     (e.g. LICENSE_SERVER_TYPE=dsls left over from the installer), or
#   - the container was restarted, or
#   - the user overrode the docker run command (see upstream issue #9 where
#     appending "sleep infinity" replaced "CMD systemctl start ..." and left
#     lmgrd stopped, producing FLEXnet error -15,570).
set -e

INI="/usr/SIMULIA/EstProducts/2025/linux_a64/SMA/site/EstablishedProductsConfig.ini"
LIC="27800@localhost"

if [ -f "${INI}" ]; then
  # Ensure section header exists (Abaqus expects INI style).
  if ! grep -q "^\[EstablishedProducts\]" "${INI}"; then
    sed -i '1i[EstablishedProducts]' "${INI}"
  fi
  # Remove all prior values so there is exactly one effective entry.
  # Plain "echo >>" appends leave duplicates; DSLS entries then shadow flex.
  sed -i -e '/^LICENSE_SERVER_TYPE=.*/d' -e '/^FLEX_LICENSE_CONFIG=.*/d' "${INI}"
  printf '%s\n' "LICENSE_SERVER_TYPE=flex" "FLEX_LICENSE_CONFIG=${LIC}" >> "${INI}"
else
  echo "WARNING: license config not found: ${INI}" >&2
fi

# (Re)start vendored FlexLM server. systemctl here is gdraheim's replacement
# (see step-1-preliminary/systemctl.py), so fall back to SysV script.
if command -v systemctl >/dev/null 2>&1; then
  systemctl start flexlmsrvssq || true
fi
if [ -x /etc/init.d/flexlmsrvssq ]; then
  /etc/init.d/flexlmsrvssq start || true
fi

# Best-effort license check. Never blocks container boot; failure shows up in
# `abaqus verify -standard` / solver log instead.
if [ -x /usr/SolidSQUAD_License_Servers/Bin/lmstat ]; then
  /usr/SolidSQUAD_License_Servers/Bin/lmstat -a -c "${LIC}" || true
fi

exec "$@"
