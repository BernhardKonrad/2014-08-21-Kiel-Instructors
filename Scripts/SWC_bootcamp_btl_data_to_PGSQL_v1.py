


"""
This script reads in bottle data and feeds it into the PGSQL database.

"""


import re
import sys
import numpy as np
import psycopg2 as pgsql
#import datetime





#first connect to the pgsql database 


################################################################################
#######  getting pgsql connection and defining the ctd_data table  #############
################################################################################




mydb = pgsql.connect(database="swc_test", user="rkiko", password="rkiko")


cur = mydb.cursor()


cur.execute("""DROP TABLE IF EXISTS btl_data""")


cur.execute("""CREATE TABLE IF NOT EXISTS btl_data
(Indx TEXT PRIMARY KEY,
Station_ID TEXT,
CTD_filename TEXT,
Cruise TEXT,
Profile_ID INT,
Date DATE,
Time TIME,
PositionLat_dec FLOAT8,
PositionLon_dec FLOAT8,
Niskin_no INT,
Bedford_no INT,
Pressure FLOAT8,
Depth FLOAT8,
Temperature FLOAT8,
Salinity FLOAT8,
Oxygen FLOAT8,
POC FLOAT8,
POC_flag INT,
PON FLOAT8,
PON_flag INT,
POP FLOAT8,
POP_flag INT,
Chla FLOAT8,
Chla_flag INT
)
""")




################################################################################
#######      starting the import      #############
################################################################################






Data_msm22 = open("/Users/rkiko/git/2014-08-21-Kiel-Instructors/Data/msm22_btl_nuts_POM_chla.txt", "r")
cruise = "'" + "msm022" + "'"

LineNumber = 1



for Line in Data_msm22:     
    if LineNumber > 13:
        Line = Line.strip('\r\n') 
        # eventuell hier ein Line.replace("NaN", "NULL")
        DL = Line.split("\t") 
        DL = [re.sub("NaN", "NULL", str(x)) for x in DL]  # ersetzt durch Line.replace()
        date = "'" + DL[1] + "'"
        profile = DL[2]
        ctd_filename = "'" + "msm_022_1_" + str(profile).zfill(3) + "'"
        lat = DL[3]
        lon = DL[4]
        niskin = DL[5]
        indx = "'" + re.sub("'","",ctd_filename) + "_" + str(niskin).zfill(2) + "'"  # eventuell wieder string.replace()
        btl_depth = DL[7]
        Chla = DL[16]
        Chla_flag = DL[17]
        POC = DL[18]
        POC_flag = DL[19]
        PON = DL[20]
        PON_flag = DL[21]
        POP = DL[20]
        POP_flag = DL[21]
        cur.execute("""INSERT INTO btl_data(Indx, CTD_filename, Cruise, Profile_ID, Date, PositionLat_dec, PositionLon_dec, Niskin_no, Depth, POC, POC_flag, PON, PON_flag, POP, POP_flag, Chla, Chla_flag) 
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)""" %(indx, ctd_filename, cruise, profile, date, lat, lon, niskin, btl_depth, POC, POC_flag, PON, PON_flag, POP, POP_flag, Chla, Chla_flag))  # not sure if this line works

    LineNumber += 1



Data_msm22.close()



cur.close()

mydb.commit()

mydb.close()
