GNU_C=gcc
WIN_C=x86_64-w64-mingw32-gcc -static -static-libgcc -Bstatic -lpthread

default: main

all: main main-linux

unix_utils.o: unix_utils.c unix_utils.h
	$(GNU_C) -c unix_utils.o unix_utils.c

# this build is mostly for debugging purposes
main-linux: main.c unix_utils.o
	$(GNU_C) -o main unix_utils.o main.c

main: main.c
	$(WIN_C) -o main.exe main.c

