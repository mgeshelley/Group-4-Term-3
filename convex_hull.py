#!/usr/bin/env python

import numpy as np

"""
Reads in data file containing final energies from CASTEP runs with a 
parameter being varied. Creates convex hull for data.
"""

#Read in data
file_name = 'madeup.dat'
data = np.genfromtxt(file_name, usecols = (0, 1))

n = len(data)

#Array for hull vertices
hv = np.zeros((1,2))

#First hull vertex must be first data point
hv[0,:] = data[0,:]

hv_new = 0
theta_max = 4.0 * np.arctan(1.0)

while hv_new != n:
    points_to_check = n - hv_new
    for i in range (0, points_to_check):
        theta = -1 * np.arctan((data[i,1] - data[hv_new,1])/(data[i,0] - data[hv_new,0]))
        max_loc = hv_new + i
        if theta > theta_max:
            theta_max = theta
            max_loc = hv_new + i
    hv = [[hv],[data[max_loc,:]]]
    hv_new = max_loc

#Write 'hv' to file
convex_hull = open('convex_hull.dat', 'w')