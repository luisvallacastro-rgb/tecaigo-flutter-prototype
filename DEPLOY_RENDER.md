# Publicar TeCaiGO Flutter en Render

Este prototipo Flutter se publica como Static Site en Render.

## Opcion recomendada

1. Sube este proyecto a un repo de GitHub, por ejemplo `tecaigo-flutter-prototype`.
2. En Render: `New` -> `Static Site`.
3. Conecta el repo.
4. Usa estos valores:

```text
Name: tecaigo-flutter-prototype
Build Command: bash scripts/render_build_flutter.sh
Publish Directory: build/web
```

5. Agrega la variable de entorno:

```text
SKIP_INSTALL_DEPS=true
```

6. En Redirects/Rewrites agrega:

```text
Rewrite /* /index.html
```

El archivo `render.yaml` ya incluye la misma configuracion por si prefieres crear el servicio como Blueprint.

## Antes de publicar

Verifica localmente:

```bash
flutter analyze
flutter build web
```

Render instalara Flutter estable durante el build y publicara la carpeta `build/web`.
