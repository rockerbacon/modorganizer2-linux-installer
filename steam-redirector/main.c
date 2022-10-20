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

char_t* read_path_from_file(const char* file_path) {
	errno = 0;
	FILE* file = fopen(file_path, "r");

	if (errno != 0) {
		fprintf(stderr, "ERROR: failed to open '%s' - %s\n", file_path, strerror(errno));
		return NULL;
	}

	fseek(file, 0L, SEEK_END);
	size_t estimated_line_length = ftell(file);

	if (estimated_line_length == 0) {
		fprintf(stderr, "ERROR: cannot read empty file '%s'\n", MO2_PATH_FILE);
		return NULL;
	}

	char* line = (char*)malloc(estimated_line_length + 1);

	fseek(file, 0L, SEEK_SET);
	int current_byte = fgetc(file);
	size_t byte_count = 0;
	do {
		line[byte_count] = (char)current_byte;
		current_byte = fgetc(file);
		byte_count++;
	} while (current_byte != EOF && current_byte != '\n');
	line[byte_count] = '\0';

	fclose(file);

#ifdef REQUIRE_UNICODE_CONVERSION
	char_t* converted_line = convert_from_unicode(line);
	free(line);
	return converted_line;
#else
	return line;
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

int execute_from_path_file(const char* path_file_location, const char_t* arg) {
	int exit_status = 1;
	char_t* executable_path = read_path_from_file(path_file_location);

	if (executable_path == NULL) {
		fprintf(stderr, "ERROR: could not find executable, aborting\n");
		goto exit_point;
	}

	fprintf(stdout, "INFO: read executable location '%s'\n", executable_path);
	int has_access = check_file_access(executable_path);

	if (has_access == 0) {
		fprintf(stderr, "ERROR: cannot execute '%s' - %s\n", executable_path, strerror(errno));
		goto exit_point;
	}

	fprintf(stdout, "Launching '%s'\n", executable_path);
	execute(executable_path, arg);
	exit_status = 0;

exit_point:
	if (executable_path != NULL) {
		free(executable_path);
	}

	return exit_status;
}

#ifdef REQUIRE_UNICODE_CONVERSION
int wmain(int argc, wchar_t** argv) {
#else
int main(int argc, char** argv) {
#endif
	int exit_status = 1;

	char_t *arg = NULL;
	if (argc > 1) {
		arg = argv[1];
	}

	exit_status = execute_from_path_file(MO2_PATH_FILE, arg);

	return exit_status;
}
