select 
    challenge_rating,     
    round(least(6, greatest(2, ((armor_class - ((attack_low + attack_high) * 0.5)) * 0.3))) || '+' as attack1,
    case when challenge_rating <= 5 then '-' else round(least(6, greatest(2, ((armor_class - ((attack_low + attack_high) * 0.5)) - 0.25) * 0.3))) || '+' end as attack2,
    case when challenge_rating <= 10 then '-' else round(least(6, greatest(2, ((armor_class - ((attack_low + attack_high) * 0.5)) - 0.5) * 0.3))) || '+' end as attack3,
    case when challenge_rating <= 15 then '-' else round(least(6, greatest(2, ((armor_class - ((attack_low + attack_high) * 0.5)) - 0.75) * 0.3))) || '+' end as attack4    
from d20.monsters_by_adjusted_cr;


/*
select id, name, saves from monster where id not in (
    select id from (
        select id, regexp_matches(saves, '^Fort ([+-][0-9]*).* Ref ([+-][0-9]*).* Will ([+-][0-9]*).*$') from monster 
    ) m
)

select id, name, saves, sv[1] as fort, sv[2] as ref, sv[3] as will
select count(*)
from (select id, name, saves, regexp_matches(saves, 'Fort ([+-][0-9]*).* Ref ([+-][0-9]*).* Will ([+-][0-9]*)') as sv from monster) m
where saves <> ('Fort ' || sv[1] || ', Ref ' || sv[2] || ', Will ' || sv[3])
*/

/*
select distinct subtype
from (
select m.id as monster_id, btrim(st.subtype) as subtype
from monster as m, regexp_split_to_table(m.descriptor, ',') as st(subtype)
) mst
order by subtype

select 
    adjusted_challenge_rating, 
    percentile_cont(0.50) within group(order by hit_dice) as hit_dice,
    percentile_cont(0.50) within group(order by hit_points) as hit_points
from d20.monster
group by adjusted_challenge_rating
order by adjusted_challenge_rating

select
    id, 
    name,
    attacks
from monster, regexp_split_to_table(full_attack, ' or ') fa(attacks)

select m.id, m.name, f.attacks
from monster m
join (select m.id, f.attacks from monster m, regexp_split_to_table(m.full_attack, ' or ') f(attacks)) f on (m.id = f.id)

select m.id, m.name, regexp_matches(full_attack, '([0-9]*) ([a-zA-Z\s]+) ([+-][0-9]+) ((?:melee)|(?:ranged))')
from monster m


select id, attacks from monster, regexp_split_to_table(full_attack, '[;]? or ') fa(attacks)


select id, name, replace(full_attack, ' or ', '<<<; or >>>') as full_attack from monster where full_attack like '% or %' and full_attack not like '%; or %';

select id, name, replace(replace(regexp_replace(full_attack, '(\(.*) or (.*\))', '\1 OR \2', 'g'), ' or ', '; or '), ' OR ', ' or ') as full_attack from monster

select
    id,

from 
(select id, case when full_attack ~ '[^;] or ' then replace(replace(regexp_replace(full_attack, '(\(.*) or (.*\))', '\1 OR \2', 'g'), ' or ', '; or '), ' OR ', ' or ') else full_attack end as full_attack from monster) m, regexp_split_to_table(m.full_attack, '; or ')


select id, name, 
    replace(
        replace(
            replace(
                replace(
                    regexp_replace(
                        regexp_replace(
                            full_attack, 
                            '(\([^\)]*) or (.*\))', 
                            '\1 OR \2', 
                            'g'
                        ), 
                        '(\([^\)]*) and (.*\))', 
                        '\1 AND \2', 
                        'g'
                    ),
                    '; or ', 
                    ' | '
                ),
                ' or ',
                ' | ',
            ),
            ', and '
            ' & '
        ),
        ' and ',
        ' & '


    select id, name, full_attack from monster where full_attack ~ '\([^\)]* or [^\)]*\)' or full_attack ~ '\([^\)]* and [^\)]*\)' or full_attack ~ '\([^\)]*, [^\)]*\)';
from monster

select id, replace(full_att)


select id, n1, n2, fa2.attack from monster m, regexp_split_to_table(full_attack, ' or ') with ordinality fa(attacks, n1), regexp_split_to_table(attacks, '(?:and|,)') with ordinality fa2(attack, n2)
where id not in (14, 331, 424, 491, 603)




 14 | Flesh Colossus                         | Colossal club +79 (6d6+18) melee or 2 slams +79 (4d6+12) melee or thrown object (weighing 10 tons or less) +65 (4d6+12) ranged


select
    adjusted_challenge_rating as challenge_rating,
    count(*),
    percentile_cont(0.5) within group (order by hit_dice) as hit_dice,
    percentile_cont(0.5) within group (order by hit_points) as hit_points,
    percentile_cont(0.5) within group (order by armor_class) as armor_class,
    percentile_cont(0.5) within group (order by greatest(fort_save, ref_save, will_save)) as good_save,
    percentile_cont(0.5) within group (order by least(fort_save, ref_save, will_save)) as poor_save
from d20.monster
where adjusted_challenge_rating is not null
group by adjusted_challenge_rating

select
    coalesce(r.challenge_rating, a.challenge_rating) as challenge_rating,
    r.count as r_count, a.count as a_count,
    r.hit_dice as r_hit_dice, a.hit_dice as a_hit_dice,
    r.hit_points as r_hit_points, a.hit_points as a_hit_points,
    r.armor_class as r_armor_class, a.armor_class as a_armor_class,
    r.good_save as r_good_save, a.good_save as a_good_save,
    r.poor_save as r_poor_save, a.poor_save as a_poor_save
from d20.monsters_by_raw_cr r
full outer join d20.monsters_by_adjusted_cr a on (r.challenge_rating = a.challenge_rating)
where r.count <> a.count

select
 from d20.monster m, (
   
) r
order by m.adjusted_challenge_rating;

select
    m.challenge_rating,
    floor(r.intercept_hit_dice + (m.challenge_rating * r.slope_hit_dice)) as hit_dice,
    floor(r.intercept_armor_class + (m.challenge_rating * r.slope_armor_class)) as armor_class
from (select distinct adjusted_challenge_rating as challenge_rating from d20.monster) m,
(
    select
        regr_slope(hit_dice, adjusted_challenge_rating) as slope_hit_dice,
        regr_intercept(hit_dice, adjusted_challenge_rating) as intercept_hit_dice,
        regr_r2(hit_dice, adjusted_challenge_rating) as r2_hit_dice,
        regr_slope(armor_class, adjusted_challenge_rating) as slope_armor_class,
        regr_intercept(armor_class, adjusted_challenge_rating) as intercept_armor_class,
        regr_r2(armor_class, adjusted_challenge_rating) as r2_armor_class
    from d20.monster
) r
order by m.challenge_rating;



select
    adjusted_challenge_rating as challenge_rating,
    mode() within group (order by hit_dice) as hit_dice,
    mode() within group (order by hit_points) as hit_points,
    mode() within group (order by armor_class) as armor_class,
    mode() within group (order by fort_save) as fort_save,
    mode() within group (order by ref_save) as ref_save,
    mode() within group (order by will_save) as will_save,
    mode() within group (order by greatest(fort_save, ref_save, will_save)) as good_save,
    mode() within group (order by least(fort_save, ref_save, will_save)) as poor_save
from d20.monster
group by adjusted_challenge_rating
order by adjusted_challenge_rating

select
    adjusted_challenge_rating,
    percentile_cont(0.0/6.0) within group (order by armor_class) as ac_0,
    percentile_cont(1.0/6.0) within group (order by armor_class) as ac_1,
    percentile_cont(2.0/6.0) within group (order by armor_class) as ac_2,
    percentile_cont(3.0/6.0) within group (order by armor_class) as ac_3,
    percentile_cont(4.0/6.0) within group (order by armor_class) as ac_4,
    percentile_cont(5.0/6.0) within group (order by armor_class) as ac_5,
    percentile_cont(6.0/6.0) within group (order by armor_class) as ac_6
from d20.monster
group by adjusted_challenge_rating
order by adjusted_challenge_rating


select
    m.challenge_rating,
    floor(r.intercept + (m.challenge_rating * r.slope)) as hit_dice
from
(select distinct adjusted_challenge_rating as challenge_rating from d20.monster) m,
(
    select 
        regr_intercept(hit_dice, challenge_rating) as intercept,
        regr_slope(hit_dice, challenge_rating) as slope
    from
    (
        select
            adjusted_challenge_rating as challenge_rating,
            percentile_cont(0.5) within group (order by hit_dice) as hit_dice
        from d20.monster
        group by adjusted_challenge_rating
        order by adjusted_challenge_rating
    ) m
) r
order by m.challenge_rating;


select
    m.monster_id as id,
    m.name,
    m.hit_dice,
    round((7 - (select percent_rank(m.hit_points) within group (order by n.hit_points) from d20.monster n where n.hit_dice = m.hit_dice) * 6)) as hit_points,
    round((7 - (select percent_rank(m.armor_class) within group (order by n.armor_class) from d20.monster n where n.hit_dice = m.hit_dice) * 6)) as armor_class,
    round((7 - (select percent_rank(m.fort_save) within group (order by n.fort_save) from d20.monster n where n.hit_dice = m.hit_dice) * 6)) as fort_save,
    round((7 - (select percent_rank(m.ref_save) within group (order by n.ref_save) from d20.monster n where n.hit_dice = m.hit_dice) * 6)) as ref_save,
    round((7 - (select percent_rank(m.will_save) within group (order by n.will_save) from d20.monster n where n.hit_dice = m.hit_dice) * 6)) as will_save,
    m.adjusted_challenge_rating as challenge_rating
from d20.monster m    
order by hit_dice, name

select
    monster_id,
    least(min(attack_low), min(attack_high)) as attack_low,
    greatest(max(attack_low), max(attack_high)) as attack_high,
    min(damage) as damage_low,
    max(damage) as damage_high
from (select monster_id, option_id, min(attack) as attack_low, max(attack) as attack_high, sum(damage) as damage from monster_attack_list group by monster_id, option_id) m
group by monster_id;

select m.monster_id, min(m2.attack) as attack_low, max(m2.attack) as attack_high, min(m.damage) as damage_low, max(m.damage) as damage_high
from (select monster_id, option_id, sum(damage) as damage from monster_attack_list m group by monster_id, option_id) m
join monster_attack_list m2 on (m.monster_id = m2.monster_id and m.option_id = m2.option_id)
where m.monster_id = 365
group by m.monster_id

select 
    challenge_rating, 
    hit_dice, 
    hit_points, 
    armor_class, 
    least(0.95, greatest(0.05, (21 - (armor_class - ((attack_low + attack_high) * 0.5))) * 0.05)) as accuracy,
    ceiling((hit_points / ((damage_low + damage_high) * 0.5))) as hits_to_kill
from d20.monsters_by_adjusted_cr;

select 
    challenge_rating,     
    least(6, greatest(2, ((armor_class - ((attack_low + attack_high) * 0.5)) * 0.3))) || '+' as attack1,
    case when challenge_rating <= 5 then '-' else least(6, greatest(2, ((armor_class - ((attack_low + attack_high) * 0.5) - 0.25) * 0.3))) || '+' as attack2,
    case when challenge_rating <= 10 then '-' else least(6, greatest(2, ((armor_class - ((attack_low + attack_high) * 0.5) - 0.5) * 0.3))) || '+' as attack3,
    case when challenge_rating <= 15 then '-' else least(6, greatest(2, ((armor_class - ((attack_low + attack_high) * 0.5) - 0.75) * 0.3))) || '+' as attack4    
from d20.monsters_by_adjusted_cr;
    


*/