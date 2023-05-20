# Array

Functions for array operations and manipulations.

## Overview

Check if item exists in the given array.

## Index

* [array::contains](#arraycontains)
* [array::dedupe](#arraydedupe)
* [array::is_empty](#arrayis_empty)
* [array::join](#arrayjoin)
* [array::reverse](#arrayreverse)
* [array::random_element](#arrayrandom_element)
* [array::sort](#arraysort)
* [array::rsort](#arrayrsort)
* [array::bsort](#arraybsort)
* [array::merge](#arraymerge)

### array::contains

Check if item exists in the given array.

#### Example

```bash
array=("a" "b" "c")
array::contains "c" ${array[@]}
#Output
0
```

#### Arguments

* **$1** (mixed): Item to search (needle).
* **$2** (array): array to be searched (haystack).

#### Exit codes

* **0**:  If successful.
* **1**: If no match found in the array.
* **2**: Function missing arguments.

### array::dedupe

Remove duplicate items from the array.

#### Example

```bash
array=("a" "b" "a" "c")
printf "%s" "$(array::dedupe ${array[@]})"
#Output
a
b
c
```

#### Arguments

* **$1** (array): Array to be deduped.

#### Exit codes

* **0**:  If successful.
* **2**: Function missing arguments.

#### Output on stdout

* Deduplicated array.

### array::is_empty

Check if a given array is empty.

#### Example

```bash
array=("a" "b" "c" "d")
array::is_empty "${array[@]}"
```

#### Arguments

* **$1** (array): Array to be checked.

#### Exit codes

* **0**: If the given array is empty.
* **2**: If the given array is not empty.

### array::join

Join array elements with a string.

#### Example

```bash
array=("a" "b" "c" "d")
printf "%s" "$(array::join "," "${array[@]}")"
#Output
a,b,c,d
printf "%s" "$(array::join "" "${array[@]}")"
#Output
abcd
```

#### Arguments

* **$1** (string): String to join the array elements (glue).
* **$2** (array): array to be joined with glue string.

#### Exit codes

* **0**:  If successful.
* **2**: Function missing arguments.

#### Output on stdout

* String containing a string representation of all the array elements in the same order,with the glue string between each element.

### array::reverse

Return an array with elements in reverse order.

#### Example

```bash
array=(1 2 3 4 5)
printf "%s" "$(array::reverse "${array[@]}")"
#Output
5 4 3 2 1
```

#### Arguments

* **$1** (array): The input array.

#### Exit codes

* **0**:  If successful.
* **2**: Function missing arguments.

#### Output on stdout

* The reversed array.

### array::random_element

Returns a random item from the array.

#### Example

```bash
array=("a" "b" "c" "d")
printf "%s\n" "$(array::random_element "${array[@]}")"
#Output
c
```

#### Arguments

* **$1** (array): The input array.

#### Exit codes

* **0**:  If successful.
* **2**: Function missing arguments.

#### Output on stdout

* Random item out of the array.

### array::sort

Sort an array from lowest to highest.

#### Example

```bash
sarr=("a c" "a" "d" 2 1 "4 5")
array::array_sort "${sarr[@]}"
#Output
1
2
4 5
a
a c
d
```

#### Arguments

* **$1** (array): The input array.

#### Exit codes

* **0**:  If successful.
* **2**: Function missing arguments.

#### Output on stdout

* sorted array.

### array::rsort

Sort an array in reverse order (highest to lowest).

#### Example

```bash
sarr=("a c" "a" "d" 2 1 "4 5")
array::array_sort "${sarr[@]}"
#Output
d
a c
a
4 5
2
1
```

#### Arguments

* **$1** (array): The input array.

#### Exit codes

* **0**:  If successful.
* **2**: Function missing arguments.

#### Output on stdout

* reverse sorted array.

### array::bsort

Bubble sort an integer array from lowest to highest.
This sort does not work on string array.

#### Example

```bash
iarr=(4 5 1 3)
array::bsort "${iarr[@]}"
#Output
1
3
4
5
```

#### Arguments

* **$1** (array): The input array.

#### Exit codes

* **0**:  If successful.
* **2**: Function missing arguments.

#### Output on stdout

* bubble sorted array.

### array::merge

Merge two arrays.
Pass the variable name of the array instead of value of the variable.

#### Example

```bash
a=("a" "c")
b=("d" "c")
array::merge "a[@]" "b[@]"
#Output
a
c
d
c
```

#### Arguments

* **$1** (string): variable name of first array.
* **$2** (string): variable name of second array.

#### Exit codes

* **0**:  If successful.
* **2**: Function missing arguments.

#### Output on stdout

* Merged array.

