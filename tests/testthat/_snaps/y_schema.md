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

