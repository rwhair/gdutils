set client_min_messages = error;
begin transaction;

/*
==============================
mtg_cantrip
==============================
*/

drop table if exists mtg_cantrip cascade;
create table mtg_cantrip as
select * from mtg_card 
where (type like '%Instant%' or type like '%Sorcery%') 
and text ~ '\. Draw a card\.$';

update mtg_cantrip set text = 'Cantrip. ' || regexp_replace(text, ' Draw a card\.$', '');

/*
==============================
mtg_prototype
==============================
*/



create table mtg_card_class as
(
    -- Bear
    select
    (select card_id from mtg_card where name = 'Grizzly Bears' order by release_date limit 1) as prototype_id,
    c.* from mtg_card c
    where c.cmc = 2 and c.power = 2 and c.toughness = 2
)
union all
(
    -- Air Elemental
    select
    (select card_id from mtg_card where name = 'Air Elemental' order by release_date limit 1) as prototype_id,
    c.* from mtg_card c
    where c.cmc = 5 and c.power >= 4 and c.toughness >= 4 and c.rarity >= 'Uncommon' and c.text ~ '[Ff]lying[\,\.\;]'
)
union all
(
    -- Welkin Tern
    select
    (select card_id from mtg_card where name = 'Welkin Tern' order by release_date limit 1) as prototype_id,
    c.* from mtg_card c
    where c.cmc = 2 and c.power = 2 and c.toughness = 1 and c.text ~ '[Ff]lying[\,\.\;]'
)
union all
(
    -- Hill Giant
    select
    (select card_id from mtg_card where name = '')
)

create or replace view as mtg_additional_cost as
select 
c.mana_cost as mana, 
startcase(m.costs[1]) as cost,
regexp_replace(text, 'As an additional cost to cast CARDNAME, [^\.]*\. ', '') as text 
from mtg_card c, regexp_matches(text, 'As an additional cost to cast CARDNAME, ([^\.]*\.) ') m(costs)
where text ~ 'As an additional cost to cast CARDNAME, ';



set client_min_messages = notice;
commit transaction;
