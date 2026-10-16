# invalid schemas give a clean error

    Code
      validate_yaml(file = file, schema = schema)
    Condition
      Error in `validate_yaml()`:
      ! Invalid JSON schema 'schemas/invalid_type.json'
      x schema is invalid: data/type must be equal to one of the allowed values, data/type must be array, data/type must match a schema in anyOf
    Code
      validate_list(x = list(), schema = schema)
    Condition
      Error in `validate_list()`:
      ! Invalid JSON schema 'schemas/invalid_type.json'
      x schema is invalid: data/type must be equal to one of the allowed values, data/type must be array, data/type must match a schema in anyOf
    Code
      S7schema(file = file, schema = schema)
    Condition
      Error in `S7schema()`:
      ! Invalid JSON schema 'schemas/invalid_type.json'
      x schema is invalid: data/type must be equal to one of the allowed values, data/type must be array, data/type must match a schema in anyOf

