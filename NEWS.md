# S7schema 0.2.1

* Updates for compatibility with S7 > 0.2.2 (#80).

# S7schema 0.2.0

* Validation now checks the data that R reads (#70, #67). Files are validated as `yaml::read_yaml()` reads them, `S7schema` objects as `write_config()` writes them and R reads them back, and `list` objects in `validate_list()` as they are. Previously the YAML was parsed again by a JavaScript parser, which could read values differently. This changes some validation results:
  * Unquoted `y`, `n`, `yes`, `no`, `on`, and `off` in lowercase, title case, or uppercase (e.g. `Yes`, `YES`) are logical values. This also applies to map keys: `y:` is read as the key `"TRUE"` and `n:` as `"FALSE"`. Quote them to keep them as strings.
  * Unquoted dates such as `2025-08-06` and values such as `1e3`, `0o17`, and `0b101` are strings.
  * Merge keys (`<<: *anchor`) resolve as in R: a key from the merged mapping wins over the same key set next to `<<`.
  * One-item sequences such as `[a]` in files and `S7schema` objects are single values. Use `oneOf` in the schema for fields that can hold one or more values.
  * `NA`, `NaN`, and `Inf` are validated as `null`. Allow `null` in the schema for fields that may be missing.
  * `Date` values in `list` and `S7schema` objects are validated as strings.
  * Numbers in files and lists are validated exactly. Numbers in `S7schema` objects are validated as `write_config()` writes them, which rounds numbers that need 17 significant digits, such as `0.1 + 0.2`.
  * The current value in error messages is the value as R reads it.
* `to_yaml()` and `write_config()`:
  * Logical `NA` is written as `.na`, so R reads it back as `NA`. Previously it was written as `NA`, which R read back as the string `"NA"`.
  * `Date` values are written as ISO 8601 strings (`2025-08-06`) instead of the number of days since 1970-01-01.
  * Numbers are written with a precision of 15 instead of 7, so numbers with up to 16 significant digits are read back as the same value.
* `validate_yaml()` and `S7schema()` no longer warn when a YAML file has no final newline.
* `jsonlite` is now a required dependency, and `js-yaml` is no longer bundled.
* Uses 'QuickJSR' instead of 'V8' to run 'ajv', so the 'V8' system library is no longer needed (#56). The bundled `fast-uri` is updated to 3.1.8, which has security fixes.
* An invalid JSON schema now gives a short error with the schema file and the reason, instead of a JavaScript stack trace.

# S7schema 0.1.2

* Validation error messages now include the current value that failed validation (#63).
* Now possible to create a `S7schema()` object in memory using the new `.data` argument (#62).
* Rebundled `inst/bundle.js` with updated JavaScript dependencies: `ajv` 8.17.1 → 8.18.0, `js-yaml` 4.1.0 → 4.3.1, and `fast-uri` → 3.1.5.

# S7schema 0.1.1

* Fixed `write_config()` to use `NULL` as the default for the output path instead of `x@file`, and renamed the `file` argument to `path` (#48).

# S7schema 0.1.0

* Initial CRAN submission.
