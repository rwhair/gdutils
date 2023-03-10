/*
======================================================================
Target creature gets ±P/±T until end of turn.
======================================================================
*/

select
    date_part('year', max(c.release_date)) as year,
    mode() within group (order by c.rarity) as rarity,
    c.name,
    c.type,
    c.cmc,
    c.mana_cost,
    (regexp_matches(text, 'gets ([\+\-][0-9]+)/([\+\-][0-9]+)'))[1] as power,
    (regexp_matches(text, 'gets ([\+\-][0-9]+)/([\+\-][0-9]+)'))[2] as toughness,
from mtg_card c
where (c.type like '%Instant%' or c.type like '%Sorcery%')
and c.text ~ 'gets ([\+\-][0-9]+)/([\+\-][0-9]+)' and c.text like 'Target creature %' and c.text like '% until end of turn.'
group by c.type, c.name, c.cmc, c.mana_cost, pt[1], pt[2], c.text
order by c.cmc, length(c.mana_cost), abs(pt[1] :: integer) + abs(pt[2] :: integer), abs(pt[1] :: integer), abs(pt[2] :: integer) desc



/*
======================================================================
Target creature gains [ability] until end of turn.
======================================================================
*/

select
    date_part('year', max(c.release_date)) as year,
    mode() within group (order by c.rarity) as rarity,
    c.name,
    c.type,
    c.cmc,
    c.mana_cost,
    pt[1] as power,
    pt[2] as toughness,
    c.text
from mtg_card c, regexp_matches(text, '^Target creature gains ([^\.*]+) until end of turn.$') pt
group by c.type, c.name, c.cmc, c.mana_cost, pt[1], pt[2], c.text
order by c.cmc, length(c.mana_cost), abs(pt[1] :: integer) + abs(pt[2] :: integer), abs(pt[1] :: integer), abs(pt[2] :: integer) desc

select
cst.subtype,
sum((colors = '') :: integer) as C,
sum((colors = 'W') :: integer) as W,
sum((colors = 'U') :: integer) as U,
sum((colors = 'B') :: integer) as B,
sum((colors = 'R') :: integer) as R,
sum((colors = 'G') :: integer) as G,
sum((colors = 'WU') :: integer) as WU,
sum((colors = 'UB') :: integer) as UB,
sum((colors = 'BR') :: integer) as BR,
sum((colors = 'RG') :: integer) as RG,
sum((colors = 'WG') :: integer) as WG,
sum((colors = 'WB') :: integer) as WB,
sum((colors = 'WR') :: integer) as WR,
sum((colors = 'UR') :: integer) as UR,
sum((colors = 'UG') :: integer) as UG,
sum((colors = 'BG') :: integer) as BG,
sum((colors = 'WUB') :: integer) as WUB,
sum((colors = 'WUR') :: integer) as WUR,
sum((colors = 'WUG') :: integer) as WUG,
sum((colors = 'WBR') :: integer) as WBR,
sum((colors = 'WBG') :: integer) as WBG,
sum((colors = 'WRG') :: integer) as WRG,
sum((colors = 'UBR') :: integer) as UBR,
sum((colors = 'UBG') :: integer) as UBG,
sum((colors = 'URG') :: integer) as URG,
sum((colors = 'BRG') :: integer) as BRG,
sum((colors = 'WUBR') :: integer) as WUBR,
sum((colors = 'WUBG') :: integer) as WUBG,
sum((colors = 'WURG') :: integer) as WURG,
sum((colors = 'WBRG') :: integer) as WBRG,
sum((colors = 'UBRG') :: integer) as UBRG,
sum((colors = 'WUBRG') :: integer) as WUBRG
from mtg_card c
join mtg_card_type ct on (c.card_id = ct.card_id and ct.type = 'Creature')
join mtg_card_subtype cst on (c.card_id = cst.card_id)
group by cst.subtype
order by cst.subtype
) t

/*
==============================
Cantrips
==============================
*/

select
c.name,
date_part('year', mode() within group (order by c.release_date)) as year,
mode() within group (order by c.rarity) as rarity,
c.mana_cost,
c.type,
replace(replace(replace(regexp_replace(c.text, '\([^\)]*\)', ' ', 'g'), ' Draw a card.', ''), '  ', ' '), '..', '.') as text
from mtg_card c
where c.rules ~ '\nDraw a card.$' and (c.type like '%Instant%' or c.type like '%Sorcery%')
group by c.name, c.cmc, c.mana_cost, c.type, c.text
order by length(coalesce(text, '')), text, cmc, length(mana_cost), case when mana_cost like '%W%' then 1 when mana_cost like '%U%' then 2 when mana_cost like '%B%' then 3 when mana_cost like '%R%' then 4 when mana_cost like '%G%' then 5 else 6 end, case when c.type like '%Instant%' then 1 when c.type like '%Sorcery%' then 2 else 3 end, year, rarity;

/*
==============================
Bears
==============================
*/

select
c.name,
date_part('year', mode() within group (order by c.release_date)) as year,
mode() within group (order by c.rarity) as rarity,
c.mana_cost,
split_part(c.type, ' — ', 1) as type,
split_part(c.type, ' — ', 2) as subtype,
c.power,
c.toughness,
replace(replace(regexp_replace(c.text, '\([^\)]*\)', ' ', 'g'), '  ', ' '), '..', '.') as text
from mtg_card c
where c.type like '%Creature%' 
and (c.cmc = 2 and c.power = 2 and c.toughness = 2) 
group by c.name, c.cmc, c.mana_cost, c.type, c.power, c.toughness, c.text
order by length(mana_cost), case when mana_cost like '%W%' then 1 when mana_cost like '%U%' then 2 when mana_cost like '%B%' then 3 when mana_cost like '%R%' then 4 when mana_cost like '%G%' then 5 else 6 end, c.mana_cost, length(coalesce(text, '')), text, year, rarity

/*
==============================
Air Elemental
==============================
*/

select
c.name,
date_part('year', mode() within group (order by c.release_date)) as year,
mode() within group (order by c.rarity) as rarity,
c.mana_cost,
split_part(c.type, ' — ', 1) as type,
split_part(c.type, ' — ', 2) as subtype,
c.power,
c.toughness,
replace(replace(regexp_replace(c.text, '\([^\)]*\)', ' ', 'g'), '  ', ' '), '..', '.') as text
from mtg_card c
where c.type like '%Creature%' 
and (c.cmc = 5 and c.power >= 4 and c.toughness >= 4) 
and c.text ~ '$[^\.]*[Ff]lying\.'
and c.rarity >= 'Uncommon'
group by c.name, c.cmc, c.mana_cost, c.type, c.power, c.toughness, c.text
order by length(mana_cost), case when mana_cost like '%W%' then 1 when mana_cost like '%U%' then 2 when mana_cost like '%B%' then 3 when mana_cost like '%R%' then 4 when mana_cost like '%G%' then 5 else 6 end, c.mana_cost, length(coalesce(text, '')), text, year, rarity

/*
====================
Additional Cost
====================
*/

create or replace view as mtg_additional_cost as
select 
c.mana_cost as mana, 
startcase(m.costs[1]) as cost,
regexp_replace(text, 'As an additional cost to cast CARDNAME, [^\.]*\. ', '') as text 
from mtg_card c, regexp_matches(text, 'As an additional cost to cast CARDNAME, ([^\.]*\.) ') m(costs)
where text ~ 'As an additional cost to cast CARDNAME, ';

