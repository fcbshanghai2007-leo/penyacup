-- ============================================================
-- Barça Asia Penya Cup · 数据库结构
-- 在 Supabase → SQL Editor 中整段粘贴并点击 Run，只需运行一次
-- ============================================================

-- 1. 网站配置（配捐规则、参赛队伍与嘉宾、logo），只有一行 id = 1
create table if not exists public.config (
  id int primary key default 1 check (id = 1),
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
insert into public.config (id, data) values (1, '{}'::jsonb)
on conflict (id) do nothing;

-- 2. 比赛与比分
create table if not exists public.matches (
  id uuid primary key default gen_random_uuid(),
  no int,
  time text,
  home text not null,
  away text not null,
  home_score int not null default 0,
  away_score int not null default 0,
  status text not null default 'scheduled' check (status in ('scheduled','live','done')),
  updated_at timestamptz not null default now()
);

-- 3. 报名记录
create table if not exists public.registrations (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  type text, region text, penya text not null, city text, contact text,
  email text not null, phone text, players text, guests text, days text,
  gift text, notes text, lang text,
  constraint reg_lengths check (
    char_length(penya) <= 200 and char_length(email) <= 200
    and char_length(coalesce(gift,'')) <= 2000 and char_length(coalesce(notes,'')) <= 2000
  )
);

-- ============================================================
-- 访问权限（行级安全 RLS）
-- 访客：可以读取配置和比分，可以提交报名，但看不到任何报名记录
-- 管理员（已登录账号）：可以修改配置和比分，查看和删除报名
-- 注意：请在 Authentication → Sign In / Providers 中关闭“Allow new users to sign up”，
-- 只由你在后台手动添加管理员账号
-- ============================================================
alter table public.config enable row level security;
alter table public.matches enable row level security;
alter table public.registrations enable row level security;

drop policy if exists "public read config" on public.config;
create policy "public read config" on public.config for select to anon, authenticated using (true);
drop policy if exists "admin write config" on public.config;
create policy "admin write config" on public.config for update to authenticated using (true) with check (true);

drop policy if exists "public read matches" on public.matches;
create policy "public read matches" on public.matches for select to anon, authenticated using (true);
drop policy if exists "admin write matches" on public.matches;
create policy "admin write matches" on public.matches for all to authenticated using (true) with check (true);

drop policy if exists "anyone can register" on public.registrations;
create policy "anyone can register" on public.registrations for insert to anon, authenticated with check (true);
drop policy if exists "admin read registrations" on public.registrations;
create policy "admin read registrations" on public.registrations for select to authenticated using (true);
drop policy if exists "admin delete registrations" on public.registrations;
create policy "admin delete registrations" on public.registrations for delete to authenticated using (true);

-- 实时更新：比分与配置改动后，网页自动刷新
do $$ begin
  begin alter publication supabase_realtime add table public.matches; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.config; exception when duplicate_object then null; end;
end $$;
