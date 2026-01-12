# Work with valid configurations

`S7schema()` provides a generic way of working with yaml configuration
files.

The object is created by supplying both an initial YAML configuration
(`file`) and the JSON schema definition (`schema`) of the configuration
file.

The initial configuration is validated before the new object is
returned. If not valid the first error is thrown, together with a path
to the entry in the YAML file, and a description of the error.

The `S7schema` class inherits from `list`, ensuring that the content of
the YAML file can be accessed as if read directly with
[`yaml::read_yaml()`](https://yaml.r-lib.org/reference/read_yaml.html),
and supports the below workflow:

1.  Read and validate config file: `x <- S7schema(...)`

2.  Edit content as if it was a list: `x$new_entry <- "new_value"`

3.  Validate new content against the original schema: `validate(x)`

4.  Use values in downstream functions: `x$new_entry`

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
  used to validate the content (read-only).

## Examples

``` r
# Work with yaml configuration file:
S7schema(
  file = system.file("examples/config.yml", package = "S7schema"),
  schema = system.file("examples/schema.json", package = "S7schema")
)
#> <S7schema::S7schema> List of 1
#>  $ my_config_var: int 1
#>  @ schema   : chr "/home/runner/work/_temp/Library/S7schema/examples/schema.json"
#>  @ validator: <S7schema::validator>
#>  .. @ context:Classes 'V8', 'environment' <environment: 0x5562e9bcad50> 
```
