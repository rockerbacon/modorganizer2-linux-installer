#ifdef __unix__
#define _GNU_SOURCE
#endif

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32

#include "win32_utils.h"

#define MO2_PATH_FILE "modorganizer2\\instance_path.txt"

#elif __unix__

#include "unix_utils.h"

#define MO2_PATH_FILE "modorganizer2/instance_path.txt"

#endif

void start_mo2(const char_t* mo2_executable_path) {
	fprintf(stdout, "Launching '%s'\n", mo2_executable_path);
	execute(mo2_executable_path);
}

char_t* find_mo2_exec_path() {
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
	int current_byte = fgetc(file);
	size_t byte_count = 0;
	do {
		path[byte_count] = (char)current_byte;
		current_byte = fgetc(file);
		byte_count++;
	} while (current_byte != EOF && current_byte != '\n');
	path[byte_count] = '\0';

	fclose(file);

#ifdef REQUIRE_UNICODE_CONVERSION
	char_t* converted_path = convert_from_unicode(path);
	free(path);
	return converted_path;
#else
	return path;
#endif
}

int check_file_access(const char_t* path) {
	errno = 0;
	check_can_execute(path);

	if (errno == 0) {
		return 1;
	} else {
		return 0;
	}
}

int main() {
	int exit_status = 1;

	char_t* mo2_exec_path = find_mo2_exec_path();

	if (mo2_exec_path == NULL) {
		fprintf(stderr, "ERROR: could not find Mod Organizer 2 executable, aborting\n");
		goto exit_point;
	}

	fprintf(stdout, "INFO: read Mod Organizer 2 location '%s'", mo2_exec_path);
	int has_access = check_file_access(mo2_exec_path);

	if (has_access == 0) {
		fprintf(stderr, "ERROR: cannot execute '%s' - %s\n", mo2_exec_path, strerror(errno));
		goto exit_point;
	}

	start_mo2(mo2_exec_path);
	exit_status = 0;

exit_point:
	if (mo2_exec_path != NULL) {
		free(mo2_exec_path);
	}

	return exit_status;
}
