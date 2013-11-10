//
//  ErrorHandler.h
//  ToudaijiCube
//
//  Created by Arno in Wolde Lübke on 10.11.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#ifndef ToudaijiCube_ErrorHandler_h
#define ToudaijiCube_ErrorHandler_h

#include <stdlib.h>
#include <stdio.h>

#define ASSERT(x) if (!(x)) {printf("Assertion %s failed in file %s line %d", #x, __FILE__, __LINE__); exit(0);}
#define REPORT(x) Report(x, __FILE__, __LINE__)

void Report(const char* msg, const char* filename, int line);

#endif
