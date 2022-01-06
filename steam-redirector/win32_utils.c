#include <io.h>
#include <process.h>

#include "win32_utils.h"

void execute(const char_t* path) {
	_execv(path, NULL);
}

void check_can_execute(const char_t* path) {
	_access(path, 0);
}

