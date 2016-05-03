#!/bin/bash
{
    doxygen Doxyfile && cd latex && make && cd .. && gnome-open latex/refman.pdf
} &> /dev/null
