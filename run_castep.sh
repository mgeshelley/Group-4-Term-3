#!/bin/bash

# Get user input
read -r -p "Delete old .castep files? [yN] " -n 1 yn
echo ""

for name in $( ls *.cell | sed 's/\(.*\)\..*/\1/' ); do
    # Delete the old .castep file if yn is yes; default is to keep
    case $yn in
        [Yy]* ) rm "$name.castep";;
        * ) ;;
    esac

    # Run CASTEP
    mpirun -np 3 castep.mpi $name &

    # Get energies from the output file
    grep 'total energy' "$name.castep"
done
