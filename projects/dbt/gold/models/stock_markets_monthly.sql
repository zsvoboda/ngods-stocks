select  
		dt,
		symbol,
		price_open,
		price_high,
		price_low,
		price_close,
		price_open_relative,
		price_high_relative,
		price_low_relative,
		price_close_relative,
		volume,
		dividends
	from warehouse.silver.stock_markets_with_relative_prices_monthly
