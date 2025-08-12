#ifndef STRING_UTILS_H
#define STRING_UTILS_H

#include <Arduino.h>

class StringUtils {
public:
    static String removeAccents(const String& text);
};

#endif