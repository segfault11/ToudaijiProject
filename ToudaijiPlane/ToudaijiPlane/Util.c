//
//  Util.c
//  Toudaiju
//
//  Created by Arno in Wolde Lübke on 18.10.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#include <stdio.h>
#include "Util.h"

void DumpError(const char* expr, const char* filename, int line)
{
    printf(
        "Assertion \"%s\" Failed.\nFilename: %s\nLine: %d ",
        expr,
        filename,
        line
    );
}