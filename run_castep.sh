#!/bin/bash

# Get user input
read -r -p "Delete old .castep files? [yN] " -n 1 yn
echo ""
read -r -p "Enter 'cube' or 'sheet': " latticetype
echo ""
read -r -p "How many cores? " numcores
echo ""

./lattice.exe

for name in $( ls $latticetype*.cell | sed 's/\(.*\)\..*/\1/' ); do
    # Delete the old .castep file if yn is yes; default is to keep
    case $yn in
        [Yy]* ) rm "$name.castep";;
        * ) ;;
    esac

    # Run CASTEP
    mpirun -np $numcores castep.mpi $name &

    # Get energies from the output file
    grep 'total energy' "$name.castep"
done
