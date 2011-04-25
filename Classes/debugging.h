/*
 *  debugging.h
 *  patch
 *
 *  Created by Robert Diamond on 1/20/11.
 *  Copyright 2011 Patch.com. All rights reserved.
 *
 */

#if !defined(NDEBUG)
#define LOG_DEBUG(x,...) NSLog(x,##__VA_ARGS__)
#else
#define LOG_DEBUG(x,...)
#endif