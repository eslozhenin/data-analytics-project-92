/*общее количество покупателей*/
select distinct count(customer_id) as customers_count
from customers;

/*10 лучших продавцов*/
select
    concat(e.first_name, ' ', e.last_name) as seller,
    count(s.sales_id) as operations,
    floor(sum(s.quantity * p.price)) as income
from sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by seller
order by income desc
limit 10;

/*продавцы с меньшей средней выручкой*/
with avg_sellers as (
    select
        concat(e.first_name, ' ', e.last_name) as seller,
        floor(avg(s.quantity * p.price) over (partition by s.sales_person_id)) as average_income,
        floor(avg(s.quantity * p.price) over ()) as avg_overall
    from sales as s
    inner join employees as e
        on s.sales_person_id = e.employee_id
    inner join products as p
        on s.product_id = p.product_id
)

select
    seller,
    average_income
from avg_sellers
where average_income < avg_overall
group by seller, average_income
order by average_income;

/*выручка по дням недели*/
with weekly_gain as (
    select
        concat(e.first_name, ' ', e.last_name) as seller,
        trim(to_char(s.sale_date, 'day')) as day_of_week,
        to_char(s.sale_date, 'id') as number_weekday,
        floor(sum(s.quantity * p.price)) as income
    from sales as s
    inner join employees as e
        on s.sales_person_id = e.employee_id
    inner join products as p
        on s.product_id = p.product_id
    group by seller, day_of_week, number_weekday
    order by number_weekday, seller
)

select
    seller,
    day_of_week,
    income
from weekly_gain;

/*покупатели по возрастным группам*/
select
    case
        when age between 16 and 25 then '16-25'
        when age between 26 and 40 then '26-40'
        else '40+'
    end as age_category,
    count(customer_id) as age_count
from customers
group by age_category
order by age_category;

/*уникальные покупателей с выручкой*/
select
    to_char(s.sale_date, 'yyyy-mm') as selling_month,
    count(distinct customer_id) as total_customers,
    floor(sum(s.quantity * p.price)) as income
from sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by selling_month
order by selling_month asc;

/*первая покупка по акции*/
with special_offer as (
    select distinct
        s.customer_id,
        p.price,
        s.sale_date,
        concat(c.first_name, ' ', c.last_name) as customer,
        row_number()
            over (
                partition by s.customer_id
                order by s.sale_date
            )
        as rn,
        concat(e.first_name, ' ', e.last_name) as seller
    from sales as s
    inner join employees as e
        on s.sales_person_id = e.employee_id
    inner join products as p
        on s.product_id = p.product_id
    inner join customers as c
        on s.customer_id = c.customer_id
    order by s.customer_id
)

select
    customer,
    sale_date,
    seller
from special_offer
where price = '0' and rn = 1;