# Publicar UPEMA en Apple y configurar Codemagic

La app usa actualmente el identificador `es.angelsoto.upema`. Decide el identificador definitivo **antes de subir la primera compilación**, porque después no se puede cambiar para esa ficha de App Store Connect.

## 1. Preparar la cuenta de Apple

1. Inscríbete en el [Apple Developer Program](https://developer.apple.com/programs/).
2. En [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list), crea un App ID explícito con el bundle ID `es.angelsoto.upema`.
3. En [App Store Connect](https://appstoreconnect.apple.com/), acepta los acuerdos pendientes en **Business**.
4. En **Apps → + → New App**, crea la ficha:
   - Plataforma: iOS.
   - Nombre: Un Pingüino En Mi Ascensor.
   - Idioma principal: Español.
   - Bundle ID: `es.angelsoto.upema`.
   - SKU: por ejemplo `upema-ios-001`.
5. En **General → App Information**, copia el número **Apple ID** de la aplicación. No es el Apple ID de tu cuenta: es un número asignado a esta app.

## 2. Completar la ficha

Prepara una descripción, palabras clave, categoría, URL de soporte, URL de política de privacidad, edad recomendada y capturas de pantalla. Contesta también el cuestionario de privacidad según el comportamiento real de la app.

La app no crea cuentas, no integra publicidad ni declara recogida de datos. Guarda las listas localmente en el dispositivo. Las carátulas y audios se solicitan a los dominios indicados en el catálogo.

Antes de enviar a revisión, confirma que tienes autorización para usar el nombre del grupo, el dibujo del icono, las carátulas, las letras y los enlaces de audio. Conserva esa autorización por si Apple la solicita.

## 3. Crear la clave para Codemagic

1. En App Store Connect abre **Users and Access → Integrations → App Store Connect API**.
2. Crea una clave llamada, por ejemplo, `Codemagic UPEMA`, con permiso **App Manager**.
3. Descarga el archivo `.p8` inmediatamente; Apple solo permite descargarlo una vez.
4. Guarda también el **Issuer ID** y el **Key ID**.

## 4. Conectar Codemagic

1. En [Codemagic](https://codemagic.io/) selecciona **Add application**, conecta GitHub y elige `airsoto/upema_app`.
2. En **Team settings → Integrations → Developer Portal**, añade la clave `.p8` con el nombre exacto `upema_app_store`.
3. En **Team settings → Code signing identities**:
   - Genera o sube un certificado **Apple Distribution**.
   - Crea o descarga un perfil **App Store** para `es.angelsoto.upema`.
4. En la aplicación de Codemagic crea el grupo de variables `app_store_credentials` y añade:
   - Nombre: `APP_STORE_APPLE_ID`.
   - Valor: el número Apple ID de la ficha creada en App Store Connect.
5. Abre la configuración de la aplicación, busca `codemagic.yaml` en la rama `main` e inicia el workflow **UPEMA · TestFlight**.

El workflow genera el proyecto de Xcode, valida el catálogo, selecciona la firma, incrementa el número de compilación, crea el IPA y lo sube a App Store Connect. No lo envía automáticamente a revisión ni lo publica en la tienda.

## 5. Probar y publicar

1. Espera a que Apple procese la compilación.
2. En **TestFlight**, completa la información de prueba y añade primero probadores internos.
3. Prueba reproducción, segundo plano, auriculares, bloqueo de pantalla, letras, listas y enlaces remotos en un iPhone real.
4. Cuando todo esté correcto, selecciona la compilación en la versión de App Store, completa la información para revisión y pulsa **Add for Review / Submit for Review**.
5. Mantén la publicación manual para decidir cuándo sale la app después de la aprobación.
