#!/bin/bash


# #To Do
# - wyszukiwanie tekstu w obrazkach
# - flaga do automatycznego odpalania zdjęć lub wyświetlanie nazw plików


help () {
echo "
$(basename "${0}") [-p <path>] [-g] [-f \"pattern\"] [-o] -- Find words in images

where:
    -p  set <path> for files directory
    -c  make cache for catalog
    -f  phrase to find
    -h  show this help
"
exit
}


make-cache () {
  if [[ ! -d ".cache" ]]; then
    mkdir ${path}/.cache
    for file in $(ls -1 ${path}) ; do
      tesseract ${path}/${file} ${path}/.cache/${file} -l pol
    done
  else
    echo "Cache already created"
    exit
  fi
}

find-phrases () {
  [[ ! -d ${path}/.cache ]] && echo "Generate cache first" && exit
  grep -Rli "${phrases}" ${path}/.cache | sed 's/.*.cache\///' | sed 's/.txt//' > ${path}/.cache/matching
  cat ${path}/.cache/matching
}

open-files () {
  for file in $(cat "${path}/.cache/matching"); do
    open ${path}/${file}
  done
}

## Main script

# Check if params start with "-""
[[ ! $@ =~ ^\-.+ ]] && help

# Parsing bash script options with getopts

while getopts ':hp:cf:o' option; do
  case "${option}" in
    h)
    help
    ;;
    
    p)
    path="${OPTARG}"
    ;;

    c)
    make-cache 
    ;;

    f)
    phrases=${OPTARG}
    find-phrases
    ;;

    o)
    open-files
    ;;

    :)
    printf "Missing argument for -%s\n" "${OPTARG}" 1>&2
    help
    ;;

    \?)
    printf "Illegal option: -%s\n" "${OPTARG}" 1>&2
    help
    ;;
  esac
done
# It is common practice to call the shift command at the end of your processing loop
# to remove options that have already been handled from $@
shift $((OPTIND -1))