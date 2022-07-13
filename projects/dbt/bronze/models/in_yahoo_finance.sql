select  
		cast(trim(_c0) as date) as dt,
		trim(_c1) as symbol,
		cast(trim(_c2) as numeric(32,16)) as price_open,
		cast(trim(_c3) as numeric(32,16)) as price_high,
		cast(trim(_c4) as numeric(32,16)) as price_low,
		cast(trim(_c5) as numeric(32,16)) as price_close,
		cast(trim(_c6) as long) as volume,
		cast(trim(_c7) as numeric(32,16)) as dividends,
		cast(trim(_c8) as numeric(32,16)) as splits						
	from csv.`/var/lib/ngods/stage/stocks.csv`
