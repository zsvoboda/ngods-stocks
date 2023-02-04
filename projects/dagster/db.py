from dagster import job, op, resource
from trino.dbapi import connect

from contextlib import contextmanager


class TrinoConnection:

    def __init__(self, connection_params):
        self._connection_params = connection_params

    @contextmanager
    def get_connection(self):
        conn = connect(host=self._connection_params["host"], port=self._connection_params["port"],
                       user=self._connection_params["user"])
        yield conn
        conn.close()


@resource(config_schema={"host": str, "port": str, "user": str, "password": str})
def trino_resource(init_context):
    connection_params = {
        "host": init_context.resource_config["host"],
        "port": init_context.resource_config["port"],
        "user": init_context.resource_config["user"],
        "password": init_context.resource_config["password"]
    }
    return TrinoConnection(connection_params)


@op(required_resource_keys={'trino'})
def create_schemas_op(context, dependent_job=None):
    trino = context.resources.trino
    with trino.get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("create schema if not exists warehouse.default with (location = 's3a://warehouse/default')")
        cursor.fetchall()
        cursor.execute("create schema if not exists warehouse.bronze with (location = 's3a://warehouse/bronze')")
        cursor.fetchall()
        cursor.execute("create schema if not exists warehouse.silver with (location = 's3a://warehouse/silver')")
        cursor.fetchall()
        cursor.execute("create schema if not exists analytics.gold")
        cursor.fetchall()
        conn.commit()
        cursor.close()


@op(required_resource_keys={'trino'})
def drop_tables_op(context, dependent_job=None):
    trino = context.resources.trino
    drop_all_tables_in_schema(context, trino, "analytics.gold")
    drop_all_tables_in_schema(context, trino, "warehouse.silver")
    drop_all_tables_in_schema(context, trino, "warehouse.bronze")


def drop_all_tables_in_schema(context, trino, schema_name):
    with trino.get_connection() as conn:
        cursor = conn.cursor()
        context.log.info(f"Schema: {schema_name}")
        cursor.execute(f"show tables from {schema_name}")
        tables = cursor.fetchall()   
        cursor.close()     
    with trino.get_connection() as conn:  
        cursor = conn.cursor()
        for table in tables:            
            drop_statement = f"drop table if exists {schema_name}.{table[0]}"
            context.log.info(f"{drop_statement}")
            cursor.execute(drop_statement)
            cursor.fetchall()
        conn.commit()
        cursor.close()


@job(resource_defs={'trino': trino_resource})
def initialize_db():
    drop_tables_op(create_schemas_op())    
