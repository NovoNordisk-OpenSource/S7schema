# Write YAML configuration file

Thin wrapper around
[`to_yaml()`](https://novonordisk-opensource.github.io/S7schema/reference/to_yaml.md)
calling
[`validate()`](https://rconsortium.github.io/S7/reference/validate.html)
before converting to YAML and creating the file, ensuring that the saved
configuration is valid.

## Usage

``` r
write_config(x, path = NULL)
```

## Arguments

- x:

  `S7schema` object to write.

- path:

  `character(1)` path to the file to write to. Default `NULL` uses
  `x@file` for
  [`S7schema()`](https://novonordisk-opensource.github.io/S7schema/reference/S7schema.md)
  objects.

## Value

Invisible `x` (the input `S7schema` object). Called for side effect of
writing the file.

## Examples

``` r
# Read configuration file:
x <- S7schema(
  file = system.file("examples/config.yml", package = "S7schema"),
  schema = system.file("examples/schema.json", package = "S7schema")
)

print(x)
#> <S7schema::S7schema> List of 1
#>  $ my_config_var: int 1
#>  @ schema   : chr "/home/runner/work/_temp/Library/S7schema/examples/schema.json"
#>  @ validator: <S7schema::validator>
#>  .. @ context:Classes 'V8', 'environment' <environment: 0x559f4d56f0c8> 
#>  @ file     : chr "/home/runner/work/_temp/Library/S7schema/examples/config.yml"

# Edit content
x$my_config_var <- 2

# Save new file
write_config(
  x = x,
  path = tempfile(fileext = ".yml")
)
```
