#!/usr/bin/env bash
#set -x
toDir=fra_pinne
fromDir=/mnt/c/fra_pinne/100_PANA
for origFile in $(find "$fromDir" -type f); do
  f=$(basename "$origFile")
  mv "$origFile" "$f"

  ext="${f##*.}"
  if [[ "$ext" == "JPG" || "$ext" == "jpg" ]]; then
    ym=$(identify -verbose "$f" | grep 'date:create' | sed -e 's/.*: //' -e 's/...T.*//')
    y=${ym%%-*}
    m=${ym##*-}
  elif [[ "$ext" == "MP4" || "$ext" == "mp4" ]]; then
    ymdt=$(exiftool fra_pinne/P1000303.MP4 | grep 'Date/Time Original' | head | sed 's/.*: //')
    ymd=${ymdt%% *}
    ym=${ymd%:*}
    y=${ym%%:*}
    m=${ym##*:}
  else
    y="9999"
    m="12"
  fi
  d="$toDir/$y/$m"

  mkdir -p "$d"

  if [ -f "$d/$f" ]; then
    sum1=$(cksum "$f" | sed 's/ .*//')
    sum2=$(cksum "$d/$f" | sed 's/ .*//')
    if [[ "$sum1" == "$sum2" ]]; then
      echo "Already present: $f"
      rm "$f"
    else
      echo mv "$f" "$d/$sum1$f"
      mv "$f" "$d/$sum1$f"
    fi
  else
    echo mv "$f" "$d/$f"
    mv "$f" "$d/$f"
  fi
done
