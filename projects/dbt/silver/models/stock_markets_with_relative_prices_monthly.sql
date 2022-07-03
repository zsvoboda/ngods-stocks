select  distinct
		to_date(concat(date_format(dt, 'yyyy-MM'),'-01'), 'yyyy-MM-dd') as dt,
		symbol,
		first(price_open) over (partition by symbol, date_format(dt, 'yyyy-MM') order by dt rows between unbounded preceding and unbounded following) as price_open,
		max(price_high) over (partition by symbol, date_format(dt, 'yyyy-MM') order by dt rows between unbounded preceding and unbounded following) as price_high,
		min(price_low) over (partition by symbol, date_format(dt, 'yyyy-MM') order by dt rows between unbounded preceding and unbounded following) as price_low,
		last(price_close) over (partition by symbol, date_format(dt, 'yyyy-MM') order by dt rows between unbounded preceding and unbounded following) as price_close,
		first(price_open_relative) over (partition by symbol, date_format(dt, 'yyyy-MM') order by dt rows between unbounded preceding and unbounded following) as price_open_relative,
		max(price_high_relative) over (partition by symbol, date_format(dt, 'yyyy-MM') order by dt rows between unbounded preceding and unbounded following) as price_high_relative,
		min(price_low_relative) over (partition by symbol, date_format(dt, 'yyyy-MM') order by dt rows between unbounded preceding and unbounded following) as price_low_relative,
		last(price_close_relative) over (partition by symbol, date_format(dt, 'yyyy-MM') order by dt rows between unbounded preceding and unbounded following) as price_close_relative,
		sum(volume) over (partition by symbol, date_format(dt, 'yyyy-MM') order by dt rows between unbounded preceding and unbounded following) as volume,
		sum(dividends) over (partition by symbol, date_format(dt, 'yyyy-MM') order by dt rows between unbounded preceding and unbounded following) as dividends
	from {{ ref('stock_markets_with_relative_prices') }}
