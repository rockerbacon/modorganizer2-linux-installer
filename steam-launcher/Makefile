GNU_C=gcc
WIN_C=x86_64-w64-mingw32-gcc -static -static-libgcc -Bstatic -lpthread

default: main

all: main main-linux

# this build is mostly for debugging purposes
main-linux: main.c
	$(GNU_C) -o main main.c

main: main.c
	$(WIN_C) -o main.exe main.c

