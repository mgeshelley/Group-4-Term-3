#!/usr/bin/env python

import numpy as np

"""@package convex_hull
Reads in data file containing final energies from CASTEP runs with a 
parameter being varied. Creates convex hull for data.
"""

#Read in data
file_name = 'madeup.dat'
data = np.genfromtxt(file_name, usecols = (0, 1))

#Number of points
n = len(data)

#Write first data point to output - will always be a hull vertex
convex_hull = open('convex_hull.dat', 'w')
convex_hull.write("%f %f\n" % (data[0,0], data[0,1]))

#'hv_new' is location in data of most recent vertex determined
hv_new = 0

#Keep checking for new vertices, provided end of data not yet reached
while hv_new < n-1:
    #-pi/2 as minimum possible angle (i.e. vertical line upwards)
    theta_max = -2.0 * np.arctan(1.0)
    #Check all data to right 'hv_new' for next vertex
    for i in range (hv_new+1, n):
        #Angle measured from x-axis to line between data points, i.e. clockwise is positive
        theta = -1 * np.arctan((data[i,1] - data[hv_new,1])/(data[i,0] - data[hv_new,0]))
        print theta, theta_max
        if theta > theta_max:
            theta_max = theta
            max_loc = i
    hv_new = max_loc
    convex_hull.write("%f %f\n" % (data[hv_new,0], data[hv_new,1]))

convex_hull.close()