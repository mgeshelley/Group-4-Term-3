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

convex_hull = open('convex_hull.dat', 'w')
convex_hull.write("%f %f\n" % (data[0,0], data[0,1]))
hv_new = 0
while hv_new < n-1:
    #-pi/2 as minimum possible angle
    theta_max = -2.0 * np.arctan(1.0)
    for i in range (hv_new+1, n):
        theta = -1 * np.arctan((data[i,1] - data[hv_new,1])/(data[i,0] - data[hv_new,0]))
        print theta, theta_max
        if theta > theta_max:
            theta_max = theta
            max_loc = i
    hv_new = max_loc
    convex_hull.write("%f %f\n" % (data[hv_new,0], data[hv_new,1]))
