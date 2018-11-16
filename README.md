# elecciones

Esto es una librería de R para descarga resultados electorales de España del [Ministerio del Interior](http://www.infoelectoral.mir.es/infoelectoral/min/). Por ahora solo permite descargar lo resultados de las elecciones generales y municipales a nivel de mesa electoral y de municipio. Sigo trabajando para ampliarlo.


# Cómo instalarlo

```
devtools::install_github("meneos/elecciones")
```

# Cómo usarlo

La librería tiene dos funciones: 

1. ``` mesas()``` para descargar datos a nivel de mesa electoral.
2. ``` municipios()``` para descargar datos a nivel de municipio.

Ambas funciones aceptan tres argumentos:

1. ``` tipoeleccion = c("generales", "municipales")```. El tipo de elección que se quiere descargar.
2. ``` yr```. El año de la elección en formato YYYY. Puede ir como número o como texto.
3. ``` mes```. El mes de la elección en formato mm. Se debe introducir el número del mes pero en forma texto (p.e: para mayo hay que introducir "05").

## Ejemplo
Para descargar los resultados electorales a nivel de municipio de las elecciones generales de marzo de 1979 se debe introducir:

```
library(elecciones)
municipios(tipoeleccion = "generales", yr = 1979, mes = "03")

```

# Qué devuelve

Ambas funciones devuelven cuatro data frames:

1. ``` dfcandidaturas```. El data frame con los datos básicos de todas las candidaturas (siglas, denominación, códigos de cabecera provincial, autonómica y estatal, etc...).
2. ``` dfbasicos```. El data frame con los datos básicos de los municipios o las mesas electorales (códigos de provincia, municipio, distrito, censo, etc...).
3. ``` dfmesas``` o ``` dfmunicipios```. El data frame con los resultados electorales de cada partido en cada mesa/municipio en formato [long](https://www.dummies.com/programming/r/understanding-data-in-long-and-wide-formats-in-r/).
4. ``` dftotal```. El data frame fusionado de los tres data frames anteriores.

Hay que tener en cuenta que en el caso de que se hayan descargado los datos a nivel de municipio, aparecerán por separado los resultados del total del municipio y los de los distritos de los municipios.
