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

# Launch screen without the static icon: just the background colour (values and
# values-night/colors.xml), so the forum's own animated splash appears on the same
# background and the hand-off reads as one screen.
splash = 'android:resource="@drawable/splash"'
if splash in stripped:
    stripped = stripped.replace(splash, 'android:resource="@drawable/splash_blank"')
elif 'android:resource="@drawable/splash_blank"' not in stripped:
    sys.exit("Splash image meta-data not found: check AndroidManifest.xml by hand.")

open(path, "w").write(stripped)
print(f"Removed {removed} extra app-link intent filter(s); launch screen without icon.")
PY

# Bubblewrap wipes extra resources on update, so these two are written here every time.
mkdir -p app/src/main/res/drawable app/src/main/res/values-night
cat > app/src/main/res/drawable/splash_blank.xml <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<!-- Transparent launch-screen image, written by scripts/update.sh. -->
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <size android:width="1dp" android:height="1dp" />
    <solid android:color="@android:color/transparent" />
</shape>
XML
# Dark-mode launch background: the palette's dark `secondary`, what the forum's splash
# draws on. Light mode uses twa-manifest.json's backgroundColor.
cat > app/src/main/res/values-night/colors.xml <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<!-- Written by scripts/update.sh. -->
<resources>
    <color name="backgroundColor">#181719</color>
</resources>
XML
