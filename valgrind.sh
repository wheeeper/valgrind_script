#!/bin/bash

# SCRIPT FOR USING VALGRIND IN DOCKER
# TO LEARN USE RUN SCRIPT WITH --help

# NAME OF DOCKER IMAGE
DOCKER_IMAGE="mem-check"

# SWITCHES FOR COMPILER
COMP_SWITCH="-g -std=c++14"

print_info() {
  echo
  echo "##########################/* VALGRIND SCRIPT 1.1 */##########################"
  echo "To setup script, run script with --setup"
  echo
  echo "Please specify the file you want to memory check and the valgrind switches."
  echo "   valgrind \"FILE\" SWITCHES"
  echo
  echo "For leaks run with \"--leak-check=full\""
  echo
  echo "Also works with Makefile, to create makefile run with -m or --make"
  echo "To change files in makefile run with -f or --files and list the files"
  echo
  echo
  echo "Run with --compile for compilition inside docker via the Makefile"
  echo "Run with -r, --run or run for valgrind run. After then you can specify"
  echo "the valgrind switches"
  echo
  echo
  echo "To see current switches, run script with --comp-switches"
  echo "To change compilation switches, run script with --comp-switches SWITCHES"
  echo "#############################################################################"
  echo
  exit 0
}

check_answer() {
  echo "Y/N"
  read response

  if [[ $response =~ "y" ]] || [[ $response =~ "Y" ]] || [ -z $response ]; then
    return
  fi
  if [[ $response =~ "n" ]] || [[ $response =~ "N" ]] || ! [ -z $response ] && ! [[ $response =~ "y" ]] && ! [[ $response =~ "Y" ]]; then
    echo "Script aborted."
    exit 1
  fi
}

create_makefile() {
  cp $(dirname "$0")/Makefile Makefile
  echo "Succesfully created Makefile"
}

check_makefile() {
  if ! [ -f Makefile ]; then
    echo "Makefile file not found, do you want to create makefile?"
    check_answer
    create_makefile
  fi
}

change_files() {
  sed -e s/"files=.*$"/"files="$@""/1 "./Makefile" >tmp
  mv tmp Makefile
  echo "Files in a Makefile were changed to:"
  cat Makefile | head -n 1
}

if [ $PWD == $(dirname "$0") ]; then
  echo "Script not supported in its default destination, aborted."
  exit 2
fi

#### MAIN ######

if [ "$#" -lt 1 ] || [[ "$1" =~ --help ]] || [[ "$1" =~ -h ]]; then
  print_info
fi

if [[ "$1" =~ --make ]] || [[ "$1" =~ -m ]]; then
  create_makefile
  exit 0
fi

if [[ "$1" =~ --files ]] || [[ "$1" =~ -f ]]; then
  if [ "$#" -lt 2 ]; then
    echo "Files not specified, please specify the files"
    exit 1
  fi
  check_makefile
  change_files ${*:2}
  exit 0
fi

if [[ "$1" =~ --bash ]]; then
  docker run -ti -v $PWD:/test mem-check bash
  exit 0
fi

if [[ "$1" =~ --compile ]]; then
  check_makefile
  docker run -ti -v $PWD:/test "$DOCKER_IMAGE" bash -c "cd /test/; make compile"
  exit 0
fi

if [[ "$1" =~ --run ]] || [[ "$1" =~ -r ]] || [[ "$1" =~ run ]]; then
  check_makefile
  docker run -ti -v $PWD:/test "$DOCKER_IMAGE" bash -c "cd /test/; make compile && valgrind "${*:2}" ./output.o "
  exit 0
fi

if [[ "$1" =~ --setup ]]; then
  if [ "$#" -eq 1 ]; then
    echo "To setup script run script with --setup \"NAME OF DOCKER IMAGE\""
    exit 0
  fi

  sed -e s/"DOCKER_IMAGE=.*\"$"/"DOCKER_IMAGE=\""$2"\""/1 "${0}" >tmp
  chmod u+ tmp
  mv tmp "${0}"
  echo "Docker image name changed to:" "$2"
  exit 0

fi

if [[ "$1" =~ --comp-switches ]]; then

  if [ "$#" -eq 1 ]; then
    echo "Current switches:" $COMP_SWITCH
    exit 0
  fi

  sed -e s/"COMP_SWITCH=.*\"$"/"COMP_SWITCH=\"${*:2}\""/1 "${0}" >tmp
  chmod + tmp
  mv tmp "${0}"
  echo "Compilation switches have been changed to: ${*:2}"
  exit 0
fi

if ! [[ "$1" =~ \.cpp ]] && ! [[ "$1" =~ \.c ]] && ! [[ "$1" =~ \.o ]] && ! [[ "$1" =~ \.out ]]; then

  echo "Not supported file, please use C++ or C source code or compiled file."
  exit 2
fi

if [[ "$1" =~ .o ]] || [[ "$1" =~ .out ]]; then
  docker run -ti -v $PWD:/test "$DOCKER_IMAGE" bash -c "cd /test/; valgrind ${*:2} ./"$1""
fi

if [ $(
  ls $(basename "$1") &>/dev/null
  echo $?
) -ne 0 ]; then
  cd $(dirname "$1")
fi

docker run -ti -v $PWD:/test "$DOCKER_IMAGE" bash -c "cd /test/; g++ $COMP_SWITCH -o main.o "$(basename $1)" && valgrind ${*:2} ./main.o"
rm main.o &>/dev/null

exit 0
