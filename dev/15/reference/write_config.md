# Write YAML configuration file

Thin wrapper around
[`yaml::write_yaml()`](https://rdrr.io/pkg/yaml/man/write_yaml.html)
calling
[`validate()`](https://rconsortium.github.io/S7/reference/validate.html)
before creating the YAML file, ensuring that the saved configuration is
valid.

## Usage

``` r
write_config(x, file, ...)
```

## Arguments

- x:

  `S7schema` object to write.

- file:

  `character(1)` path to the file to write to.

- ...:

  Additional arguments passed along to
  [`yaml::write_yaml()`](https://rdrr.io/pkg/yaml/man/write_yaml.html).

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
#>  .. @ context:Classes 'V8', 'environment' <environment: 0x5559a40f64e0> 

# Edit content
x$my_config_var <- 2

# Save new file
write_config(
  x = x,
  file = tempfile(fileext = ".yml")
)
```
