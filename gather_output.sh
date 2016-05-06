#!/bin/bash

for i in *.castep
do 
grep -o '(0K)' $i | sed -e q'/NB est\. 0K energy (E\-0\.5TS)      =/d' -e "/eV/d" >> output.dat
done