# Diseño de un bloque de PCS tipo 1000BASE-X
La subcapa de Codificación Física (PCS) según la cláusula 36 del estándar IEEE 802.3 es responsable de procesar y convertir los datos de la capa superior en un formato adecuado para la transmisión a través del medio físico de la red. Esto implica operaciones como el mapeo de datos en símbolos de codificación, la inserción de bits de control y sincronización, y la sincronización del reloj en el receptor. Su objetivo es garantizar una transmisión confiable y eficiente de los datos en una red Ethernet. La subcapa cuenta con 3 bloques principales. El bloque transmisor en la subcapa de PCS se encarga de recibir los datos de entrada directamente de la capa de enlace de datos (Data Link Layer), específicamente del GMII (Gigabit Media Independent Interface), el cual es una interfaz estandarizada utilizada para la conexión entre el transmisor y receptor físico y la subcapa MAC (Media Access Control).

La sincronización es un aspecto crucial en la subcapa de PCS. Permite al receptor ajustar su reloj interno al ritmo de transmisión de los datos y asegura una recepción precisa. La sincronización se logra mediante la inserción de patrones de bits especiales en los datos transmitidos, que el receptor utiliza para sincronizar su reloj.

El bloque receptor en la subcapa de PCS se encarga de recibir los datos transmitidos a través del medio físico y recuperar la información original. Realiza operaciones como el desempaquetado de los símbolos de codificación, la detección y corrección de errores, y la extracción de los datos originales para ser entregados a la capa superior.

## Descripcion
A continuación se presentan diagramas de transición de estados simplificados e implementados de la capa PCS de la cláusula 36 del estándar IEEE 802.3.
### Transmisor order set
![TransmisorSimpl](https://github.com/ecoenucr/Grupo4_IS23/assets/56570687/5433a7cd-6111-4ec0-bcec-bc6a69738c13)
### Transmisor code-group
![Transmisor2](https://github.com/ecoenucr/Grupo4_IS23/assets/56570687/f350de57-6ab4-494f-a414-50e6a4db87be)
### Receptor parte A
![ReceptorA](https://github.com/ecoenucr/Grupo4_IS23/assets/56570687/c20144d8-57b1-45a9-a558-ec72d1a08071)
### Receptor parte B
![ReceptorB](https://github.com/ecoenucr/Grupo4_IS23/assets/56570687/e77d8bc9-7fbe-4d98-a971-b5bd6cafff76)
### Sincronizador
![SynchronizationSimpl](https://github.com/ecoenucr/Grupo4_IS23/assets/56570687/54d99217-d64b-4516-8e2f-642fb12a90f7)


## Requisitos y uso
### Requisitos del sistema
- Sistema operativo Windows, Linux o MAC.
- Git.
- Compilador IVERILOG v11.0 o una versión más reciente.
- GTKWAVE.
### Uso
1. Clonar el repositorio de git https://github.com/ecoenucr/Grupo4_IS23.git.
2. Dentro del repositorio moverse a la carpeta src.
3. Dentro del la carpeta src ejecutar el comando:
      make
4. Al abrirse el programa GTKWAVE, se seleccionan las entradas y salidas de interés.

## Desarrolladores
- [Isaí David Vargas Ovares](mailto:ISAI.VARGAS@ucr.ac.cr)
- [Jose Pablo Eras Saborío](mailto:JOSE.ERAS@ucr.ac.cr)
- [Kevin Campos Castro](mailto:KEVIN.CAMPOSCASTRO@ucr.ac.cr)
- Marco Vásquez Ovares


