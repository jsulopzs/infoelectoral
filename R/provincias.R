#' @title Download data at the electoral constituency level (province or island)
#'
#' @description `provincias()` downloads, formats and imports to the environment the electoral results data of the selected election at electoral constituency level (province or island).
#'
#' @param tipo_eleccion The type of choice you want to download. The accepted values are "congreso", "senado", "europeas" o "municipales".
#' @param anno The year of the election in YYYY format.
#' @param mes The month of the election in MM format.
#'
#' @return data.frame with the electoral results data at the polling station level.
#'
#' @importFrom stringr str_trim
#' @importFrom stringr str_remove_all
#' @importFrom dplyr relocate
#' @importFrom dplyr %>%
#' @importFrom rlang .data
#'
#' @export
provincias <- function(tipo_eleccion, anno, mes) {
  ### Construyo la url al zip de la elecciones
  if (tipo_eleccion == "municipales") {
    tipo <- "04"
  } else if (tipo_eleccion == "congreso") {
    tipo <- "02"
  } else if (tipo_eleccion == "europeas") {
    tipo <- "07"
  } else if (tipo_eleccion == "cabildos") {
    tipo <- "06"
  } else {
    stop('The argument tipo_eleccion must take one of the following values: "congreso", "municipales", "europeas"')
  }


  urlbase <- "https://infoelectoral.interior.gob.es/estaticos/docxl/apliextr/"
  url <- paste0(urlbase, tipo, anno, mes, "_TOTA", ".zip")

  ### Descargo el fichero zip en un directorio temporal y lo descomprimo
  tempd <- tempdir()
  temp <- tempfile(tmpdir = tempd, fileext = ".zip")
  download.file(url, temp, mode = "wb")
  unzip(temp, overwrite = T, exdir = tempd)





  ### Construyo las rutas a los ficheros DAT necesarios
  codigo_eleccion <- paste0(substr(anno, nchar(anno)-1, nchar(anno)), mes)
  todos <- list.files(tempd, recursive = T)
  x <- todos[todos == paste0("03", tipo, codigo_eleccion, ".DAT")]
  xbasicos <- todos[todos == paste0("07", tipo, codigo_eleccion, ".DAT")]
  xcandidaturas <- todos[todos == paste0("08", tipo, codigo_eleccion, ".DAT")]


  ### Leo los ficheros DAT necesarios
  dfcandidaturas_basicos <- read03(x, tempd)
  dfbasicos <- read07(xbasicos, tempd)
  dfcandidaturas <- read08(xcandidaturas, tempd)


  ### Limpio el directorio temporal (IMPORTANTE: Si no lo hace, puede haber problemas al descargar más de una elección)
  borrar <-  list.files(tempd, full.names = T, recursive = T)
  try(file.remove(borrar), silent = T)

  ### Junto los datos de los tres ficheros
  df <- merge(dfcandidaturas_basicos, dfcandidaturas, by = c("tipo_eleccion", "anno", "mes", "codigo_partido"), all = T)
  df <- merge(dfbasicos, df, c("tipo_eleccion", "anno", "mes", "vuelta", "codigo_ccaa", "codigo_provincia", "codigo_distrito_electoral"), all.x = T)



  ### Limpieza: Quito los espacios en blanco a los lados de estas variables
  df$siglas <- str_trim(df$siglas)
  df$denominacion <- str_trim(df$denominacion)
  df$denominacion <- str_remove_all(df$denominacion, '"')
  df$ambito_territorial <- str_trim(df$ambito_territorial)


  # Inserto el nombre del municipio más reciente y reordeno algunas variables
  df <- df %>%
    relocate(
      .data$codigo_ccaa,
      .data$codigo_provincia,
      .data$codigo_distrito_electoral,
      .after = .data$vuelta) %>%
    relocate(
      .data$codigo_partido_autonomia,
      .data$codigo_partido_provincia,
      .data$codigo_partido,
      .data$denominacion,
      .data$siglas,
      .data$votos,
      .data$diputados,
      .data$datos_oficiales,
      .after = .data$codigo_partido_nacional
    ) %>%
    relocate(
      .data$n_diputados,
      .after = .data$poblacion_derecho
    ) %>%
    arrange(
      .data$codigo_ccaa,
      .data$codigo_provincia,
      .data$codigo_distrito_electoral,
      -.data$votos
    )

  return(df)
}
