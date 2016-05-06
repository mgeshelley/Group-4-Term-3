# Getting started
*Group 4 term 3*

1. Compile using `gfortran constants.f90 lattice.f90 -o lattice.exe`
2. Run the simulation using `run_castep.sh`
3. Use `grep "Total energy" *.castep` to get lines with final energies
3. Find the convex hull using `convex_hull.py` (which reads in `output.dat`)

**For full documentation, see [latex/refman.pdf](https://github.com/mges501York/Group-4-Term-3/blob/master/latex/refman.pdf)**.

Generate your own copy of this documentation, including an interactive HTML version, by running `makedoc.sh` (requires [doxygen](http://www.stack.nl/~dimitri/doxygen/)).
