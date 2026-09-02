# Changelog

## S7schema 0.1.2

CRAN release: 2026-08-21

- Validation error messages now include the current value that failed
  validation
  ([\#63](https://github.com/NovoNordisk-OpenSource/S7schema/issues/63)).
- Now possible to create a
  [`S7schema()`](https://novonordisk-opensource.github.io/S7schema/reference/S7schema.md)
  object in memory using the new `.data` argument
  ([\#62](https://github.com/NovoNordisk-OpenSource/S7schema/issues/62)).
- Rebundled `inst/bundle.js` with updated JavaScript dependencies: `ajv`
  8.17.1 → 8.18.0, `js-yaml` 4.1.0 → 4.3.1, and `fast-uri` → 3.1.5.

## S7schema 0.1.1

CRAN release: 2026-05-09

- Fixed
  [`write_config()`](https://novonordisk-opensource.github.io/S7schema/reference/write_config.md)
  to use `NULL` as the default for the output path instead of `x@file`,
  and renamed the `file` argument to `path`
  ([\#48](https://github.com/NovoNordisk-OpenSource/S7schema/issues/48)).

## S7schema 0.1.0

CRAN release: 2026-03-13

- Initial CRAN submission.
