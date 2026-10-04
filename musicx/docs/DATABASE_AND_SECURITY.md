# Base de Datos, Supabase y Seguridad RLS

MusicX utiliza PostgreSQL a través de Supabase como backend BaaS (*Backend as a Service*), implementando aislamiento multi-usuario mediante **Row Level Security (RLS)**.

---

## 1. Esquema de la Tabla `songs`

| Columna | Tipo | Restricción | Descripción |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | `PRIMARY KEY DEFAULT gen_random_uuid()` | Identificador único de la canción |
| `user_id` | `UUID` | `NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE DEFAULT auth.uid()` | ID del usuario propietario |
| `title` | `TEXT` | `NOT NULL` | Título de la pista musical |
| `artist` | `TEXT` | `NOT NULL DEFAULT ''` | Nombre del artista o agrupación |
| `description` | `TEXT` | `NOT NULL DEFAULT ''` | Notas o descripción del álbum/año |
| `image_url` | `TEXT` | `NOT NULL DEFAULT ''` | URL pública de la portada |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT now()` | Fecha y hora de creación |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT now()` | Fecha y hora de última modificación |

---

## 2. Índices de Rendimiento

Siguiendo las mejores prácticas de PostgreSQL y Supabase:
- `idx_songs_user_id`: Indexa `user_id` para acelerar el filtrado de RLS y joins.
- `idx_songs_user_created_at`: Índice compuesto `(user_id, created_at DESC)` para optimizar la consulta principal de ordenación por fecha.

---

## 3. Políticas de Seguridad (RLS)

La seguridad se aplica a nivel de base de datos utilizando el patrón `(SELECT auth.uid()) = user_id`:

```sql
-- Consulta: Los usuarios solo ven sus canciones
CREATE POLICY "Users can view their own songs"
ON public.songs FOR SELECT TO authenticated
USING ( (SELECT auth.uid()) = user_id );

-- Creación: Se asegura que el user_id asignado sea el del usuario autenticado
CREATE POLICY "Users can insert their own songs"
ON public.songs FOR INSERT TO authenticated
WITH CHECK ( (SELECT auth.uid()) = user_id );

-- Actualización: Permite editar solo registros propios
CREATE POLICY "Users can update their own songs"
ON public.songs FOR UPDATE TO authenticated
USING ( (SELECT auth.uid()) = user_id )
WITH CHECK ( (SELECT auth.uid()) = user_id );

-- Eliminación: Permite borrar solo registros propios
CREATE POLICY "Users can delete their own songs"
ON public.songs FOR DELETE TO authenticated
USING ( (SELECT auth.uid()) = user_id );
```

---

## 4. Archivos de Migración

Las migraciones se encuentran versionadas en el directorio `supabase/migrations/`:
- `supabase/migrations/20261004000000_create_songs_table.sql`: Creación de la tabla base con RLS e índices.
- `supabase/migrations/20261004000001_add_artist_to_songs.sql`: Migración incremental para añadir la columna `artist`.
