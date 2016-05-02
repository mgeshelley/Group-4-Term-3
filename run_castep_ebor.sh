#!/bin/bash

#This is a generic script to execute a parallel command on jorvik using Sun Grid Engine
#Lines beginning with one "#" are comment lines and ignored
#Lines beginning with "#$" are instructions to the qsub command
#Ebor has 32 cores per node 
#v1.0 MIJP 20/11/2015

#specify export QSUB vars to shell script
#$ -V -j y -R y 

#specify which queue (phys-teaching = high priority, short max time; phys-cluster = low priority, longer max time) 
#$ -q phys-cluster

#execute script from current working directory 
#$ -cwd

#select max run-time
#$ -l h_rt=00:01:00

#select parallel environment to run on nn cores, max 32 cores/node
#$ -pe mpi-16 32
#set same value here too
NUM_CORES=32

#name of MPI executable
EXEC=castep.mpi

#any additional arguments to pass to the executable
ARGS=$1

#set job running
mpirun -np $NUM_CORES $EXEC $ARGS