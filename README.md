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
- 16 operators allowing comparison analysis for either whole reading or specific zone from reading in relation with both specified value and themselves.
- 16 functional implementations of comparison analysis operators
- 2 tables that hold statistics, both 'positional' and 'overall' giving details on distribution of values of our parameters

## Type definitions
All type definitions can be found under this location: [Types](https://github.com/PiotrBelniak/example-of-ODCI-implementaton/tree/main/Type-definitions).  
  
Meteo_zonereading is the basis for whole system being built as object type with 4 attributes - namely temperature, rain amount, pressure and avg wind. I have chosen these 4, as I believe they are the most basic meteo parameters.  

Meteo_regionreadings is the varray of meteo_zonereading - it is set to have 100 zones, as presumably regions are divided into some arbitrary amount of zones.

Meteo_t is our main type that fulfills the role of column in tables. It is equivalent for hours meteo reading for whole region.  
Besides having attributes of both of previously defined types, it has procedures that allow automatic assignment of average values, zone with best/worst conditions for this particular reading.

### Meteo_Idxtype_Im
This type implements meteo_idxtype indextype(the object specifying programs managing maintenance of domain indexes).  
Since the indextype specifies maintenance rules for indexes, it needs to have subprograms for creation, deletion of index, updates such as insert, update or delete of source rows.  
The indextype also provides mechanism for obtaining data from indexes based on the indextype.

### Meteo_Stats_Im
This type implements user statistics associated with meteo_idxtype and functions, that are implementations of comparison operators.  
It specifies methods for collecting statistics, deleting them for both table columns and indexes. 
Type needs also methods for calculating selectivity for predicates, that are crucial in determining, if the index should be used or functional implementation for given operator.

## Operators
All operator definitions can be found under this location: [Operators](https://github.com/PiotrBelniak/example-of-ODCI-implementaton/tree/main/Operator-definitions).  

Operators are divided into 5 groups:
1) Comparison of one parameter to specified value for whole reading
2) Comparison of one parameter to specified value for specified zone
3) Comparison of two parameters to specified values for whole reading
4) Comparison of two parameters to specified value for specified zone
5) Comparison of conditions between two readings/two zones in the same reading

Every operator has functional implementation bound to it.  
Because operators are associated with indextype, the indextype implementation type has specified procedures that allow to evaluate operator using index.
