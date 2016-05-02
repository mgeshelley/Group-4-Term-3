#!/bin/bash

# Get user input
read -r -p "Cell name: " name
read -r -p "Delete old .castep file? [Yn] " -n 1 yn

# Delete the old .castep file if yn is yes; default is to delete
case $yn in
    [Yy]* ) rm "$name.castep";;
    * ) ;;
esac

# Run CASTEP
mpirun -np 1 castep.mpi $name &

# Get energies from the output file
grep 'total energy' "$name.castep"
