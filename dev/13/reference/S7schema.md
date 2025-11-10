# Work with valid configurations

`S7schema` provides a generic way of working with yaml configuration
files. sds

## Usage

``` r
S7schema(file, schema)
```

## Arguments

- file:

  `character(1)` path to a yaml file to be checked.

- schema:

  `character(1)` path to a JSON schema.

## Value

New `S7schema` object.

## Details

See internal
[`validator()`](https://nn-opensource.github.io/S7schema/reference/validator.md)
documentation for more info on how the validation is done.

## Properties

- schema:

  `character(1)` path to JSON schema being used to validate against.

- validator:

  Internal
  [`validator()`](https://nn-opensource.github.io/S7schema/reference/validator.md)
  used to validate the content.

## Examples

``` r
if (FALSE) {
# Work with yaml configuration file:
S7schema(
  file = "path/to/my/config.yml",
  schema = "path/to/my/schema.json"
)
}
```
