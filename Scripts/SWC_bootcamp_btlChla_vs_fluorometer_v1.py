
"""

generate 2d plots of btlchla vs fluorometer chla

"""

#to get data out of the database and into a pandas dataframe, I now use pandas.io.sql
#works nice and is much shorter
#just insert the SQL statement


import psycopg2 as pgsql

import re
import pandas.io.sql as sql
import numpy as np
import matplotlib.pyplot as plt
import sys
#import re
#import os
from scipy.optimize import curve_fit
from scipy.stats import linregress


mydb = pgsql.connect(database="swc_test", user="rkiko", password="rkiko")

###### defining needed functions ######

def lin_func(x,a,b):
    return a*x + b

def lin_fit(y,x):
    a_fit, b_fit = curve_fit(lin_func, y, x)
    return a_fit[0], a_fit[1], b_fit
    
def regr_own(x_data, y_data):
    a,b,r2,c,d = linregress(x_data, y_data)
    r2 = round(r2, 2)
    print "a: " +str(a)
    print "b: " +str(b)
    print "r2: " + str(r2)
    t = np.linspace(np.min(x_data), np.max(x_data), num = 3)
    s = a*t + b
    return a, b, r2, s, t

######


para_y = sys.argv[1] #
para_x = sys.argv[2]





####### plotting set up

fig = plt.figure(1, figsize=(3.5,5))


#plt.rcParams.update({'font.size': 6})

w = 0.85
h = 0.8
lower = 0.06
left = 0.12





###### getting the data


df = sql.read_sql("""
select btl.ctd_filename, btl.depth, avg(c.depth) as avg_ctd_depth, avg(c.%s) as %s, avg(btl.btl_var) as %s
from ctd_data as c

LEFT JOIN LATERAL
(select b.depth, b.ctd_filename, b.%s as btl_var
from btl_data as b
where b.depth < 150
) as btl

ON btl.ctd_filename = c.ctd_filename
where c.depth BETWEEN btl.depth - 5 and btl.depth + 5
GROUP BY btl.depth, btl.ctd_filename

"""%(para_y, para_y, para_x, para_x), mydb)



mydb.close()



df = df.dropna()




xs = np.array(df[para_x])
ys = np.array(df[para_y])



r = regr_own(xs, ys)

print r

ax1 = fig.add_axes([left, lower, w, h])
plot1 = plt.scatter(xs,ys, c = 'b')
plt.plot(r[4], r[3], linewidth=1.0, color = 'b')
plt.text(0, 0.5, 'r^2 = ' + str(r[2]), color = 'r')
plt.ylabel('Chla btl') 
plt.xlabel('Chla sensor')

        
                
#fig_name = "Chlbtl_vs_Chlsensor_v1.pdf"

#plt.savefig(fig_name)

plt.show(fig)
                        



