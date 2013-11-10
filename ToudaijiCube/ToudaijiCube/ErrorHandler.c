//
//  ErrorHandler.c
//  ToudaijiCube
//
//  Created by Arno in Wolde Lübke on 10.11.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#include "ErrorHandler.h"

void Report(const char* msg, const char* filename, int line)
{
    printf("Error in file %s line %d. Message: %s", filename, line, msg);
    exit(0);
}