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

  `character(1)` path to a yaml file to be checked.

## Value

- `validate_list()`: `invisible(x)`

&nbsp;

- `validate_yaml()`: `invisible(file)`

## Details

See internal
[`validator()`](https://nn-opensource.github.io/S7schema/reference/validator.md)
documentation for more info on how the validation is done.

## See also

[`S7schema()`](https://nn-opensource.github.io/S7schema/reference/S7schema.md)

## Examples

``` r
if (FALSE) {
# Validate list object in memory
validate_list(
  x = list(a = 1),
  schema = "path/to/my/schema.json"
)

# Validate yaml file on disk
validate_yaml(
  file = "path/to/my/config.yml",
  schema = "path/to/my/schema.json"
)
}
```
