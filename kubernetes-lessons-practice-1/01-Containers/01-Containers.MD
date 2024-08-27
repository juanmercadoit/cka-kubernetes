# Containers

Estos conceptos son fundamentales para entender cómo se ejecutan y gestionan las aplicaciones en entornos de contenedores, permitiendo una mayor flexibilidad, portabilidad y eficiencia en el desarrollo y despliegue de software.

### **Qué es un Contenedor (Container)**

Un contenedor es una unidad de software que empaqueta el código de una aplicación junto con todas sus dependencias, bibliotecas, configuraciones y archivos necesarios para que se ejecute de manera consistente en cualquier entorno. Los contenedores permiten que las aplicaciones se ejecuten de manera aislada unas de otras y del sistema operativo subyacente, asegurando que funcionen de manera predecible sin importar dónde se desplieguen.

### **Conceptos Relacionados**

#### **1. Imágenes (Images)**

Una **imagen** es una plantilla inmutable que contiene todo lo necesario para ejecutar una aplicación: el código fuente, las bibliotecas, las dependencias y la configuración. Las imágenes son las bases a partir de las cuales se crean los contenedores. Cada vez que se ejecuta un contenedor, se instancia a partir de una imagen. Las imágenes se definen generalmente mediante un archivo llamado `Dockerfile`, que especifica los pasos para crear la imagen.

**Características Clave:**
- **Inmutabilidad:** Una vez creada, una imagen no cambia. Si necesitas modificarla, creas una nueva versión.
- **Capas:** Las imágenes están compuestas por una serie de capas que corresponden a cada instrucción en el `Dockerfile`. Esto permite una reutilización eficiente de capas entre diferentes imágenes.

#### **2. Entorno del Contenedor (Container Environment)**

El **entorno del contenedor** se refiere al entorno aislado en el que un contenedor se ejecuta. Este entorno incluye:
- **Sistema de Archivos:** Una copia del sistema de archivos definido por la imagen desde la cual se inició el contenedor.
- **Variables de Entorno:** Configuraciones específicas que pueden influir en cómo se ejecuta la aplicación dentro del contenedor.
- **Redes:** Un espacio de red aislado que incluye la configuración de red propia del contenedor, como direcciones IP y puertos mapeados.
- **Espacio de Nombres (Namespaces):** Los contenedores utilizan espacios de nombres para proporcionar aislamiento de procesos, usuarios, redes y otros recursos del sistema operativo.

#### **3. Clase de Runtime (Runtime Class)**

El concepto de **Runtime Class** en Kubernetes y contenedores en general se refiere a la configuración que define qué runtime de contenedores se usará para ejecutar un Pod o contenedor específico. Un **runtime de contenedores** es el software responsable de la ejecución de contenedores en un sistema operativo. 

**Ejemplos de Runtimes:**
- **runc:** Es el runtime por defecto en Docker y Containerd que cumple con las especificaciones de la Open Container Initiative (OCI).
- **gVisor:** Un runtime que proporciona aislamiento adicional mediante una capa de virtualización liviana.
- **Kata Containers:** Proporciona un mayor aislamiento utilizando máquinas virtuales ligeras para ejecutar contenedores.

**Runtime Class en Kubernetes:**
- Permite que diferentes contenedores dentro de un clúster de Kubernetes utilicen diferentes runtimes según las necesidades de seguridad, rendimiento, o compatibilidad.

#### **4. Ciclo de Vida de un Contenedor (Container Lifecycle)**

El **ciclo de vida de un contenedor** describe las etapas por las que pasa un contenedor desde que se crea hasta que se elimina. Aquí están las principales etapas:

1. **Creación (Created):** El contenedor es creado pero aún no está en ejecución. Las configuraciones son aplicadas y está listo para arrancar.
   
2. **Inicio (Started):** El contenedor comienza su ejecución y la aplicación dentro del contenedor se inicia.
   
3. **En Ejecución (Running):** El contenedor está activamente ejecutando la aplicación. En esta fase, puede recibir tráfico y realizar operaciones.
   
4. **Pausado (Paused):** La ejecución del contenedor se suspende temporalmente. Los procesos dentro del contenedor no se ejecutan, pero el estado de memoria se conserva.
   
5. **Parado (Stopped):** El contenedor se detiene y no se está ejecutando. Esto puede ocurrir porque la aplicación ha finalizado o porque un usuario ha detenido manualmente el contenedor.
   
6. **Eliminación (Removed):** El contenedor es eliminado del sistema. Esto borra todos los datos y el estado asociados con ese contenedor específico.
