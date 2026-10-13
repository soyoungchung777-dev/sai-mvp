begin;

create table public.applications (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  name text not null check (char_length(btrim(name)) between 1 and 40),
  contact text not null check (
    char_length(contact) <= 100 and
    (contact ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'
      or contact ~ '^(\+82[- .]?|0)1[016789]([- .]?[0-9]){7,8}$')
  ),
  message text not null default '' check (char_length(message) <= 1000)
);

alter table public.applications enable row level security;
alter table public.applications force row level security;

revoke all on table public.applications from public, anon, authenticated;
grant usage on schema public to anon, authenticated;
grant insert (name, contact, message) on public.applications to anon, authenticated;

create policy "Visitors can submit applications only"
  on public.applications for insert
  to anon, authenticated
  with check (
    char_length(btrim(name)) between 1 and 40
    and char_length(contact) between 1 and 100
    and char_length(message) <= 1000
  );

comment on table public.applications is '사이 MVP 정식 버전 출시 알림 신청. 브라우저는 추가만 가능.';
commit;
