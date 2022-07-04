import os
import re

from datetime import datetime, timedelta

import yfinance as yf

from dagster import job, op

def yesterday(date:str) -> str:    
    yesterday = datetime.now() - timedelta(1)
    return datetime.strftime(yesterday, '%Y-%m-%d')


@op(config_schema={"target_file": str, "symbols": [str], "start_date": str, "end_date": str})
def download_yahoo_finance_files_op(context, dependent_job=None):
    target_file = context.op_config["target_file"]
    symbols = context.op_config["symbols"]
    start_date  = context.op_config["start_date"]
    if not re.match(start_date, "^[0-9]{4}-[0-9]{2}-[0-9]{2}$"):
        start_date = '2000-01-01'
    end_date = context.op_config["end_date"]
    if not re.match(end_date, "^[0-9]{4}-[0-9]{2}-[0-9]{2}$"):
        end_date = yesterday(start_date)

    if os.path.exists(target_file):
        os.remove(target_file)

    for symbol in symbols:
        ticker = yf.Ticker(symbol)
        df = ticker.history(start=start_date, end=end_date)
        df.insert(0, 'Symbol', symbol)
        df.to_csv(target_file, mode='a', header=False, index=True)

    return target_file


@job
def download_yahoo_finance_files():
    download_yahoo_finance_files_op()