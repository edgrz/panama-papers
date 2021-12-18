

# Análisis de los papeles de Panamá mediante la teoría de redes complejas
Master universitario en Ciencia de Datos (Data Science)

Proyecto final de Máster

M2.982 - TFM Area: Data Analysis and Big Data

Autor: Edgar Pardo

## Índice
  * [Entorno](#entorno)
  * [Conjunto de datos](#conjunto-de-datos)
  * [Preprocesado](#preprocesado)
  * [Implementación](#implementacion)
  * [Referencias](#referencias)
## Entorno
El entorno de datos está alojado en una base de datos Neo4j. Dicha instancia de base de datos es desplegada como un contenedor sobre una infraestructura Cloud llamada minikube[1]. 

Con minikube disponemos un cluster de Kubernetes mononodo (4CPUs, 8GB RAM).

Para desplegar Neo4j hacemos uso de un chart de Helm de los propios desarrolladores de Neo4j[2]. En la carpeta [Infrastructure](./infrastructure/) podéis encontrar el fichero de configuración para levantar la BBDD.

## Conjunto de datos
Los datos de los papeles de Panamá son públicos y accesibles a través de la base de datos del del Consorcio internacional de Periodistas de Investigación (ICIJ)[3].

El contenido de la BBBD es exportable a ficheros y estos están disponibles en la carpeta [data](./data). Consta de los siguientes ficheros:

  - Address.csv: vértices que representan el domicilio fiscal de un vértices
  - Entities.csv: vértices que representan *Offshore*
  - Intermediaries.csv: vértices que representan los proveedores/creadores de las *Offshore*
  - Officers.csv: vértices que representan propietarios/accionistas/empleados de las *Offshore*
  - all_edges.csv: aristas del grafo
 

## Preprocesado

Para insertar los datos en nuestra instancia de Neo4j, primero es necesario preprocesar los ficheros csv del apartado anterior. 

Para ello, hacemos uso de los scripts presentes en la carpeta [preprocess](./preprocess).

Primero, es necesario correr un script en R que nos genera el fichero de aristas parseado `edges_parsed.csv`.

A continuación, cargamos en el contenedor de Neo4j los datos mediante el uso del comando `neo4j-admin import` y de un script en Bash. Este script bifurca los ficheros, en ficheros intermedios temporales que adaptan los datos al formato requerido por la herramienta.

## Implementacion

La carpeta [code](./code) contiene los scripts en Python en formato notebook con los que se ha desarrolado el análisis y exploración de la red. Este consta de los siguientes ficheros:

- Graph_study: script de análisis general de la red a macroescala y mesoescala. Se estudian los grados del grafo, conectividad y clases de este.
- Percolation: script de análisis de robustez de la red mediante distintas percolaciones con distintos criterios.
- Weight_graph: script de proyección del grafo a una red bipartita con pesos.
- Nestedness: script que explota las particiones resultantes de la ejecución del algoritmo de COSIN3 de análisis de redes anidadas[4].

## Referencias
[1] https://minikube.sigs.k8s.io/docs/start/
[2] https://neo4j.com/docs/operations-manual/current/kubernetes/helm-charts-setup/
[3] https://offshoreleaks.icij.org/pages/database
[4] https://github.com/COSIN3-UOC/nestedness_modularity_in-block_nestedness_analysis
