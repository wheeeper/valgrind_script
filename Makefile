files=main.cpp
output=output.o

compile:
	g++ -Wall -pedantic -g $(files) -o $(output)

run: compile
	./$(output)

clean:
	rm -rf $(output)*

memory:
	/Users/martin/Utility/sample-data/valgrind/valgrind.sh -r --leak-check=full

