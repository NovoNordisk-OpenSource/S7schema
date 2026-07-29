# Changelog

## S7schema (development version)

- Rebundled `inst/bundle.js` with updated JavaScript dependencies: `ajv`
  8.17.1 → 8.18.0, `js-yaml` 4.1.0 → 4.2.0, and `fast-uri` → 3.1.4.

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
