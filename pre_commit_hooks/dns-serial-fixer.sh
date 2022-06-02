#!/bin/bash

DATE=$(date +%Y%m%d)
NEEDLE="Serial"
SED="$(command -v gsed || command -v sed)"

for ZONE in $@ ; do
    # echo
    # echo "===== $ZONE ====="
    # echo
    curr=$(grep -e "${NEEDLE}\s*$" ${ZONE} | ${SED} -n "s/^\s*\([0-9]*\)\s*;\s*${NEEDLE}\s*$/\1/p")
    if [[ ${#curr} -lt ${#DATE} ]]; then
      serial="${DATE}00"
    else
      prefix=${curr::-2}
      if [[ "$DATE" -eq "$prefix" ]]; then # same day
        num=${curr: -2} # last two digits from serial number
        num=$((10#$num + 1)) # force decimal representation, increment
        serial="${DATE}$(printf '%02d' $num )" # format for 2 digits
      elif [[ "$DATE" -lt "$prefix" ]]; then
        num=${curr: -2} # last two digits from serial number
        num=$((10#$num + 1)) # force decimal representation, increment
        serial="${prefix}$(printf '%02d' $num )" # format for 2 digits
      else
        serial="${DATE}00" # just update date
      fi
    fi
    ${SED} -i -e "s/^\(\s*\)[0-9]\{0,\}\(\s*;\s*${NEEDLE}\)\s*$/\1${serial}\2/" ${ZONE}
    echo "${ZONE}: $(grep "; ${NEEDLE}$" ${ZONE})"
done
