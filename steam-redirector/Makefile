GNU_C=gcc
WIN_C=x86_64-w64-mingw32-gcc

default: main.exe

all: main.exe main

# this build is mostly for debugging purposes
main: main.c unix_utils.c
	$(GNU_C) -o main unix_utils.c main.c

main.exe: main.c win32_utils.c
	$(WIN_C) -mwindows -municode -static -static-libgcc -Bstatic -lpthread -o main.exe win32_utils.c main.c

