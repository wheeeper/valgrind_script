files=main.cpp
output=output.o

compile:
	g++ -Wall -pedantic -std=c++14 -g $(files) -o $(output)

run: compile
	./$(output)

clean:
	rm -rf $(output)*

memory:
	/Users/martin/Utility/valgrind_script/valgrind.sh -r --leak-check=full

complete:
	../complet.php . files