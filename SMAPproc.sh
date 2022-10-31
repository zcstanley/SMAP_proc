Code for processing SMAP files into IODA format.

SMAP files are downloaded in ~1 hour chunks. For JEDI we need (want) all of the files to be concatenated into a single file for the 6 hour assimilation window. SMAPproc.sh does the following:

1. Convert SMAP files into IODA format
2. Merge IODA files into a single file for the 6 hour window

Run with 

./SMAP_proc.sh YYYYMMDDHH 

where YYYYMMDDHH is a 10 character date string (e.g. 2016010118)
