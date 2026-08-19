# 🚀 Setup Supabase — Paso a paso

Guía para conectar el cuestionario a una base de datos Supabase.
**Tiempo estimado: 10 minutos.**

---

## 📋 Lo que vas a obtener

Al terminar tendrás:
- Todos los envíos guardados en una **tabla** que puedes ver, filtrar y exportar
- Los archivos adjuntos hasta **50 MB** cada uno en Storage
- Un **panel visual** para ver cada respuesta estructurada como JSON
- Todo **gratis** (500 MB DB + 1 GB Storage + 50K usuarios/mes)

---

## PASO 1 — Crear cuenta y proyecto en Supabase (3 min)

1. Ve a **https://supabase.com** → botón **"Start your project"**
2. Regístrate con **GitHub, Google o correo** (gratis)
3. Una vez dentro → **"New project"**
4. Completa:
   - **Name:** `cuestionarios-seguridad`
   - **Database password:** genera una fuerte (⚠️ GUÁRDALA en un lugar seguro, la vas a necesitar si haces backups)
   - **Region:** `South America (São Paulo)` — más cerca de Chile = más rápido
   - **Plan:** Free (por defecto)
5. Click en **"Create new project"** → espera ~2 minutos que se aprovisione

---

## PASO 2 — Ejecutar el SQL de migración (2 min)

1. Cuando el proyecto esté listo, en el menú lateral izquierdo click en **"SQL Editor"** (ícono `</>`)
2. Click en **"+ New query"**
3. **Copia y pega** todo el contenido del archivo `supabase_migration.sql` que te envié
4. Click en el botón **"RUN"** (arriba a la derecha, o `Ctrl+Enter`)
5. Deberías ver **"Success. No rows returned"** en verde

Esto crea:
- La tabla `cuestionarios` con todas sus columnas
- El bucket de Storage `cuestionarios-archivos`
- Las políticas de seguridad (RLS) para que sea seguro pero permita inserts públicos

---

## PASO 3 — Copiar credenciales (1 min)

1. En el menú lateral izquierdo click en el **⚙️ (Project Settings)** → abajo del todo
2. Dentro de Settings, click en **"API"** en la barra izquierda
3. Copia **DOS valores** que están arriba:

| Campo | Valor | ¿Qué es? |
|---|---|---|
| **Project URL** | `https://xxxxx.supabase.co` | La URL de tu backend |
| **anon public** | `eyJhbGc...` (una key larga) | Key para llamadas desde el frontend |

⚠️ **NO copies la "service_role secret"** — esa es privada y NUNCA va en el frontend.

---

## PASO 4 — Pegar las credenciales en el HTML (1 min)

1. Abre `cuestionario_asesorias.html` en un editor de texto (VS Code, Notepad, etc.)
2. Busca esta sección al inicio del `<script>`:

```javascript
const SUPABASE_URL      = "PEGA_AQUI_TU_URL_DE_SUPABASE";
const SUPABASE_ANON_KEY = "PEGA_AQUI_TU_ANON_KEY";
```

3. Reemplaza los placeholders con tus valores reales:

```javascript
const SUPABASE_URL      = "https://xxxxx.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGc...";
```

4. Guarda el archivo

---

## PASO 5 — Re-desplegar el HTML (1 min)

Sube el HTML actualizado a donde tengas el sitio:

**Opción A — GitHub Pages:**
- Reemplaza el archivo en tu repo `IngenieriaRequerimientos` → push
- URL: `https://danielfigueroa1879.github.io/IngenieriaRequerimientos/`

**Opción B — Netlify (donde ya está):**
- En Netlify → Deploys → arrastra el HTML nuevo
- URL: `https://requerimientoswebs.netlify.app`

---

## PASO 6 — Hacer envío de prueba (1 min)

1. Abre la URL de tu sitio en el celular
2. Llena empresa, contacto y sube un archivo pequeño de prueba
3. Presiona **"Enviar respuestas"** → pantalla verde ✅

---

## PASO 7 — Ver la respuesta en Supabase (1 min)

1. Ve a Supabase → tu proyecto → menú lateral **"Table Editor"** (ícono de tabla)
2. Click en la tabla **`cuestionarios`**
3. Verás tu envío como una fila con:
   - **id** — UUID único
   - **created_at** — timestamp
   - **empresa** — "test envío"
   - **contacto** — tu correo
   - **respuestas** — click en la celda para ver el JSON completo con todas las preguntas y respuestas estructuradas
   - **archivos** — array con URLs de los archivos que subiste (puedes hacer click en la URL para descargarlos)
   - **estado** — "nuevo" (por defecto)

**Para ver el JSON completo bien formateado:**
Click en la celda `respuestas` → se abre un modal con el JSON expandido y navegable.

---

## 🎁 EXTRA — Ver los archivos subidos

1. Menú lateral **"Storage"**
2. Click en el bucket **"cuestionarios-archivos"**
3. Verás carpetas organizadas por empresa (ej: `Prueba_SA/`) con los archivos dentro
4. Click en cualquier archivo → **"Download"** o abre la URL pública directamente

---

## 📊 Vistas útiles en Supabase

**Ver solo envíos nuevos:**
Table Editor → cuestionarios → filtro `estado = nuevo`

**Ver envíos de hoy:**
Table Editor → filtro `created_at > 2026-08-19` (o cualquier fecha)

**Marcar como revisado tras leer:**
Doble click en la celda `estado` de la fila → cambiar a `revisado`

**Agregar notas internas:**
Doble click en `notas_internas` → escribir tu nota → Enter

**Exportar a CSV:**
Table Editor → botón "Export" arriba → CSV o JSON

---

## 🔔 Notificaciones por correo (opcional)

Para recibir un correo cada vez que un cliente envíe el cuestionario:

1. En Supabase → menú **"Database"** → **"Webhooks"**
2. **"Create a new webhook"**
3. Configura:
   - **Name:** `notificar-nuevo-cuestionario`
   - **Table:** `cuestionarios`
   - **Events:** ☑️ INSERT
   - **Type:** HTTP Request
   - **URL:** puedes usar un servicio como https://webhook.site o conectarlo a Zapier / Make para que te mande correo
4. Save

Alternativa simpler: revisa la tabla 1-2 veces al día. Con esto ya tienes control total.

---

## 🛠️ Solución de problemas

**Error "supabase is not defined":**
Verifica que el HTML tiene la línea del CDN de Supabase JS en el `<head>`.

**Error "Invalid API key":**
Volviste a pegar mal el anon_key. Vuelve a copiarlo desde Project Settings → API.

**Error de CORS:**
Supabase permite CORS desde cualquier origen por defecto. Si aparece, verifica que tu URL de Supabase esté bien.

**Los archivos no se suben:**
Verifica que el bucket `cuestionarios-archivos` existe en Storage → si no, vuelve a ejecutar el SQL.

**Nada aparece en la tabla tras enviar:**
Abre la consola del navegador (F12 → Console) al enviar el cuestionario y busca errores. Comparte el mensaje.

---

## 🎯 Ventajas vs. Netlify Forms

| | Netlify Forms | Supabase |
|---|---|---|
| Panel para ver envíos | Básico | **Excelente (SQL, filtros, JSON viewer)** |
| Límite archivos | 10 MB | **50 MB (configurable)** |
| Envíos gratis/mes | 100 | **Ilimitados** |
| Almacenamiento archivos | Limitado | **1 GB gratis** |
| Cambiar estado / notas | ❌ | **✅ En vivo** |
| Búsqueda por texto | ❌ | **✅ Con índice GIN** |
| Exportar | CSV básico | **CSV, JSON, SQL directo** |
| Reutilizable en tu plataforma | ❌ | **✅ Ya es el mismo backend** |

Con Supabase estás construyendo la base de la plataforma final desde ahora.
