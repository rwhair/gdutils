set client_min_messages = warning;
begin transaction;

/*
=============================
d20.monster
.fort_save
.ref_save
.will_save
=============================
*/

update d20.monster set (fort_save, ref_save, will_save) = (
    select 
        case when m2.sv[1] = '-' then null else m2.sv[1] end :: integer as fort_save,
        case when m2.sv[2] = '-' then null else m2.sv[2] end :: integer as ref_save,
        case when m2.sv[3] = '-' then null else m2.sv[3] end :: integer as will_save
    from monster m1
    left outer join (select id, regexp_matches(saves, '^Fort ([+-][0-9]*).* Ref ([+-][0-9]*).* Will ([+-][0-9]*).*$') sv from monster) m2 on (m1.id = m2.id)
    where d20.monster.monster_id = m1.id
);

/*
=============================
d20.monster
.hit_dice
.hit_dice_d4
.hit_dice_d6
.hit_dice_d8
.hit_dice_d10
.hit_dice_d12
.hit_dice_plus
.hit_points
=============================
*/

update d20.monster set (hit_dice_d4, hit_dice_d6, hit_dice_d8, hit_dice_d10, hit_dice_d12, hit_dice_plus, hit_points) = (
    select 
        coalesce((select sum(parse_rational(d.n[1])) from regexp_matches(hit_dice, '([0-9\/]+)[\s]?d4', 'g') d(n)), 0) as hit_dice_d4,
        coalesce((select sum(parse_rational(d.n[1])) from regexp_matches(hit_dice, '([0-9\/]+)[\s]?d6', 'g') d(n)), 0) as hit_dice_d6,
        coalesce((select sum(parse_rational(d.n[1])) from regexp_matches(hit_dice, '([0-9\/]+)[\s]?d8', 'g') d(n)), 0) as hit_dice_d8,
        coalesce((select sum(parse_rational(d.n[1])) from regexp_matches(hit_dice, '([0-9\/]+)[\s]?d10', 'g') d(n)), 0) as hit_dice_d10,
        coalesce((select sum(parse_rational(d.n[1])) from regexp_matches(hit_dice, '([0-9\/]+)[\s]?d12', 'g') d(n)), 0) as hit_dice_d12,
        coalesce((select sum(parse_rational(d.n[1])) from regexp_matches(hit_dice, '([+-][0-9]+)', 'g') d(n)), 0) as hit_dice_plus,
        coalesce((select parse_rational(d.n[1]) from regexp_matches(hit_dice, '([0-9]*) hp') d(n)), 0) as hit_points
    from monster
    where d20.monster.monster_id = monster.id
);

update d20.monster set hit_dice = (hit_dice_d4 + hit_dice_d6 + hit_dice_d8 + hit_dice_d10 + hit_dice_d12);
update d20.monster set hit_dice = null where hit_dice = 0;
update d20.monster set hit_points = null where hit_points = 0;
update d20.monster set hit_dice_d4 = null, hit_dice_d6 = null, hit_dice_d8 = null, hit_dice_d10 = null, hit_dice_d12 = null where hit_dice is null;


/*
=============================
d20.monster
.challenge_rating
.adjusted_challenge_rating
=============================
*/

update d20.monster set challenge_rating = (
    select parse_rational(split_part(case when challenge_rating = '''' then '1/2' else challenge_rating end, ' ', 1))
    from monster where d20.monster.monster_id = monster.id
);

update d20.monster set adjusted_challenge_rating = 
    case when family = 'Dragon, True' then floor((challenge_rating * 4) / 3) 
    else challenge_rating end;

/*
=============================
d20.monster
.armor_class
.touch_ac
.flat_footed_ac
=============================
*/ 

update d20.monster set (armor_class, touch_ac, flat_footed_ac) = (
    select ac[1] :: integer, ac[2] :: integer, ac[3] :: integer
    from monster m, regexp_matches(m.armor_class, '([+-]?[0-9]+) .*, touch ([+-]?[0-9]+), flat-footed ([+-]?[0-9]+)') ac
    where m.id = d20.monster.monster_id
);    

/*
=============================
d20.monster
.strength
.dexterity
.constitution
.intelligence
.wisdom
.charisma
=============================
*/ 

update d20.monster set (strength, dexterity, constitution, intelligence, wisdom, charisma) = (
    select 
        nullif(ability_scores[1], '-') :: integer as strength, 
        nullif(ability_scores[2], '-') :: integer as dexterity,
        nullif(ability_scores[3], '-') :: integer as constitution,
        nullif(ability_scores[4], '-') :: integer as intelligence,
        nullif(ability_scores[5], '-') :: integer as wisdom,
        nullif(ability_scores[6], '-') :: integer as charisma
    from monster m, regexp_matches(m.abilities, 'Str (\-|[0-9]+).*, Dex (\-|[0-9]+).*, Con (\-|[0-9]+).*, Int (\-|[0-9]+).*, Wis (\-|[0-9]+).*, Cha (\-|[0-9]+)') as ability_scores
    where m.id = d20.monster.monster_id
);

commit transaction;
set client_min_messages = notice;