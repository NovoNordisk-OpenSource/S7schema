.onLoad <- function(...) {
  if ("S7_on_load" %in% getNamespaceExports("S7")) { # nocov
    getExportedValue("S7", "S7_on_load")() # nocov
  } else {
    S7::methods_register() # nocov
  }
}

.onUnload <- function(...) {
  if ("S7_on_unload" %in% getNamespaceExports("S7")) { # nocov
    getExportedValue("S7", "S7_on_unload")() # nocov
  }
}

if ("S7_on_build" %in% getNamespaceExports("S7")) {
  getExportedValue("S7", "S7_on_build")()
}
