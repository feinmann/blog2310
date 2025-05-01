import pandas as pd
import psycopg2
from psycopg2 import sql

def model(dbt, session):
    dbt.config(materialized="table")

    df = dbt.ref("my_sql_model").to_df()

    # --- STEP 1: Create table in PostgreSQL if it doesn't exist ---
    create_table_if_not_exists(df)

    # --- STEP 2: Use DuckDB to load and insert the data ---
    session.execute("INSTALL postgres;")
    session.execute("LOAD postgres;")
    session.execute("ATTACH 'dbname=mydb user=postgres password=postgres host=127.0.0.1' AS mydb (TYPE postgres);")
    session.register("export_df", df)

    session.execute("TRUNCATE mydb.final_output;")

    session.execute("""
        INSERT INTO mydb.final_output
        SELECT * FROM export_df;
    """)

    return df


# Helper: Map pandas dtypes to PostgreSQL types
def duckdb_type(dtype):
    if pd.api.types.is_integer_dtype(dtype):
        return "BIGINT"
    elif pd.api.types.is_float_dtype(dtype):
        return "DOUBLE PRECISION"
    elif pd.api.types.is_bool_dtype(dtype):
        return "BOOLEAN"
    elif pd.api.types.is_datetime64_any_dtype(dtype):
        return "TIMESTAMP"
    else:
        return "TEXT"


# Create the table in Postgres if it doesn't already exist
def create_table_if_not_exists(df):
    conn = psycopg2.connect(
        dbname="mydb",
        user="postgres",
        password="postgres",
        host="127.0.0.1",
        port=5432
    )
    cur = conn.cursor()

    # Check if table exists
    cur.execute("""
        SELECT EXISTS (
            SELECT FROM information_schema.tables
            WHERE table_schema = 'public'
            AND table_name = 'final_output'
        );
    """)
    exists = cur.fetchone()[0]

    if not exists:
        # Build CREATE TABLE statement
        columns = [
            sql.SQL("{} {}").format(
                sql.Identifier(col),
                sql.SQL(duckdb_type(dtype))
            )
            for col, dtype in zip(df.columns, df.dtypes)
        ]
        create_stmt = sql.SQL("CREATE TABLE final_output ({})").format(
            sql.SQL(", ").join(columns)
        )

        cur.execute(create_stmt)
        conn.commit()
        print("✅ Created table 'final_output' in PostgreSQL")

    cur.close()
    conn.close()


