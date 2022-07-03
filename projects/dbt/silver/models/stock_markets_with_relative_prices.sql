select  
		dt,
		symbol,
		price_open,
		price_high,
		price_low,
		price_close,
		price_open / (first(price_close) over (partition by symbol order by dt rows between unbounded preceding and unbounded following)) as price_open_relative,
		price_high / (first(price_close) over (partition by symbol order by dt rows between unbounded preceding and unbounded following)) as price_high_relative,
		price_low / (first(price_close) over (partition by symbol order by dt rows between unbounded preceding and unbounded following)) as price_low_relative,
		price_close / (first(price_close) over (partition by symbol order by dt rows between unbounded preceding and unbounded following)) as price_close_relative,
		volume,
		dividends,
		splits						
	from warehouse.bronze.in_yahoo_finance
