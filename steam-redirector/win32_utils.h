#pragma once

#include <wchar.h>

#define REQUIRE_UNICODE_CONVERSION

typedef wchar_t char_t;

void execute(const char_t* path);

void check_can_execute(const char_t* path);

char_t read_character(FILE* file);

char_t* convert_from_unicode(const char* str);

