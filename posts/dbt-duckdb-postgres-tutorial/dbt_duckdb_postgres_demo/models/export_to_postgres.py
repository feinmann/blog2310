import pandas as pd

def model(dbt, session):
    dbt.config(materialized="table")

    df = dbt.ref("my_sql_model").to_df()

    # Install and load the postgres extension
    session.execute("INSTALL postgres;")
    session.execute("LOAD postgres;")
    session.execute("ATTACH 'dbname=mydb user=postgres host=127.0.0.1' AS mydb (TYPE postgres);")

    # Register df as a DuckDB table
    session.register("export_df", df)

    # Now use INSERT INTO ... SELECT * FROM export_df
    # The target table must already exist in PostgreSQL, or you’ll need to CREATE it beforehand
    session.execute("""
        INSERT INTO mydb.final_output
        SELECT * FROM export_df;
    """)

    return df

