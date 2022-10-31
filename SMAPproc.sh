#!/bin/bash

if [ $# != 1 ]; then
  echo "usage: SMAP_proc YYYYMMDDHH"
  echo "where YYYYMMDDHH is a 10 character date string (e.g. 2016010118)"
  echo "produces a single file with 6 hours of data centered around YYYYMMDDHH"
  exit 1
fi

echo "Merging SMAP files in 6 hour window centered around ${1}."

# Set directories
OBSDIR=${OBSDIR:-"/scratch2/NCEPDEV/land/data/DA/"}
SMAP_OBSDIR=${SMAP_OBSDIR:-${OBSDIR}soil_moisture/SMAP/SMAP_L2_SM_P_E_R17/2016}
WORKDIR=${WORKDIR:-"/scratch2/BMC/gsienkf/Zofia.Stanley/workdir/"}
IODA_SRC_DIR=${IODA_SRC_DIR:-"/scratch2/BMC/gsienkf/Zofia.Stanley/jedi/src/ioda-bundle/"}

cd $WORKDIR

# Copy SMAP IODA converter to WORKDIR
SMAP_IODA=smap9km_ssm2ioda.py
cp ${IODA_SRC_DIR}/iodaconv/src/land/${SMAP_IODA} $WORKDIR

# Get file names
FSTUB=SMAP_L2_SM_P_E
PREFIX=${SMAP_OBSDIR}/
SUFFIX=".h5"
PASS=D                # Note: only set up to do Descending passes
YYYY=${1:0:4}
MM=${1:4:2}
DD=${1:6:2}
HH=${1:8:2}

# Store list of files to merge later
FILES=

# Convert files containing data in 6 hour centered window to IODA format 
for INC in -4 -3 -2 -1 0 1 2
do 

# Get date INC hours away from input date
DATETIME=$(date -u -d "${YYYY}-${MM}-${DD} ${HH}:00:00 UTC ${INC} hour" +%Y%m%dT%H)

# If file exist, convert to IODA format and store name
for INFILE in ${SMAP_OBSDIR}/${FSTUB}_*_${PASS}_${DATETIME}*.h5
do

if [ -f "$INFILE" ]; then
    # Rename
    SHORTNAME=${INFILE#"$PREFIX"}
    SHORTNAME=${SHORTNAME%"$SUFFIX"}
    OUTFILE=${WORKDIR}/IODA_${SHORTNAME}.nc
    
    # Convert to IODA format
    python ${SMAP_IODA} -i ${INFILE} -o ${OUTFILE} -m maskout

    if [[ $? != 0 ]]; then
        echo "SMAP IODA converter failed"
        exit 10
    fi

    if [ -f "$OUTFILE" ]; then
        echo "IODA file created"
    fi

    # Save IODA file name
    FILES+=" "${OUTFILE}
fi

done # end for INFILE
done # end for INC

echo "Done converting SMAP files to IODA format."

# Merge ioda files
ncrcat ${FILES} -O ${WORKDIR}/smap_${YYYY}${MM}${DD}T${HH}00.nc 

echo "Done merging SMAP IODA files."
