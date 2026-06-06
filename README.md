# Aegis Vault

Aplicación Flutter para localizar Safehouses activos en Cundinamarca,
consumiendo una base de datos distribuida en Supabase.

## Tecnologías

- Flutter + Material 3
- Supabase (base de datos remota)
- flutter_secure_storage (caché encriptado)
- connectivity_plus (detección de red)
- geolocator + vibration (proximidad Geiger)

## Funcionalidades

- Listado de refugios en GridView con tarjetas Material 3
- Filtro temático: tarjetas rojas si el refugio está comprometido
- Accesibilidad: widget Semantics con label de voz en cada tarjeta
- Caché encriptado local con bypass de red
- Vibración tipo contador Geiger al acercarse al Neon-Vault

## Registro de commit corrupto y saneamiento

### ¿Qué pasó?
Durante el desarrollo se hizo un commit accidental que rompía la app:
se eliminó por error el `useMaterial3: true` del ThemeData en `main.dart`,
lo que causaba que toda la UI perdiera el esquema de color de Material 3.

### Commit con el error
git add .
git commit -m "chore: corrupt commit (demo) - removes useMaterial3"
git push origin main

### Cómo se saneó
Se usó `git revert` para revertir el commit sin borrar el historial:
git revert HEAD
git push origin main

Se eligió `git revert` sobre `git reset --hard` porque el commit
ya había sido subido al repositorio remoto. Revert crea un nuevo commit
que deshace los cambios, preservando el historial de forma segura.

## Flujo de Git del proyecto

### Ramas trabajadas
- `develop` — rama principal
- `feature/supabase-connection` — conexión a Supabase + caché encriptado
- `feature/geiger-vibration` — vibración por proximidad GPS

### Conflicto resuelto
Ambas ramas modificaban las mismas líneas de inicialización del servicio.
El integrante de `feature/geiger-vibration` ejecutó rebase sobre main
después de que `feature/supabase-connection` fue mergeada, resolviendo
el conflicto línea por línea en la terminal.

### Commit final unificado
Todos los commits fueron compactados con rebase interactivo en uno solo:
feat(security): implement secure storage and geiger proximity alert.