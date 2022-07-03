cube(`StockMarketsMonthly`, {
  sql: `SELECT * FROM gold.stock_markets_monthly`,
  
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

    volume: {
      sql: `volume`,
      title: `Volume [SUM]`,
      type: `sum`
    },

    volume_avg: {
      sql: `volume`,
      title: `Volume [AVG]`,
      type: `avg`
    },

    volume_min: {
      sql: `volume`,
      title: `Volume [MIN]`,
      type: `min`
    },

    volume_max: {
      sql: `volume`,
      title: `Volume [MAX]`,
      type: `max`
    },

    dividend: {
      sql: `dividend`,
      title: `Dividend [SUM]`,
      type: `sum`
    },

    dividend_avg: {
      sql: `dividend`,
      title: `Dividend [AVG]`,
      type: `avg`
    },

    dividend_min: {
      sql: `dividend`,
      title: `Dividend [MIN]`,
      type: `min`
    },

    dividend_max: {
      sql: `dividend`,
      title: `Dividend [MAX]`,
      type: `max`
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

    price_high_relative: {
      sql: `price_high_relative`,
      title: `Relative Price High [MAX]`,
      type: `max`
    },
    
    price_low_relative: {
      sql: `price_low_relative`,
      title: `Relative Price Low [MIN]`,
      type: `min`
    },
    
    price_open_relative_avg: {
      sql: `price_open_relative`,
      title: `Relative Price Open [AVG]`,
      type: `avg`
    },
    
    price_close_relative_avg: {
      sql: `price_close_relative`,
      title: `Relative Price Close [AVG]`,
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
