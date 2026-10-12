# S7schema (development version)

* Validation now checks the data R reads (#70, #67). YAML is parsed in R with `yaml::read_yaml()` for files, and `list` and `S7schema` objects are validated after a round trip with `to_yaml()`. This changes some validation results:
  * `yes`/`no`/`on`/`off` in files are logical values.
  * Merge keys (`<<: *anchor`) resolve as in R, where the merged value wins over a later override.
  * Strings such as `"1e3"`, `"0o17"`, and `"0b101"` stay strings, and `Date` values are strings.
  * `NA`, `Inf`, and `NaN` values are `null`.
  * One-item sequences are read as single values. Use `oneOf` in the schema for fields that can hold one or more values.
  * The current value in error messages is the value read by R.
* `to_yaml()` and `write_config()` now write `Date` values as ISO 8601 strings, logical `NA` as `.na`, and numbers with `precision = 15` instead of 7 significant digits.
* `js-yaml` is no longer bundled in `inst/bundle.js`, and `jsonlite` is now a required dependency.

# S7schema 0.1.2

* Validation error messages now include the current value that failed validation (#63).
* Now possible to create a `S7schema()` object in memory using the new `.data` argument (#62).
* Rebundled `inst/bundle.js` with updated JavaScript dependencies: `ajv` 8.17.1 → 8.18.0, `js-yaml` 4.1.0 → 4.3.1, and `fast-uri` → 3.1.5.

# S7schema 0.1.1

* Fixed `write_config()` to use `NULL` as the default for the output path instead of `x@file`, and renamed the `file` argument to `path` (#48).

# S7schema 0.1.0

* Initial CRAN submission.
