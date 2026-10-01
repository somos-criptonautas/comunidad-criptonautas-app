#!/bin/sh
# Regenerate the Android project from twa-manifest.json. Use this instead of a bare
# `bubblewrap update`.
#
# Bubblewrap gives every additionalTrustedOrigins host an autoVerify intent filter,
# so links to those hosts tapped anywhere on the phone would open inside this app,
# and on Android 11 and older one host failing verification breaks App Links for all
# of them, the forum included. We only want those hosts trusted (full screen inside
# the app), so this keeps the forum's filter and drops the others.
set -e
cd "$(dirname "$0")/.."

bubblewrap update --skipVersionUpgrade "$@"

python3 - app/src/main/AndroidManifest.xml <<'PY'
import re, sys

path = sys.argv[1]
manifest = open(path).read()
filters = re.compile(
    r'\n[ \t]*<intent-filter android:autoVerify="true">.*?</intent-filter>[ \t]*', re.S
)

def keep(match):
    # The forum's own filter points at @string/hostName; the extra ones name a host.
    return match.group(0) if 'android:host="@string/hostName"' in match.group(0) else ""

stripped = filters.sub(keep, manifest)
removed = manifest.count("autoVerify") - stripped.count("autoVerify")
open(path, "w").write(stripped)
print(f"Removed {removed} extra app-link intent filter(s).")
PY
