# errors reference the user's call

    Code
      S7schema(.data = list(illegal = "entry"), schema = schema)
    Condition
      Error in `S7schema()`:
      ! (root) must NOT have additional properties
      x additionalProperty: illegal
    Code
      S7schema(.data = list(id = "test"), schema = "missing.json")
    Condition
      Error in `S7schema()`:
      ! Illegal file reference 'missing.json'
      i File does not exist
    Code
      S7schema(file = "missing.yml", schema = schema)
    Condition
      Error in `S7schema()`:
      ! Illegal file reference 'missing.yml'
      i File does not exist
    Code
      validate_yaml(file = "missing.yml", schema = schema)
    Condition
      Error in `validate_yaml()`:
      ! Illegal file reference 'missing.yml'
      i File does not exist

# errors from S7 validation reference the user's call

    Code
      validate(x)
    Condition
      Error in `validate()`:
      ! /id must be string
      x type: string
      i current value: 1
    Code
      write_config(x, path = withr::local_tempfile(fileext = ".yml"))
    Condition
      Error in `write_config()`:
      ! /id must be string
      x type: string
      i current value: 1
    Code
      y@schema <- bad
    Condition
      Error in `@<-`:
      ! Invalid JSON schema 'schemas/invalid_type.json'
      x schema is invalid: data/type must be equal to one of the allowed values, data/type must be array, data/type must match a schema in anyOf
    Code
      S7::set_props(y, schema = bad)
    Condition
      Error in `S7::set_props()`:
      ! Invalid JSON schema 'schemas/invalid_type.json'
      x schema is invalid: data/type must be equal to one of the allowed values, data/type must be array, data/type must match a schema in anyOf

