-- Ile szkiców w ostatnich 7 dniach i ile średnio braków danych?
select count(*) as szkice, round(avg(liczba_brakow), 2) as srednio_brakow
from szkice_log
where status = 'szkic' and utworzono > now() - interval '7 days';

-- W których kategoriach baza wiedzy ma najwięcej dziur?
select kategoria,
       count(*) filter (where liczba_brakow > 0)                            as z_brakami,
       count(*)                                                            as wszystkie,
       round(100.0 * count(*) filter (where liczba_brakow > 0) / count(*)) as proc_z_brakami
from szkice_log
where status = 'szkic'
group by kategoria
order by proc_z_brakami desc;

-- Szacowana oszczędność czasu (15 min ręcznie -> 2 min ze szkicem = 13 min na mail)
select round(count(*) * 13 / 60.0, 1) as zaoszczedzone_godziny
from szkice_log
where status = 'szkic';
