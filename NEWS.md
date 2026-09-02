# S7schema 0.1.2

* Validation error messages now include the current value that failed validation (#63).
* Now possible to create a `S7schema()` object in memory using the new `.data` argument (#62).
* Rebundled `inst/bundle.js` with updated JavaScript dependencies: `ajv` 8.17.1 → 8.18.0, `js-yaml` 4.1.0 → 4.3.1, and `fast-uri` → 3.1.5.

# S7schema 0.1.1

* Fixed `write_config()` to use `NULL` as the default for the output path instead of `x@file`, and renamed the `file` argument to `path` (#48).

# S7schema 0.1.0

* Initial CRAN submission.
