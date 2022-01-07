#include <unistd.h>
#include <stdio.h>

#include "unix_utils.h"

void execute(const char_t* path) {
	execv(path, NULL);
}

void check_can_execute(const char_t* path) {
	access(path, X_OK);
}

