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
S7schema(file, schema, .data)
```

## Arguments

- file:

  `character(1)` path to a yaml file to be checked. Or `NULL` if created
  using `.data`.

- schema:

  `character(1)` path to a JSON schema.

- .data:

  [`list()`](https://rdrr.io/r/base/list.html) input to create the
  object. Mutually exclusive with `file`.

## Value

New `S7schema` object.

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

Numbers with up to 16 significant digits are validated exactly. Numbers
that need 17, e.g. `0.1 + 0.2`, are validated exactly in files, but
rounded in `list` and `S7schema` objects, as
[`to_yaml()`](https://novonordisk-opensource.github.io/S7schema/reference/to_yaml.md)
writes them.

## Properties

- schema:

  `character(1)` path to JSON schema being used to validate against.

- validator:

  Internal
  [`validator()`](https://novonordisk-opensource.github.io/S7schema/reference/validator.md)
  used to validate the content (read-only).

- file:

  `character(1)` path to the source YAML file (or `NULL` if not set).

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
#>  .. @ context:Classes 'V8', 'environment' <environment: 0x56105e7bb540> 
#>  @ file     : chr "/home/runner/work/_temp/Library/S7schema/examples/config.yml"

# Create object in memory
S7schema(
  .data = list(my_config_var = 6),
  schema = system.file("examples/schema.json", package = "S7schema")
)
#> <S7schema::S7schema> List of 1
#>  $ my_config_var: num 6
#>  @ schema   : chr "/home/runner/work/_temp/Library/S7schema/examples/schema.json"
#>  @ validator: <S7schema::validator>
#>  .. @ context:Classes 'V8', 'environment' <environment: 0x56105bfce138> 
#>  @ file     : NULL
```
