cube(`StockMarketsPrediction`, {
  sql: `select 
            m.dt,
            m.symbol,
            p.price_predicted,
            m.price_open,
            m.price_close,
            m.price_low,
            m.price_high
          from gold.stock_markets m
          left join gold.stock_markets_prediction p on p.dt = m.dt and p.symbol = m.symbol`,
  
  preAggregations: {
    // Pre-Aggregations definitions go here
    // Learn more here: https://cube.dev/docs/caching/pre-aggregations/getting-started  
  },
  
  joins: {
  },
  
  measures: {
    
    count: {
      type: `count`
    },

    price_high: {
      sql: `price_high`,
      title: `Price High [MAX]`,
      type: `max`
    },
    
    price_low: {
      sql: `price_low`,
      title: `Price Low [MIN]`,
      type: `min`
    },
    
    price_open_avg: {
      sql: `price_open`,
      title: `Price Open [AVG]`,
      type: `avg`
    },
    
    price_close_avg: {
      sql: `price_close`,
      title: `Price Close [AVG]`,
      type: `avg`
    },

    price_predicted: {
      sql: `price_predicted`,
      title: `Price Predicted [AVG]`,
      type: `avg`
    }

  },
  
  dimensions: {
        
    symbol: {
      sql: `symbol`,
      title: `Symbol`,
      type: `string`
    },
    
    dt: {
      sql: `dt`,
      title: `Date`,
      type: `time`
    }

  },

  dataSource: `default`
});
