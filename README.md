# Oracle Data Cartridge Implementation
## Intro
The 'meteo system' data cartridge is attempt at creating data cartridges using Data Cartridge Interface.  
I have created it to showcase some of capabilities this interface provides in working with objects in Oracle Database.  
This data cartridge consists of multiple functions, operators, indextype and statistics type that helps in determining, whether operator should be resolved via index or function implementation.

## Components
This data cartridge has multitude of components that all together create working system:  
- abstract data type Meteo_t having 3 attributes of another object type called meteo_zonereading, one attribute of type meteo_regionreadings, which is a varray of meteo_zonereading type elements and timestamp denoting time, when the reading was taken.
- 4 implementation types for user defined aggregates
- indextype implementation object type
- user-defined statistics implementation object type
- 16 operators allowing comparison analysis for either whole reading or reading for specific zone in relation with both specified value and themselves.
- 16 functional implementations of comparison analysis operators
- 2 tables that hold statistics, both 'positional' and 'overall' giving details on distribution of values of our parameters

## Type definitions
All type definitions can be found under this location: [link](https://github.com/PiotrBelniak/example-of-ODCI-implementaton/tree/main/Type-definitions).  
  
Meteo_zonereading is the basis for whole system being built as object type with 4 attributes - namely temperature, rain amount, pressure and avg wind. I have chosen these 4, as I believe they are the most basic meteo parameters.  

Meteo_regionreadings is the varray of meteo_zonereading - it is set to have 100 zones, as presumably regions could be divided into some arbitrary amount of zones.

Meteo_t is our main type that fulfills the role of column in tables. It is equivalent for hours meteo reading for whole region.  
Besides having attributes of both of previously defined types, it has procedures that allow automatic assignment of average values, zone with best/worst conditions for this particular reading.
