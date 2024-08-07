# Memoria C4_PLANTUML_SIMPLIFIED_SYNTAX
**Autor:** Cristian González Trillo (cristian.gonzalez.trillo@udc.es)

## Documentos de la Práctica
- ./Test/ (Carpeta Test)
- lexer.l 
- parser.y 
- memoria.txt
- Makefile 

---

## DESCRIPCIÓN DEL PROYECTO

El proyecto tiene como objetivo crear una sintaxis más simple para generar diagramas C4 mediante PlantUML. PlantUML permite crear diagramas mediante texto, pero su sintaxis actual contiene paréntesis y estructuras que pueden resultar confusas. Por ejemplo:

- **PlantUML:** `Rel(ent1, ent2, "Nombre relación")`
- **Sintaxis del Proyecto:** `ent1 -> Nombre_Relación -> ent2`

La nueva sintaxis busca mejorar la comprensión directa del código. El proyecto se enfoca en los elementos más relevantes de los diagramas C4.

---

## ESTADO DEL PROYECTO

Actualmente, el proyecto contempla la creación de las siguientes entidades:

- **Defines:** `define: DEVICONS <https://raw.githubusercontent.com/tupadr3/plantuml-icon-font-sprites/master/devicons>;`
- **Includes:** `include: <DEVICONS/java.puml>;`
- **Personas:** `Per: Marta, "Descripcion Opcional";`
- **Contenedores:** `Con: Nombre_Contenedor, [Contenido], "Descripcion Opcional", sprite=icono_opcional;`
- **Sistemas:** `Sys: Nombre_Sistema, "Descripcion Opcional";`
- **Fronteras de Sistema:** 
    ```
    Boun: Nombre_Frontera {
        Per: Marta;
        Con: Nombre_Contenedor, [Contenido], "Descripcion Opcional";
    };
    ```


## EJEMPLO DE EJECUCIÓN

### Sintaxis Original:
```
@startuml C4_Elements
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Container.puml
!define DEVICONS https://raw.githubusercontent.com/tupadr3/plantuml-icon-font-sprites/master/devicons
!define FONTAWESOME https://raw.githubusercontent.com/tupadr3/plantuml-icon-font-sprites/master/font-awesome-5
!include DEVICONS/angular.puml
!include DEVICONS/java.puml
!include DEVICONS/msql_server.puml
!include FONTAWESOME/users.puml
Person(Customer, "Customer", "People that need products", $sprite="users")
System_Boundary(OurSystem, "OurSystem") {
  Container(SPA, "SPA", "angular", "The main interface that the customer interacts with" , $sprite="angular")
  Container(API, "API", "java", "Handles all business logic" , $sprite="java")
}
Rel(Customer, SPA, "Uses", "https")
Rel(SPA, API, "Uses", "https")
@enduml
```

### Nueva Sintaxis:

```
define: DEVICONS <https://raw.githubusercontent.com/tupadr3/plantuml-icon-font-sprites/master/devicons>;
define: FONTAWESOME <https://raw.githubusercontent.com/tupadr3/plantuml-icon-font-sprites/master/font-awesome-5>;
include: <DEVICONS/angular.puml>;
include: <DEVICONS/java.puml>;
include: <DEVICONS/msql_server.puml>;
include: <FONTAWESOME/users.puml>;
Per: Customer, "People that need products" | sprite=users;
Boun: OurSystem {
    Con: SPA, [angular], "The main interface that the customer interacts with" | sprite=angular;
    Con: API, [java], "Handles all business logic" | sprite=java;
};
Customer -> Uses -> SPA, "https";
SPA -> Uses -> API, "https";
```

### EN ESTE EJEMPLO LA NUEVA SINTAXIS SUPONE UN 12,65% DE REDUCCIÓN DE CÓDIGO EN COMPARACIÓN CON LA ORIGINAL.

---

## ERRORES DETECTABLES

- **Falta de un ';'**:
  - Todas las líneas del documento de entrada deben terminar con un ';', ya que este símbolo define el EOL. Pueden existir líneas en blanco dentro del programa, estas no deben contener ';'.

- **Dos entidades con el mismo nombre**:
  - El nombre de una entidad es, a su vez, su identificador. No pueden existir dos entidades con el mismo nombre.

- **La entidad System_Boundary no puede contener un sprite**:
  - Esta entidad no puede tener un sprite, así que si se le intenta asignar uno, un error saltará.

- **Declaración mal formada**:
  - Cuando los campos de una declaración están desordenados.

---

## DECISIONES DESTACABLES

- Para evitar conflictos de desplazamiento / reducción, he tenido que añadir más tokens de los inicialmente considerados. Esto se debe a que con los tokens limitados como al inicio, se generaban situaciones de ambigüedad sobre si reducir una regla o no.

- En vez de indicar en qué línea se encuentra el error, he decidido señalar en qué declaración se encuentra. Considero que de esta manera, se podrían generar herramientas de edición posteriormente que permitieran navegar el documento saltando de declaración en declaración, en lugar de por líneas.

- He decidido lanzar el error de declaración mal formada en lugar de aceptar múltiples órdenes de los argumentos de las declaraciones.

---

## EJECUCIÓN

### PREPARACIÓN DEL ENTORNO

Se debe instalar PlantUML para generar el diagrama. El programa implementado genera el código PlantUML, pero para generar el consecuente diagrama es necesario instalar PlantUML y, si se utiliza VSCode, una extensión.

- [PlantUML](https://plantuml.com/es/)
- [VSCode](https://code.visualstudio.com)
- [Extensión VSCode](https://marketplace.visualstudio.com/items?itemName=jebbs.plantum)

### MAKEFILE

En el MakeFile se encuentran varias opciones de ejecución:

- **Compile:** Únicamente compila el código, no lo ejecuta.
- **Run:** Ejecuta las pruebas que muestran el funcionamiento de la práctica.
- **Clean:** Elimina todo menos los documentos declarados al inicio de esta memoria como documentos de la práctica.
- **All:** Ejecuta secuencialmente Compile y Run, en ese orden.

### TESTS

- **AllCorrectTest.txt:**
  - Esta prueba crea un diagrama correctamente y contiene todos los elementos que se pueden generar en el estado actual del proyecto.

- **BoundaryContainsSprite.txt:**
  - En esta prueba debe saltar un error "Error at declaration number 5: System Boundaries cannot have sprites assigned", ya que una System_Boundary no puede tener asignada un Sprite.

- **MissingSemiColonTest.txt:**
  - Con esta prueba comprobamos que, efectivamente, se lanza un error indicando que falta un ';' si se da esta situación. "Error at declaration number 2: Missing missing a ; ".

- **RepeatedID.txt:**
  - Este documento intenta declarar dos veces una persona con un Nombre que ya ha sido utilizado previamente ( Per: Customer | sprite=users; ). "Error at declaration number 10: You are trying to create a Person with a name (Customer) that is already being used. "

- **DeclarationBadFormed.txt:**
  - Esta prueba representa un error al declarar una Persona, el error consiste en una declaración desordenada de esta entidad. "Error at declaration number 1: This Person declaration is not correct (Per: Name, "Optional Description")".

---
