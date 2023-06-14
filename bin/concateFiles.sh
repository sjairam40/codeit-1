#!/bin/bash
version=0.1

CAT=$(command -v cat)

SORT=$(command -v sort)

UNIQ=$(command -v uniq)

#### CAT
#### Check to make sure the cat utility is available
if [ ! -f "${CAT}" ]; then
    echo "ERROR: Unable to locate the cat binary."
    echo "FIX: Please modify the \${CAT} variable in the program header."
    exit 1
fi

#### SORT
#### Check to make sure the sort utility is available
if [ ! -f "${SORT}" ]; then
    echo "ERROR: Unable to locate the sort binary."
    echo "FIX: Please modify the \${SORT} variable in the program header."
    exit 1
fi

#### UNIQ
#### Check to make sure the uname utility is available
if [ ! -f "${UNIQ}" ]; then
    echo "ERROR: Unable to locate the uniq binary."
    echo "FIX: Please modify the \${UNIQ} variables in the program header."
    exit 1
fi


cat file1 file2 | sort | uniq


