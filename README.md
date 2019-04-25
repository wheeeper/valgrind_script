# Valgrind script

### __What is it?__
It's a script for running valgrind inside a docker image, mainly for macOS because of the lack of support for the macOS Mojave. 

### __Requirements and instalation__
For this you need to download docker and create an image. You can use the instructions listed [here](https://www.gungorbudak.com/blog/2018/06/13/memory-leak-testing-with-valgrind-on-macos-using-docker-containers/).
I advise you to use the dockerfile I created, because it has some additional stuff for this script to work properly.

The script runs in two modes - with or without using the makefile. Use the makefile when you need to compile more than one file.

You also need the default Makefile present inside the folder with this script.

Also its best to create an alias for this script. In the instructions I will be using the alias &nbsp; `valgrind`


### __How to use__

You can get list of commands by running the script with `-h` &nbsp; or &nbsp; `--help`

To setup the script, run it
```
valgrind --setup "NAME_OF_DOCKER_IMAGE"`
```
You can use it as normal valgrind program, but you dont list the binary file, just the source (at the moment works with only one file)
```bash
valgrind FILE SWITCHES
```

To change compilation switches. _Note - At the moment the change reflects only when you run it with the source file. It doesnt affect the makefile, if you want to change the switches there, edit the default makefile._
```bash
valgrind --comp-switches LIST_OF_SWITCHES
```



To create makefile inside the current folder with you source files
 ```bash 
 valgrind -m 
 valgrind --make
 ```
To change the list of source files inside the Makefile 
```bash
valgrind -f LIST_OF_FILES
valgrind --files LIST_OF_FILES
```
 To run valgrind via the make file
 ```bash
 valgrind -r LIST_OF_VALGRIND_SWITCHES
 valgrind run LIST_OF_VALGRIND_SWITCHES
 valgrind -run LIST_OF_VALGRIND_SWITCHES
 ```

 Docker container creates a different type of binary, than macOS. If you want to just compile inside docker
 ```bash
valgrind --compile
 ```


