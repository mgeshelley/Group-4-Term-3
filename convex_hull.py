#!/usr/bin/env python

import numpy as np

"""
Reads in data file containing final energies from CASTEP runs with a 
parameter being varied. Creates convex hull for data.
"""

#Read in data
file_name = raw_input("Enter name of file containing energies")
data = np.genfromtxt(file_name, usecols = (0, 1))

#Array for hull vertices
hv = np.zeros((1,2))

#First hull vertex must be first data point
hv[0,:] = data[0,:]

hv_new = 0
theta_max = -1 * np.atan((data[1,1] - data[0,1])/(data[1,0] - data[0,0]))
while

#Write 'hv' to file
convex_hull = open('convex_hull.dat', 'w')