# One-shot validation of configurations

Check if a configuration is in accordance with a JSON schema definition.

It is possible to either validate an existing `list` object in memory or
an existing `yaml` configuration file.

## Usage

``` r
validate_list(x, schema)

validate_yaml(file, schema)
```

## Arguments

- x:

  `list` object to validate

- schema:

  `character(1)` path to a JSON schema.

- file:

  `character(1)` path to a yaml file to be checked. Or `NULL` if created
  using `.data`.

## Value

- `validate_list()`: `invisible(x)`

&nbsp;

- `validate_yaml()`: `invisible(file)`

## Details

The content is validated as R reads it: files are read with
[`yaml::read_yaml()`](https://yaml.r-lib.org/reference/read_yaml.html),
and `list` or `S7schema` objects are converted with
[`to_yaml()`](https://novonordisk-opensource.github.io/S7schema/reference/to_yaml.md)
and read back before validation. See internal
[`validator()`](https://novonordisk-opensource.github.io/S7schema/reference/validator.md)
documentation for more info on how the validation is done.

R reads a YAML sequence with one item (`[a]`) as a single value (`"a"`).
For fields that can hold one or more values, allow both forms in the
schema with `oneOf`:

    {
      "oneOf": [
        {"type": "string"},
        {"type": "array", "items": {"type": "string"}}
      ]
    }

`NA`, `NaN`, and `Inf` values are validated as `null`. A field that may
be missing must allow `null` in the schema:

    {"type": ["string", "null"]}

## See also

[`S7schema()`](https://novonordisk-opensource.github.io/S7schema/reference/S7schema.md)

## Examples

``` r
# Validate list object in memory
validate_list(
  x = list(my_config_var = 1),
  schema = system.file("examples/schema.json", package = "S7schema")
) |>
  print()
#> $my_config_var
#> [1] 1
#> 

# Validate yaml file on disk
validate_yaml(
  file = system.file("examples/config.yml", package = "S7schema"),
  schema = system.file("examples/schema.json", package = "S7schema")
) |>
  print()
#> [1] "/home/runner/work/_temp/Library/S7schema/examples/config.yml"
```
