-- Run this in Supabase SQL Editor. Enables authenticated shared trips.
create table if not exists public.trips (
  id text primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  data jsonb not null,
  updated_at timestamptz not null default now()
);
create table if not exists public.trip_members (
  trip_id text not null references public.trips(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'editor' check (role in ('editor','viewer')),
  created_at timestamptz not null default now(),
  primary key (trip_id,user_id)
);
alter table public.trips enable row level security;
alter table public.trip_members enable row level security;
create or replace function public.is_trip_member(p_trip_id text, p_user_id uuid)
returns boolean language sql stable security definer set search_path=public as $$
  select exists(select 1 from public.trip_members m where m.trip_id=p_trip_id and m.user_id=p_user_id);
$$;
create or replace function public.owns_trip(p_trip_id text, p_user_id uuid)
returns boolean language sql stable security definer set search_path=public as $$
  select exists(select 1 from public.trips t where t.id=p_trip_id and t.owner_id=p_user_id);
$$;
create policy "members can read trips" on public.trips for select to authenticated
using (owner_id = auth.uid() or public.is_trip_member(id,auth.uid()));
create policy "owner and editors can update trips" on public.trips for update to authenticated
using (owner_id = auth.uid() or (public.is_trip_member(id,auth.uid()) and exists(select 1 from public.trip_members m where m.trip_id=trips.id and m.user_id=auth.uid() and m.role='editor')))
with check (owner_id = auth.uid() or (public.is_trip_member(id,auth.uid()) and exists(select 1 from public.trip_members m where m.trip_id=trips.id and m.user_id=auth.uid() and m.role='editor')));
create policy "authenticated users can create trips" on public.trips for insert to authenticated with check (owner_id=auth.uid());
create policy "owners can delete trips" on public.trips for delete to authenticated using (owner_id=auth.uid());
create policy "members can see membership" on public.trip_members for select to authenticated using (user_id=auth.uid() or public.owns_trip(trip_id,auth.uid()));
create policy "owners can add members" on public.trip_members for insert to authenticated with check (public.owns_trip(trip_id,auth.uid()));
create policy "owners can remove members" on public.trip_members for delete to authenticated using (public.owns_trip(trip_id,auth.uid()));
-- Anyone with the trip link can join as an editor after signing in. Share links should be sent only to trusted companions.
create or replace function public.join_trip(p_trip_id text)
returns void language plpgsql security definer set search_path=public as $$
begin
  if auth.uid() is null then raise exception 'Sign in first'; end if;
  if not exists(select 1 from public.trips where id=p_trip_id) then raise exception 'Trip not found'; end if;
  insert into public.trip_members(trip_id,user_id,role) values(p_trip_id,auth.uid(),'editor') on conflict do nothing;
end; $$;
grant execute on function public.join_trip(text) to authenticated;
