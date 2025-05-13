SELECT
    id,
    full_name,
    name_length
FROM {{ ref('my_python_model') }}
WHERE name_length > 10
