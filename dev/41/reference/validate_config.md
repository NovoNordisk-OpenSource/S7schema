# One-shot validation of configurations

Check if a configuration is in accordance with a JSON schema definition.

It is possible to either validate an existing `list` object in memory or
an existing `yaml` configuration file.

## Usage

``` r
validate_list(x, schema, name = NULL)

validate_yaml(file, schema)
```

## Arguments

- x:

  `list` object to validate

- schema:

  `character(1)` path to a JSON schema.

- name:

  `character(1)` or `NULL`. Optional name to identify this list in error
  messages.

- file:

  `character(1)` path to a yaml file to be checked.

## Value

- `validate_list()`: `invisible(x)`

&nbsp;

- `validate_yaml()`: `invisible(file)`

## Details

See internal
[`validator()`](https://novonordisk-opensource.github.io/S7schema/reference/validator.md)
documentation for more info on how the validation is done.

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
