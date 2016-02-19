//
//  PSDicRecordDefines.h
//  PSDicRecord
//
//  Created by PoiSon on 16/2/19.
//  Copyright © 2016年 PoiSon. All rights reserved.
//

#ifndef PSDicRecordDefines_h
#define PSDicRecordDefines_h

#if defined(__cplusplus)
#define PSDICRECORD_EXTERN extern "C"
#else
#define PSDICRECORD_EXTERN extern
#endif

#define PSDICRECORD_EXTERN_STRING(KEY, COMMENT) PSDICRECORD_EXTERN NSString * const _Nonnull KEY;
#define PSDICRECORD_EXTERN_STRING_IMP(KEY) NSString * const KEY = @#KEY;
#define PSDICRECORD_EXTERN_STRING_IMP2(KEY, VAL) NSString * const KEY = VAL;

#define PSDICRECORD_ENUM_OPTION(ENUM, VAL, COMMENT) ENUM = VAL

#define PSDICRECORD_API_UNAVAILABLE(INFO) __attribute__((unavailable(INFO)))

#endif /* PSDicRecordDefines_h */
