# Oracle Data Cartridge Implementation
## intro
The 'meteo system' data cartridge is attempt at creating data cartridges using Data Cartridge Interface.  
I have created it to showcase some of capabilities this interface provides in working with objects in Oracle Database.  
This data cartridge consists of multiple functions, operators, indextype and statistics type that helps in determining, whether operator should be resolved via index or function implementation.

## Components
This data cartridge has multitude of components that all together create working system:  
- abstract data type Meteo_t having 3 attributes of another object type called meteo_zonereading, one attribute of type meteo_regionreadings, which is a varray of meteo_zonereading type elements and timestamp denoting time, when the reading was taken.
- 4 implementation type for user defined aggregates
- indextype implementation object type
- user-defined statistics implementation object type
- 16 operators allowing comparison analysis for either whole reading or reading for specific zone in relation with both specified value and themselves.
- 16 functional implementations of comparison analysis operators
- 2 tables that hold statistics, both 'positional' and 'overall' giving details on distribution of values of our parameters
