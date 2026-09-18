-- Progress v3 — esquema Supabase
-- IMPORTANTE: ejecuta este SQL en el SQL Editor de TU proyecto Supabase.
-- No contiene ninguna contraseña.

create extension if not exists pgcrypto;

drop table if exists public.daily_records cascade;
drop table if exists public.goals cascade;
drop table if exists public.profiles cascade;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique,
  email text not null unique,
  approved boolean not null default false,
  role text not null default 'user' check (role in ('user','admin')),
  created_at timestamptz not null default now()
);

create table public.goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  type text not null check (type in ('boolean','time','quantity')),
  unit text,
  target numeric not null default 1,
  weekdays int[] not null default '{0,1,2,3,4,5,6}',
  start_date date,
  end_date date,
  sort_order int not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.daily_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  goal_id uuid not null references public.goals(id) on delete cascade,
  date date not null,
  actual numeric not null default 0,
  status text not null default 'pending' check (status in ('pending','completed','na')),
  created_at timestamptz not null default now(),
  unique(user_id,goal_id,date)
);

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='admin' and p.approved=true); $$;

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path=public
as $$
declare v_email text := lower(new.email); v_username text := coalesce(nullif(new.raw_user_meta_data->>'username',''), split_part(v_email,'@',1));
begin
  insert into public.profiles(id,username,email,approved,role)
  values(new.id,v_username,v_email, v_email='raul.sanchezbenavente.tseas@gmail.com', case when v_email='raul.sanchezbenavente.tseas@gmail.com' then 'admin' else 'user' end);
  return new;
end; $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.goals enable row level security;
alter table public.daily_records enable row level security;

revoke all on public.profiles,public.goals,public.daily_records from anon;
grant select,insert,update,delete on public.profiles,public.goals,public.daily_records to authenticated;

create policy "profiles own read" on public.profiles for select to authenticated using (id=auth.uid() or public.is_admin());
create policy "profiles own update" on public.profiles for update to authenticated using (id=auth.uid() or public.is_admin()) with check (id=auth.uid() or public.is_admin());
create policy "profiles own insert" on public.profiles for insert to authenticated with check (id=auth.uid());

create policy "goals own all" on public.goals for all to authenticated using (user_id=auth.uid()) with check (user_id=auth.uid());
create policy "records own all" on public.daily_records for all to authenticated using (user_id=auth.uid()) with check (user_id=auth.uid());

-- El administrador necesita ver y aprobar perfiles de otros usuarios.
create policy "admin read profiles" on public.profiles for select to authenticated using (public.is_admin());
create policy "admin update profiles" on public.profiles for update to authenticated using (public.is_admin()) with check (public.is_admin());

-- NOTA: el trigger reconoce automáticamente el correo del administrador indicado en config.js.
-- Crea primero ese usuario desde la pantalla de registro de Progress.
