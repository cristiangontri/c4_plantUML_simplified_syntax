# Memoria C4_PLANTUML_SIMPLIFIED_SYNTAX 

## Idea del Proyecto

El proyecto busca crear una sintaxis más simple a la actual para generar diagramas C4 mediante el uso de PlantUML. PlantUML es una tecnología que permite crear diagramas escribiendo en un documento de texto. Su sintaxis contiene abundantes paréntesis, además de alguna estructura que puede crear confusión. 

Por ejemplo -> Una relación entre dos entidades:

- PlantUML:
  
    `Rel(ent1, ent2, "Nombre relación")` 

- Sintaxis de este proyecto:
  
    `Rel: ent1 -> Nombre_Relación -> ent2`

Con la nueva sintaxis entendemos, desde el primer vistazo, qué queremos representar con la línea de código. Con la sintaxis original pueden surgir dudas ( ¿De qué entidad a qué entidad va la relación?). 

Como los diagramas C4 tienen una infinidad de elementos, el proyecto se ha **acotado para incluir los más relevantes**. Actualmente el proyecto contempla la creación de las siguientes entidades:

- **Defines** -> `define: DEVICONS <https://raw.githubusercontent.com/tupadr3/plantuml-icon-font-sprites/master/devicons>;`
  
- **Includes** -> `include: <DEVICONS/java.puml>;`

- **Personas** -> `Per: Marta, "Descripcion Opcional";`

- **Contenedores** -> `Con: Nombre_Contenedor, [Contenido], "Descripcion Opcional", sprite=icono_opcional;`
  
- **Sistemas** -> `Sys: Nombre_Sistema, "Descripcion Opcional";`

- **Fronteras de Sistema**: 
```
Boun: Nombre_Frontera {
    Per: Marta;
    Con: Nombre_Contenedor, [Contenido], "Descripcion Opcional";
};
```

