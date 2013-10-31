//
//  Util.h
//  Toudaiju
//
//  Created by Arno in Wolde Lübke on 18.10.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#ifndef Toudaiju_Util_h
#define Toudaiju_Util_h

#define ASSERT(x) if (x) {} else {DumpError(#x, __FILE__, __LINE__); exit(1);}

void DumpError(const char* expr, const char* filename, int line);

#endif
