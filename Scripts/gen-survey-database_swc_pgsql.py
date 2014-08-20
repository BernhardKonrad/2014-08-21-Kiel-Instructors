
"""

before you can start, you have to create the database swc_test from your postgres superaccount

start psql using

> psql "user=postgres"

than

CREATE DATABASE survey WITH OWNER = rkiko;


"""


import psycopg2 as pgsql
import pandas.io.sql as sql




mydb = pgsql.connect(database="survey", user="rkiko", password="rkiko")

cur = mydb.cursor()



"""
-- The `Person` table is used to explain the most basic queries.
-- Note that `danforth` has no measurements.
"""


cur.execute("""DROP TABLE IF EXISTS Person""")

cur.execute("""CREATE TABLE IF NOT EXISTS Person
(ident    text,
personal text,
family	 text
)
""", mydb)



"""
-- The `Site` table is equally simple.  Use it to explain the
-- difference between databases and spreadsheets: in a spreadsheet,
-- the lat/long of measurements would probably be duplicated.
"""


cur.execute("""DROP TABLE IF EXISTS Site""")

cur.execute("""CREATE TABLE IF NOT EXISTS Site
(name    text,
lat float8,
long	 float8
)
""", mydb)

"""
-- `Visited` is an enhanced `join` table: it connects to the lat/long
-- of specific measurements, and also provides their dates.
-- Note that #752 is missing a date; we use this to talk about NULL.

-- RK: changed the type of date from text to date

"""


cur.execute("""DROP TABLE IF EXISTS Visited""")

cur.execute("""CREATE TABLE IF NOT EXISTS Visited
(ident    int,
site text,
date	 date
)
""", mydb)

"""
-- The `Survey` table is the actual readings.  Join it with `Site` to
-- get lat/long, and with `Visited` to get dates (except for #752).
-- Note that Roerich's salinity measurements are an order of magnitude
-- too large (use this to talk about data cleanup).  Note also that
-- there are two cases where we don't know who took the measurement,
-- and that in most cases we don't have an entry (null or not) for the
-- temperature.
"""


cur.execute("""DROP TABLE IF EXISTS Survey""")

cur.execute("""CREATE TABLE IF NOT EXISTS Survey
(taken    INT,
person text,
quant	 text,
reading FLOAT8
)
""", mydb)


####Inserting the data


cur.execute("""insert into Person values
('dyer',     'William',   'Dyer'),
('pb',       'Frank',     'Pabodie'),
('lake',     'Anderson',  'Lake'),
('roe',      'Valentina', 'Roerich'),
('danforth', 'Frank',     'Danforth')
""")

cur.execute("""insert into Site values
('DR-1', -49.85, -128.57),
('DR-3', -47.15, -126.72),
('MSK-4', -48.87, -123.40)
""")

cur.execute("""insert into Visited values
(619, 'DR-1',  '1927-02-08'),
(622, 'DR-1',  '1927-02-10'),
(734, 'DR-3',  '1939-01-07'),
(735, 'DR-3',  '1930-01-12'),
(751, 'DR-3',  '1930-02-26'),
(752, 'DR-3',  null),
(837, 'MSK-4', '1932-01-14'),
(844, 'DR-1',  '1932-03-22')
""")



cur.execute("""insert into Survey values
(619, 'dyer', 'rad',    9.82),
(619, 'dyer', 'sal',    0.13),
(622, 'dyer', 'rad',    7.80),
(622, 'dyer', 'sal',    0.09),
(734, 'pb',   'rad',    8.41),
(734, 'lake', 'sal',    0.05),
(734, 'pb',   'temp', -21.50),
(735, 'pb',   'rad',    7.22),
(735, null,   'sal',    0.06),
(735, null,   'temp', -26.00),
(751, 'pb',   'rad',    4.35),
(751, 'pb',   'temp', -18.50),
(751, 'lake', 'sal',    0.10),
(752, 'lake', 'rad',    2.19),
(752, 'lake', 'sal',    0.09),
(752, 'lake', 'temp', -16.00),
(752, 'roe',  'sal',   41.60),
(837, 'lake', 'rad',    1.46),
(837, 'lake', 'sal',    0.21),
(837, 'roe',  'sal',   22.50),
(844, 'roe',  'rad',   11.25)
""")


mydb.commit()

cur.close()
mydb.close()



