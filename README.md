# UPEMA para iPhone

Reproductor nativo en SwiftUI para explorar la discografía de **Un Pingüino en mi Ascensor**. Incluye 15 álbumes y 180 canciones del catálogo facilitado, letras, búsqueda, listas personalizadas, historia del grupo y un reproductor persistente con controles de pantalla bloqueada.

## Funciones

- Inicio editorial, álbumes y búsqueda por canción, álbum o texto de la letra.
- Reproductor inferior siempre accesible y vista ampliada con progreso, anterior, play/pausa y siguiente.
- Reproducción en segundo plano y controles desde auriculares/pantalla bloqueada.
- Letras seleccionables y listas personalizadas guardadas en el iPhone.
- 83 canciones de los álbumes principales incluyen una fuente de audio en el JSON; el resto conserva ficha y letra, pero se marca como «Sin audio».
- Carátulas remotas, manifiesto de privacidad e icono original de la app.

## Abrir en Xcode

Requisitos: macOS, Xcode 16 o posterior y [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```bash
brew install xcodegen
xcodegen generate
open UPEMA.xcodeproj
```

En Xcode, selecciona el target **UPEMA**, abre **Signing & Capabilities**, elige tu equipo de Apple Developer y sustituye `es.angelsoto.upema` si ese identificador ya está ocupado. Después puedes ejecutar en un iPhone o usar **Product → Archive** para preparar la subida a App Store Connect.

## Comprobar el catálogo

```bash
python3 scripts/verify_catalog.py
```

## Contenido y derechos

La app no incorpora archivos de audio: reproduce las URL que ya aparecen en `discografia.json`. Las carátulas también se cargan desde sus fuentes originales. Antes de publicar en App Store, confirma que tienes autorización para distribuir las letras, mostrar las carátulas y facilitar la reproducción de cada enlace. Apple puede solicitar documentación sobre los derechos del contenido.

La reseña histórica enlaza a Wikipedia y el catálogo mantiene las fuentes aportadas en el JSON.

