-- 1. Tabela logów (bez danych osobowych gościa)
create table public.szkice_log (
  id                   bigint generated always as identity primary key,
  utworzono            timestamptz not null default now(),
  gmail_thread_id      text not null,
  status               text not null check (status in ('szkic', 'pominiety')),
  kategoria            text not null,
  jezyk                text,
  pewnosc              text,
  liczba_brakow        int  not null default 0,
  czas_przetwarzania_s numeric(6,1),
  tokeny               int
);

-- 2. Blokada: z internetu nikt nie czyta surowych logów
alter table public.szkice_log enable row level security;
revoke all on public.szkice_log from anon, authenticated;

-- 3. Widok KPI dzień po dniu
create view public.kpi_dzienne as
select
  (utworzono at time zone 'Europe/Warsaw')::date                                  as dzien,
  count(*) filter (where status = 'szkic')                                         as szkice,
  count(*) filter (where status = 'pominiety')                                     as pominiete,
  round(avg(czas_przetwarzania_s) filter (where status = 'szkic'), 1)              as sredni_czas_s,
  round(100.0 * avg((liczba_brakow = 0)::int) filter (where status = 'szkic'), 0)  as proc_kompletnych
from public.szkice_log
group by 1
order by 1 desc;

-- 4. Widok KPI według kategorii
create view public.kpi_kategorie as
select
  kategoria,
  count(*)                            as liczba,
  round(avg(liczba_brakow), 2)        as srednio_brakow,
  round(avg(czas_przetwarzania_s), 1) as sredni_czas_s
from public.szkice_log
where status = 'szkic'
group by kategoria
order by liczba desc;

-- 5. Dashboard (klucz publiczny anon) czyta tylko widoki
grant select on public.kpi_dzienne, public.kpi_kategorie to anon;
