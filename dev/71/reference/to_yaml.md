# Convert an R object to YAML

This function is used internally when validating `list` or `S7schema`
objects, and when using
[`write_config()`](https://novonordisk-opensource.github.io/S7schema/reference/write_config.md)
to save a configuration.

Underneath it is calling
[`yaml::as.yaml()`](https://yaml.r-lib.org/reference/as.yaml.html) to do
the conversion, but all `logical` values are converted to `true`/`false`
instead of `yes`/`no` respectively for a more robust integration with
other YAML parsers. `Date` values are written as ISO 8601 strings
(`"2025-08-06"`), and numbers are written with `precision = 15` instead
of the default of 7. Numbers with up to 16 significant digits are read
back as the same value, while numbers that need 17, e.g. `0.1 + 0.2`,
are rounded.

Missing values are written as:

- logical `NA` as `.na`

- `NA_character_` as `.na.character`

- `NA_integer_` as `.na.integer`

- `NA_real_` as `.na.real`

R reads all of them back as `NA`, while other YAML parsers read them as
strings. Previously logical `NA` was written as `NA`, which R read back
as the string `"NA"`.

It is rarely relevant to call this function directly except for
debugging purposes, or when implementing a new method for your own
object class.

## Usage

``` r
to_yaml(x)
```

## Arguments

- x:

  object to convert to YAML.

## Value

`character(1)` YAML string.

## Details

`to_yaml()` dispatches based on the class of `x`. Register a new S7
method if you want to overwrite how your own class is converted to YAML.
See
[`S7::method()`](https://rconsortium.github.io/S7/reference/method.html)
for more information.

The default method uses
[`yaml::verbatim_logical()`](https://yaml.r-lib.org/reference/verbatim_logical.html)
to overwrite the default behavior of handling `logical` values, and a
handler for `Date` values. The `logical` handler writes `NA` as `.na`,
so it is read back as `NA`:

    function(x) {
      yaml::as.yaml(
        x = x,
        precision = 15,
        handlers = list(
          logical = \(x) {
            x <- yaml::verbatim_logical(x)
            x[is.na(x)] <- ".na"
            x
          },
          Date = \(x) format(x, "%Y-%m-%d")
        )
      )
    }

Copy this and add your own additional handlers when implementing a new
method.

## Examples

``` r
# Convert simple list to YAML
to_yaml(list(hello = "world", is_today = TRUE)) |>
  cat()
#> hello: world
#> is_today: true

# Missing logical values are written as .na
to_yaml(list(a = NA, b = c(TRUE, NA))) |>
  cat()
#> a: .na
#> b:
#> - true
#> - .na

# Convert S7schema object
x <- S7schema(
  file = system.file("examples/config.yml", package = "S7schema"),
  schema = system.file("examples/schema.json", package = "S7schema")
)

print(x)
#> <S7schema::S7schema> List of 1
#>  $ my_config_var: int 1
#>  @ schema   : chr "/home/runner/work/_temp/Library/S7schema/examples/schema.json"
#>  @ validator: <S7schema::validator>
#>  .. @ context:Classes 'V8', 'environment' <environment: 0x56441e87b1c8> 
#>  @ file     : chr "/home/runner/work/_temp/Library/S7schema/examples/config.yml"

to_yaml(x) |>
  cat()
#> my_config_var: 1
```
