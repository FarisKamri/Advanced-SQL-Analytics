with
  
order_tbl as 
(
    select  date_trunc('month', date(order_create_date)) as ym
            , grass_date
            ,date(order_create_date)                     as order_date
            ,order_id
            ,order_item_id                               as item_id
            ,order_model_id                              as model_id
            ,order_buyer_id                              as buyer_id
            ,order_fraction
            ,gmv_usd
    from    mp.mart_mkt_order_item a
    where tz_type = 'local' 
        and grass_date = (select max(grass_date) from mp.mart_mkt_order_item)
        and date(order_create_date) > date('2023-10-31')

)

, buyer_agg_raw as (
    select grass_date 
            , buyer_id 
            , sum(order_fraction) as orders 
            , sum(gmv_usd)        as gmv_usd 
    from order_tbl 
    group by 1,2 
)

, buyer_agg as (
    select grass_date 
            , buyer_id 
            , orders 
            , sum(orders) over (partition by buyer_id order by grass_date) as cum_orders  
            , sum(gmv_usd) as gmv_usd 
    from buyer_agg_raw
    group by 1,2,3
)


, buyer_segment as (
    select grass_date 
            , buyer_id 
            , case  when cum_orders < 13 then 'New_Buyers'
                    when cum_orders >= 13 and cum_orders <= 30 then 'Mature'
                    else 'Super_Mature' end as buyer_segment 
            , cum_orders 
            , orders 
            , gmv_usd 
    from buyer_agg 
)

, segment_movement as (
    select grass_date
        , buyer_id
        , buyer_segment as current_segment
        , lag(buyer_segment) over (partition by buyer_id order by grass_date) as previous_segment
        , orders 
        , gmv_usd 
    from buyer_segment

)

select grass_date
        , previous_segment as from_segment
        , current_segment  as to_segment
        , count(*) movement_count
        , sum(orders)  as orders
        , sum(gmv_usd) as gmv_usd
    from segment_movement
    where grass_date > date('2024-02-29')
       group by 1,2,3 
       order by 1,
       case previous_segment
        when 'New_Buyers'   then 1
        when 'Mature'       then 2
        when 'Super_Mature' then 3
    END,
    case current_segment
        when 'New_Buyers'   then 1
        when 'Mature'       then 2
        when 'Super_Mature' then 3
        end;
