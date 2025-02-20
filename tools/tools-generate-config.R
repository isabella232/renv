
unlink("R/config-defaults.R")
devtools::load_all(quiet = TRUE)

source <- "inst/config.yml"
target <- "R/config-defaults.R"

template <- renv_template_create('
  ${NAME} = function(..., default = ${DEFAULT}) {
    renv_config_get(
      name    = "${NAME}",
      type    = "${TYPE}",
      default = default,
      args    = list(...)
    )
  }
')

template <- gsub("^\\n+|\\n+$", "", template)

generate <- function(entry) {

  name    <- entry$name
  type    <- entry$type
  default <- entry$default
  code    <- entry$code

  default <- if (length(code)) trimws(code) else deparse(default)

  replacements <- list(
    NAME     = name,
    TYPE     = type,
    DEFAULT  = default
  )

  renv_template_replace(template, replacements)

}

config <- yaml::read_yaml("inst/config.yml")
code <- map_chr(config, generate)
all <- c(
  "",
  "# Auto-generated by 'tools/tools-generate-config.R'",
  "",
  "#' @rdname config",
  "#' @export",
  "config <- list(",
  "",
  paste(code, collapse = ",\n\n"),
  "",
  ")"
)

writeLines(all, con = target)
vwritef("* 'R/config-defaults.R' has been updated.")
