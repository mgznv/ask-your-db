# Dashboard App con Consultas en Lenguaje Natural

Una aplicación Rails que permite crear dashboards con widgets que procesan consultas en lenguaje natural y las convierte automáticamente en consultas SQL.

## Características

- 🤖 **Consultas en Lenguaje Natural**: Escribe preguntas como "Muestra ventas por mes" y obtén SQL automáticamente
- 📊 **Múltiples Tipos de Gráficos**: Line, Bar, Pie, Area, Table
- ✅ **Flujo de Aprobación**: Revisa y aprueba el SQL generado antes de la ejecución
- ⚡ **Hotwire/Turbo**: Interfaz reactiva sin refrescar la página
- 🎨 **Tailwind CSS**: Interfaz moderna y responsiva
- 📈 **Chart.js**: Visualizaciones interactivas

## Configuración Inicial

### 1. Variables de Entorno

Crea un archivo `.env` basado en `.env.example`:

```bash
cp .env.example .env
```

Configura tu API key de Anthropic:

```
ANTHROPIC_API_KEY=tu_api_key_aqui
```

### 2. Base de Datos

Configura las variables de entorno para la conexión a PostgreSQL en tu archivo `.env`:

```bash
DATABASE_NAME=excel_processor_development
DATABASE_USERNAME=pginfinex
DATABASE_PASSWORD=GFF(bax02
DATABASE_HOST=localhost
DATABASE_PORT=5432
```

### 3. MCP Server

Copia el archivo de ejemplo y configura tu conexión:

```bash
cp .mcp.json.example .mcp.json
```

Edita `.mcp.json` con tus credenciales de PostgreSQL:

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "${DATABASE_URL}"],
      "env": {
        "DATABASE_URL": "postgresql://pginfinex:GFF(bax02@localhost:5432/excel_processor_development"
      }
    }
  }
}
```

## Instalación

```bash
# Instalar dependencias
bundle install
npm install

# Ejecutar migraciones
rails db:migrate

# Compilar assets
npm run build
npm run build:css

# Iniciar servidor
rails server
```

## Uso

### 1. Crear Dashboard

1. Visita la aplicación en `http://localhost:3000`
2. Haz clic en "Nuevo Dashboard"
3. Ingresa un nombre descriptivo

### 2. Agregar Widgets

1. En el dashboard, haz clic en el botón "+" flotante
2. Ingresa un título para el widget
3. Escribe tu consulta en lenguaje natural, ejemplo:
   - "Muestra las ventas agrupadas por mes"
   - "Top 10 productos más vendidos"
   - "Clientes activos en los últimos 30 días"

### 3. Flujo de Aprobación

1. **Generación SQL**: El sistema convierte automáticamente tu consulta en SQL
2. **Revisión**: Revisa el SQL generado con syntax highlighting
3. **Aprobación**: 
   - ✅ **Aprobar**: El widget queda listo para ejecutar
   - ✗ **Rechazar**: Marca el widget como rechazado
   - **Regenerar SQL**: Vuelve a generar el SQL

### 4. Visualización

1. **Ejecutar**: Una vez aprobado, ejecuta la consulta
2. **Seleccionar Gráfico**: Elige entre Line, Bar, Pie, Area o Table
3. **Interactividad**: Las gráficas se actualizan dinámicamente

## Estructura del Proyecto

```
app/
├── controllers/
│   ├── dashboards_controller.rb
│   └── dashboard_widgets_controller.rb
├── models/
│   ├── dashboard.rb
│   └── dashboard_widget.rb
├── services/
│   └── natural_query_service.rb
├── views/
│   ├── dashboards/
│   └── dashboard_widgets/
└── javascript/
    ├── application.js
    └── dashboard.js
```

## Estados de Widget

- **Pending**: SQL generado, esperando aprobación
- **Approved**: Aprobado y listo para ejecutar
- **Rejected**: Rechazado por el usuario

## Tipos de Gráficos

- **Line**: Ideal para tendencias temporales
- **Bar**: Comparaciones entre categorías
- **Pie**: Distribuciones y porcentajes
- **Area**: Datos acumulados en el tiempo
- **Table**: Vista tabular de los datos

## API Endpoints

```
GET     /dashboards                     # Lista de dashboards
POST    /dashboards                     # Crear dashboard
GET     /dashboards/:id                 # Ver dashboard
PATCH   /dashboards/:id                 # Actualizar dashboard
DELETE  /dashboards/:id                 # Eliminar dashboard

POST    /dashboards/:id/dashboard_widgets           # Crear widget
PATCH   /dashboards/:id/dashboard_widgets/:id       # Actualizar widget
DELETE  /dashboards/:id/dashboard_widgets/:id       # Eliminar widget
PATCH   /dashboards/:id/dashboard_widgets/:id/approve    # Aprobar widget
PATCH   /dashboards/:id/dashboard_widgets/:id/reject     # Rechazar widget
POST    /dashboards/:id/dashboard_widgets/:id/execute    # Ejecutar consulta
POST    /dashboards/:id/dashboard_widgets/:id/regenerate_sql  # Regenerar SQL
```

## Tecnologías Utilizadas

- **Ruby on Rails 7.1.5**
- **PostgreSQL**
- **Anthropic Claude API** - Conversión NL→SQL
- **Hotwire/Turbo** - Interactividad sin JavaScript pesado
- **Stimulus** - Controladores JavaScript ligeros
- **Tailwind CSS** - Framework CSS utilitario
- **Chart.js** - Librería de gráficos
- **esbuild** - Bundling de JavaScript

## Desarrollo

### Comandos Útiles

```bash
# Desarrollo con recarga automática
bin/dev

# Solo Rails
rails server

# Solo assets
npm run build -- --watch

# Tests
rails test

# Console
rails console

# Rutas
rails routes
```

### Estructura de Base de Datos

```sql
-- Dashboards
CREATE TABLE dashboards (
  id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  layout JSONB,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- Dashboard Widgets
CREATE TABLE dashboard_widgets (
  id SERIAL PRIMARY KEY,
  dashboard_id INTEGER REFERENCES dashboards(id),
  title VARCHAR NOT NULL,
  natural_query TEXT NOT NULL,
  sql_query TEXT,
  chart_type VARCHAR,
  chart_config JSONB,
  position JSONB,
  status VARCHAR DEFAULT 'pending',
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

## Próximas Funcionalidades

- [ ] Drag & drop para reordenar widgets
- [ ] Guardar configuración de gráficos
- [ ] Exportar dashboards
- [ ] Compartir dashboards via URL
- [ ] Histórico de consultas
- [ ] Más tipos de visualizaciones
- [ ] Filtros dinámicos
- [ ] Alertas basadas en datos

## Troubleshooting

### Error de API Key
Si obtienes errores relacionados con Anthropic, verifica que `ANTHROPIC_API_KEY` esté configurada correctamente.

### Errores de Base de Datos
Asegúrate de que PostgreSQL esté ejecutándose y que las credenciales sean correctas.

### Assets no se cargan
Ejecuta `npm run build` y `npm run build:css` para recompilar los assets.

---

¡Tu dashboard con consultas en lenguaje natural está listo! 🚀