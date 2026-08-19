-- ============================================================
-- 🗄️ MIGRACIÓN INICIAL — Cuestionario de Requerimientos
-- ============================================================
-- Copia y pega TODO este archivo en:
-- Supabase → tu proyecto → SQL Editor → New query → RUN
-- ============================================================

-- ============ TABLA PRINCIPAL ============
create table if not exists public.cuestionarios (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz default now(),

  -- Campos rápidos para búsqueda/listado
  empresa text,
  contacto text,
  progreso text,

  -- Todo el cuestionario estructurado como JSON
  respuestas jsonb,

  -- Array de archivos subidos al Storage bucket
  archivos jsonb default '[]'::jsonb,

  -- Estado interno de gestión
  estado text default 'nuevo'
    check (estado in ('nuevo','revisado','contactado','cotizado','ganado','descartado')),

  -- Notas del asesor (privadas)
  notas_internas text
);

-- Índice para orden por fecha (dashboard)
create index if not exists cuestionarios_created_at_idx
  on public.cuestionarios (created_at desc);

-- Índice para búsqueda por estado
create index if not exists cuestionarios_estado_idx
  on public.cuestionarios (estado);

-- Índice de búsqueda por texto en empresa
create index if not exists cuestionarios_empresa_idx
  on public.cuestionarios using gin (to_tsvector('spanish', coalesce(empresa,'')));


-- ============ RLS (Row Level Security) ============
alter table public.cuestionarios enable row level security;

-- Cualquiera puede INSERTAR un cuestionario (envío público)
drop policy if exists "public_insert" on public.cuestionarios;
create policy "public_insert" on public.cuestionarios
  for insert to anon, authenticated
  with check (true);

-- Solo usuarios autenticados pueden LEER los cuestionarios
drop policy if exists "auth_select" on public.cuestionarios;
create policy "auth_select" on public.cuestionarios
  for select to authenticated
  using (true);

-- Solo usuarios autenticados pueden ACTUALIZAR (cambiar estado, agregar notas)
drop policy if exists "auth_update" on public.cuestionarios;
create policy "auth_update" on public.cuestionarios
  for update to authenticated
  using (true);


-- ============ STORAGE BUCKET (para archivos adjuntos) ============
-- Este bloque intenta crear el bucket. Si ya existe, no hace nada.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'cuestionarios-archivos',
  'cuestionarios-archivos',
  true,       -- público (para poder leer los archivos vía URL)
  52428800,   -- 50 MB por archivo (mucho más generoso que Netlify)
  null        -- todos los tipos MIME permitidos
)
on conflict (id) do nothing;

-- Políticas del bucket
drop policy if exists "public_upload_cuestionarios" on storage.objects;
create policy "public_upload_cuestionarios" on storage.objects
  for insert to anon, authenticated
  with check (bucket_id = 'cuestionarios-archivos');

drop policy if exists "public_read_cuestionarios" on storage.objects;
create policy "public_read_cuestionarios" on storage.objects
  for select to anon, authenticated
  using (bucket_id = 'cuestionarios-archivos');


-- ============ FIN ============
-- Al terminar, deberías ver:
-- 1. Tabla "cuestionarios" en Table Editor
-- 2. Bucket "cuestionarios-archivos" en Storage
-- 3. Puedes hacer un envío de prueba desde el formulario
