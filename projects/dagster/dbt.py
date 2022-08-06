from dagster import job, op

from dagster_dbt import dbt_cli_resource


def _dbt_run(context):
    pdir = context.op_config['project_dir']
    context.log.info(f"elt: executing dbt run with project_dir: '{pdir}'")
    if 'select' in context.op_config:
        s = context.op_config['select']        
        context.log.info(f"elt: executing dbt run with select: '{s}'")
        context.resources.dbt.cli("run", project_dir=pdir, select=s)
    else:
        context.resources.dbt.cli("run", project_dir=pdir)

def _dbt_test(context):
    pdir = context.op_config['project_dir']
    context.log.info(f"elt: executing dbt test with project_dir: '{pdir}'")
    if 'select' in context.op_config:
        s = context.op_config['select']        
        context.log.info(f"elt: executing dbt run with select: '{s}'")
        context.resources.dbt.cli("test", project_dir=pdir, select=s)
    else:
        context.resources.dbt.cli("test", project_dir=pdir)

def _dbt_generate_docs(context):
    pdir = context.op_config['project_dir']
    context.log.info(f"elt: executing dbt docs generate with project_dir: '{pdir}'")
    if 'select' in context.op_config:
        s = context.op_config['select']        
        context.log.info(f"elt: executing dbt run with select: '{s}'")
        context.resources.dbt.cli("docs generate", project_dir=pdir, select=s)
    else:
        context.resources.dbt.cli("docs generate", project_dir=pdir)

def _dbt_source_freshness(context):
    pdir = context.op_config['project_dir']
    context.log.info(f"elt: executing dbt source freshness with project_dir: '{pdir}'")
    if 'select' in context.op_config:
        s = context.op_config['select']        
        context.log.info(f"elt: executing dbt run with select: '{s}'")
        context.resources.dbt.cli("source freshness", project_dir=pdir, select=s)
    else:
        context.resources.dbt.cli("source freshness", project_dir=pdir)


@op(required_resource_keys={'dbt'})
def dbt_bronze_run_op(context, dependent_job=None):
    _dbt_run(context)
    
@op(required_resource_keys={'dbt'})
def dbt_bronze_test_doc_sources_op(context, dependent_job=None):
    _dbt_test(context)
    _dbt_generate_docs(context)
    _dbt_source_freshness(context)


@op(required_resource_keys={'dbt'})
def dbt_silver_run_op(context, dependent_job=None):
    _dbt_run(context)

@op(required_resource_keys={'dbt'})
def dbt_silver_test_doc_sources_op(context, dependent_job=None):
    _dbt_test(context)
    _dbt_generate_docs(context)
    _dbt_source_freshness(context)


@op(required_resource_keys={'dbt'})
def dbt_gold_run_op(context, dependent_job=None):
    _dbt_run(context)

@op(required_resource_keys={'dbt'})
def dbt_gold_test_doc_sources_op(context, dependent_job=None):
    _dbt_test(context)
    _dbt_generate_docs(context)
    _dbt_source_freshness(context)


@job(resource_defs={'dbt': dbt_cli_resource})
def dbt_bronze():
    dbt_bronze_test_doc_sources_op(dbt_bronze_run_op())


@job(resource_defs={'dbt': dbt_cli_resource})
def dbt_silver():    
    dbt_silver_test_doc_sources_op(dbt_silver_run_op())

@job(resource_defs={'dbt': dbt_cli_resource})
def dbt_gold():    
    dbt_gold_test_doc_sources_op(dbt_gold_run_op())

@job(resource_defs={'dbt': dbt_cli_resource})
def dbt_all():    
    dbt_gold_test_doc_sources_op(
        dbt_gold_run_op(
            dbt_silver_test_doc_sources_op(
                dbt_silver_run_op(
                    dbt_bronze_test_doc_sources_op(
                        dbt_bronze_run_op()
                    )
                )
            )
        )
    )
