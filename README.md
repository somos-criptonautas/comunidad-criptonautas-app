# Comunidad Criptonautas — Android

Trusted Web Activity for https://comunidad.criptonautas.co, generated with
[Bubblewrap](https://github.com/GoogleChromeLabs/bubblewrap). No app code: Chrome renders the
forum full screen. Push notifications, share-to-app and shortcuts come from the forum's PWA manifest.

## Release

Tag `vX.Y.Z` → GitHub Actions builds, signs and attaches `criptonautas.apk`, `criptonautas.aab`
and `SHA256SUMS` to the release. Bump `appVersionCode`/`appVersionName` in `twa-manifest.json`
first, then regenerate:

    sh scripts/update.sh

It runs `bubblewrap update` and then drops the "open these links in the app" rules Bubblewrap
adds for each `additionalTrustedOrigins` host, so only forum links open the app from elsewhere
on the phone. Don't run a bare `bubblewrap update`.

Repo secrets: `KEYSTORE_B64` (`base64 -w0 android.keystore`), `KEYSTORE_PASSWORD`.
The keystore is **not** in this repo. Lose it and the app can't be updated.

## Verify a release

    sha256sum -c SHA256SUMS
    apksigner verify --print-certs criptonautas.apk   # SHA-256 must match assetlinks.json
    aapt dump permissions criptonautas.apk
    adb install criptonautas.apk                        # full screen, no URL bar = domain verified

The forum must serve `.well-known/assetlinks.json` (copy in this repo) at
https://comunidad.criptonautas.co/.well-known/assetlinks.json, otherwise the app shows a URL bar.

## Other criptonautas.co hosts

The hosts in `additionalTrustedOrigins` open full screen inside the app when the forum links to
them. Each one must serve the same `assetlinks.json`, or it opens with Chrome's address bar
instead. Adding or removing a host means a new release.
