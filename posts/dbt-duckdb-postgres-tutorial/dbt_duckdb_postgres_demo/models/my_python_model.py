import pandas as pd

def model(dbt, session):
    dbt.config(materialized="table")

    df = dbt.ref("my_seed_data").to_df()
    df["full_name"] = df["first_name"] + " " + df["last_name"]
    df["name_length"] = df["full_name"].str.len()

    return df
