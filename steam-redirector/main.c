#ifdef __unix__
#define _GNU_SOURCE
#endif

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32

#include <io.h>
#include <process.h>

#define MO2_PATH_FILE "modorganizer2\\instance_path.txt"

#elif __unix__

#include "unix_utils.h"

#define MO2_PATH_FILE "modorganizer2/instance_path.txt"

#endif

void start_mo2(const char* mo2_executable_path) {
	fprintf(stdout, "Launching '%s'\n", mo2_executable_path);

#ifdef _WIN32
	_execv(mo2_executable_path, NULL);
#elif __unix__
	execute(mo2_executable_path);
#endif
}

char* find_mo2_exec_path() {
	errno = 0;
	FILE* file = fopen(MO2_PATH_FILE, "r");

	if (errno != 0) {
		fprintf(stderr, "ERROR: failed to open '%s' - %s\n", MO2_PATH_FILE, strerror(errno));
		return NULL;
	}

	fseek(file, 0L, SEEK_END);
	size_t estimated_path_length = ftell(file);

	if (estimated_path_length == 0) {
		fprintf(stderr, "ERROR: cannot read empty file '%s'\n", MO2_PATH_FILE);
		return NULL;
	}

	char* path = (char*)malloc(estimated_path_length + 1);

	fseek(file, 0L, SEEK_SET);
	int read_char = fgetc(file);
	size_t char_count = 0;
	do {
		path[char_count] = (char)read_char;
		read_char = fgetc(file);
		char_count++;
	} while (read_char != EOF && read_char != '\n');
	path[char_count] = '\0';

	fclose(file);

	return path;
}

int check_file_access(const char* path) {
	errno = 0;
#ifdef _WIN32
	_access(path, 0);
#elif __unix__
	check_can_execute(path);
#endif

	if (errno == 0) {
		return 1;
	} else {
		return 0;
	}
}

int main() {
	char* mo2_exec_path = find_mo2_exec_path();

	if (mo2_exec_path == NULL) {
		fprintf(stderr, "ERROR: could not find Mod Organizer 2 executable, aborting\n");
		return 1;
	}

	int has_access = check_file_access(mo2_exec_path);

	if (has_access == 0) {
		fprintf(stderr, "ERROR: cannot execute '%s' - %s\n", mo2_exec_path, strerror(errno));
		return 1;
	}

	start_mo2(mo2_exec_path);

	free(mo2_exec_path);

	return 0;
}
