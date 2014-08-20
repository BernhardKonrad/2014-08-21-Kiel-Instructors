


"""
This script reads in asci_ctd data and feeds it into a PostGreSQL database.


#!!!!START INSTRUCTIONS!!!!



#!!!!END INSTRUCTIONS!!!!
 """


import re
import sys
import numpy as np
import psycopg2 as pgsql





################################################################################
#######  getting pgsql connection and defining the ctd_data table  #############
################################################################################



mydb = pgsql.connect(database="swc_test", user="rkiko", password="rkiko")


cur = mydb.cursor()

#cur.execute("""DROP TABLE IF EXISTS ctd_data""")

cur.execute("""CREATE TABLE IF NOT EXISTS ctd_data
(Indx TEXT PRIMARY KEY,
Station_ID TEXT,
CTD_filename TEXT,
Cruise TEXT,
Profile_ID INT,
Date DATE,
Time TIME,
PositionLat_dec FLOAT8,
PositionLon_dec FLOAT8,
Pressure FLOAT8,
Depth FLOAT8,
Temperature FLOAT8,
Salinity FLOAT8,
Oxygen FLOAT8,
chl_raw FLOAT8)
""")





Data = open(sys.argv[1], 'r')

DataFileName = "'" + sys.argv[1] + "'"

print DataFileName

CTD_filename = "'" + sys.argv[1].split('.')[0] + "'"

print CTD_filename

Cruise_ID = sys.argv[1].split("_")[0] + "_" + sys.argv[1].split("_")[1]

print Cruise_ID




DataStart_list = {'msm_022': 68, "met_090": 67}

Cruise_list = {"msm_022":'MSM022', "met_090":"M090"}



if Cruise_ID in DataStart_list:
    DataStart = DataStart_list[Cruise_ID]
    
if Cruise_ID in Cruise_list:
    cruise = "'" + Cruise_list[Cruise_ID] + "'"




#loop through the file, take off the line endings, split the columns into fields,
#reformat the fields and insert the data into the PGSQL_database using cur.execute




LineNumber = 0


for Line in Data:
    if LineNumber < 11:
        Line = Line.strip('\r\n')
        ElementList = Line.split('= ')
        if re.sub(" ", "", ElementList[0]) == "Profile":
            profile = ElementList[1]
        if re.sub(" ", "", ElementList[0]) == "Latitude":
            lat = ElementList[1]
        if re.sub(" ", "", ElementList[0]) == "Longitude":
            lon = ElementList[1]
        if re.sub(" ", "", ElementList[0]) == "Date":
            date = "'" +  re.sub("/","", ElementList[1]) + "'"          
        if re.sub(" ", "", ElementList[0]) == "Time":
            time = "'" + re.sub(r":","", ElementList[1]) + "'"
    
            
    if LineNumber > (DataStart-2):
        Line = Line.strip('\r\n')
        DataList = Line.split()
        #print DataList
        pressure = re.sub("-9.99.*","NULL", DataList[1])
        depth = re.sub("-9.99.*","NULL", DataList[2])
        temp = re.sub("-9.99.*","NULL", DataList[3])
        sal = re.sub("-9.99.*","NULL", DataList[4])
        ox = re.sub("-9.99.*","NULL", DataList[5])
        chl_raw = re.sub("-9.99.*","NULL", DataList[8])
        indx = "'" + re.sub("'","", cruise) + "_" + profile + "_" + str(int(float(pressure))) + "'"


        #input into mysql station_book
        cur.execute("""INSERT INTO ctd_data(Indx, Cruise, CTD_filename, Profile_ID, Date, Time, PositionLat_dec, PositionLon_dec, Pressure, Depth, Temperature, Salinity, Oxygen, chl_raw) 
                     VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)""" %(indx, cruise, CTD_filename, profile, date, time, lat, lon, pressure, depth, temp, sal, ox, chl_raw))

    LineNumber += 1


Data.close()

    
cur.close()

mydb.commit()

mydb.close()

