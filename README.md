# AwayLock

App de barra de menú que bloquea la Mac cuando te alejás con tu Apple Watch (o iPhone).
No desbloquea: eso lo hace el desbloqueo con Apple Watch de macOS. Así no guarda tu contraseña
ni necesita permiso de Accesibilidad.

## Compilar y abrir

```bash
./build.sh
open build/AwayLock.app
```

Tests de la lógica: `swift test`.

## Cómo decide

`Sources/AwayLockCore/PresenceEngine.swift` tiene tres estados:

- **Cerca**: solo desde acá puede bloquear.
- **Alejándote**: la mediana de la señal cayó bajo el umbral de bloqueo; si sigue así la demora configurada, bloquea.
- **Lejos**: no vuelve a bloquear hasta que la señal supere el umbral de "volviste". Esto corta el bucle con el Apple Watch.

Además: mediana de 4 s (ignora picos), 2 s seguidos cerca para contar que volviste,
20 s sin bloquear después de cada desbloqueo, y al despertar de reposo arranca en "Lejos".

## Calibrar

El menú muestra la señal en vivo. Mirá cuánto marca sentado y cuánto a la distancia en
que querés que bloquee, y ajustá los dos umbrales dejando unos 15–20 dBm de diferencia.
Si aparece "¿bloqueo falso?", bajá "Bloquear con señal menor a".

## Notas

- Firmado ad hoc: cada vez que recompilás, macOS puede volver a pedir el permiso de Bluetooth.
- Para "Abrir al iniciar sesión" conviene mover la app a /Applications.
- Bloquea con `SACLockScreenImmediate` (privada, la que usa Ctrl+Cmd+Q). Si no está,
  apaga la pantalla, y eso bloquea si "Pedir contraseña" está en "inmediatamente".
