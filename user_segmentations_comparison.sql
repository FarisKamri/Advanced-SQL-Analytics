/***************************************************
|| Mature/Whale User Segmentation To Add To Remove New Refresh ||
***************************************************/
-- mature
CREATE TABLE IF NOT EXISTS ls_oct_24_segmentation_mature_toadd_toremove (
    userid bigint 
    , to_do varchar
);

DELETE FROM ls_oct_24_segmentation_mature_toadd_toremove ;
insert into ls_oct_24_segmentation_mature_toadd_toremove (


select * from (
with 
current_tag as (
    select distinct user_id as userid
    from dev_mybi_general.ls_sep_24_segmentation_v4
    where 
        ls_segment = 'Mature'
)

, new_tag as (
    select distinct user_id as userid
    from dev_mybi_general.ls_oct_24_segmentation
        where 
        ls_segment = 'Mature'
)

, full_users as (
    select userid from current_tag
    union 
    select userid from new_tag
)

, agg as (
    select a.userid 
            , case when b.userid is not null then 1 else 0 end as is_current_tag 
            , case when c.userid is not null then 1 else 0 end as is_new_tg 
    from full_users a 
    left join current_tag b on a.userid = b.userid 
    left join new_tag c     on a.userid = c.userid 
)

, to_add as (
    select distinct userid 
    from agg 
    where is_current_tag = 0 and is_new_tg = 1 
)

, to_remove as (
    select distinct userid 
    from agg 
    where is_current_tag = 1 and is_new_tg = 0
)

, final_agg as (
    select userid, 'To Add'    as to_do from to_add 
    union all 
    select userid, 'To Remove' as to_do from to_remove 
)

select * from final_agg 
)
);
-- whale
CREATE TABLE IF NOT EXISTS ls_oct_24_segmentation_whale_toadd_toremove (
    userid bigint 
    , to_do varchar
);

DELETE FROM ls_oct_24_segmentation_whale_toadd_toremove ;
insert into ls_oct_24_segmentation_whale_toadd_toremove (

select * from (
with 
current_tag as (
    select distinct user_id as userid
    from dev_mybi_general.ls_sep_24_segmentation_v4
    where 
        ls_segment = 'Whale'
)

, new_tag as (
    select distinct user_id as userid
    from dev_mybi_general.ls_oct_24_segmentation
        where 
        ls_segment = 'Whale'
)

, full_users as (
    select userid from current_tag
    union 
    select userid from new_tag
)

, agg as (
    select a.userid 
            , case when b.userid is not null then 1 else 0 end as is_current_tag 
            , case when c.userid is not null then 1 else 0 end as is_new_tg 
    from full_users a 
    left join current_tag b on a.userid = b.userid 
    left join new_tag c     on a.userid = c.userid 
)

, to_add as (
    select distinct userid 
    from agg 
    where is_current_tag = 0 and is_new_tg = 1 
)

, to_remove as (
    select distinct userid 
    from agg 
    where is_current_tag = 1 and is_new_tg = 0
)

, final_agg as (
    select userid, 'To Add'    as to_do from to_add 
    union all 
    select userid, 'To Remove' as to_do from to_remove 
)

select * from final_agg 
)
);
--------------------------------Checking Numbers Part------------------------------------------------------------
select 
    to_do as Action
    , count(distinct userid)    as "Mature User Amount "
from ls_oct_24_segmentation_mature_toadd_toremove
group by 1
order by 1;


select 
    to_do as Action
    , count(distinct userid)    as "Whale User Amount "
from ls_oct_24_segmentation_whale_toadd_toremove
group by 1
order by 1;

select ls_segment, count(distinct user_id)  as "New user count" 
from dev_mybi_general.ls_oct_24_segmentation
group by 1 
order by 1;

select ls_segment, count(distinct user_id)  as "Previous user count" 
from dev_mybi_general.ls_sep_24_segmentation_v4
group by 1 
order by 1;

-----------------------------------------------------------------------------------------------------------------
