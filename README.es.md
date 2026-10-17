# Comunidad Criptonautas — Android

[ENGLISH](README.md) | **ESPAÑOL**

Trusted Web Activity para https://comunidad.criptonautas.co, generada con
[Bubblewrap](https://github.com/GoogleChromeLabs/bubblewrap). Sin código propio: Chrome muestra el
foro a pantalla completa. Las notificaciones push, compartir hacia la app y los accesos directos
salen del manifiesto PWA del foro.

## Publicar una versión

Un tag `vX.Y.Z` hace que GitHub Actions compile, firme y adjunte `criptonautas.apk`,
`criptonautas.aab` y `SHA256SUMS` al release. Antes, sube `appVersionCode`/`appVersionName` en
`twa-manifest.json` y regenera:

    sh scripts/update.sh

Los iconos salen directo del [brand kit](https://github.com/somos-criptonautas/brand-kit)
(`discourse/large-icon-512.png`, `discourse/push-icon-96.png`): después de actualizar el kit,
corre el script y publica una versión para tomarlos.

El script ejecuta `bubblewrap update` y después quita las reglas de "abrir estos enlaces en la
app" que Bubblewrap agrega para cada host de `additionalTrustedOrigins`, así solo los enlaces
del foro abren la app desde el resto del teléfono. No ejecutes `bubblewrap update` a secas.

Secretos del repo: `KEYSTORE_B64` (`base64 -w0 android.keystore`), `KEYSTORE_PASSWORD`.
El keystore **no** está en este repo. Si se pierde, la app no se puede actualizar.

## Verificar una versión

    sha256sum -c SHA256SUMS
    apksigner verify --print-certs criptonautas.apk   # el SHA-256 debe coincidir con assetlinks.json
    aapt dump permissions criptonautas.apk
    adb install criptonautas.apk                        # pantalla completa, sin barra de URL = dominio verificado

El foro tiene que servir `.well-known/assetlinks.json` (hay una copia en este repo) en
https://comunidad.criptonautas.co/.well-known/assetlinks.json; si no, la app muestra la barra de URL.

## Otros hosts de criptonautas.co

Los hosts de `additionalTrustedOrigins` se abren a pantalla completa dentro de la app cuando el
foro enlaza a ellos. Cada uno tiene que servir el mismo `assetlinks.json`; si no, se abre con la
barra de direcciones de Chrome. Agregar o quitar un host requiere una versión nueva.

## Licencia

[Apache-2.0](LICENSE), como la plantilla de Bubblewrap de la que se genera.

Texto de este README bajo [CC BY-NC-SA 4.0](CC-BY-NC-SA-4.0.txt).
