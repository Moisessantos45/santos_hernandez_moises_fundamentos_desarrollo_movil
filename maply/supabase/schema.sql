create table if not exists public.places (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null default auth.uid(),
  title text not null,
  description text default '',
  category text not null default 'General',
  latitude double precision not null,
  longitude double precision not null,
  image_url text default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.places enable row level security;

create policy "Users can view their own places"
  on public.places for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users can create their own places"
  on public.places for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Users can update their own places"
  on public.places for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "Users can delete their own places"
  on public.places for delete
  to authenticated
  using ((select auth.uid()) = user_id);

create index if not exists idx_places_user_id on public.places(user_id);
create index if not exists idx_places_category on public.places(category);
