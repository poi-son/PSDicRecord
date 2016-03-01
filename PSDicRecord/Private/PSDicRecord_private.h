//
//  PSDicRecord_private.h
//  PSExtensions
//
//  Created by PoiSon on 15/10/19.
//  Copyright © 2015年 yerl. All rights reserved.
//

#define va_array(arg_start) ({ \
   NSMutableArray *params = [NSMutableArray new]; \
   NSUInteger count = [arg_start componentsSeparatedByString:@"?"].count - 1; \
   va_list va; va_start(va, arg_start); \
   for(NSInteger i = 0; i < count; i ++){ \
      id arg = va_arg(va, id); \
      breakIf(!arg); \
      doIf(arg, [params addObject:arg]); \
   } \
   va_end(va); \
   params; \
})

#import "PSDicRecordDefines.h"
#import "PSDbContext.h"
#import "PSDb.h"
#import "PSModel.h"
#import "PSRecord.h"
#import "PSPage.h"
#import "PSSql.h"
#import "PSDbAttribute.h"
#import "PSDictionaryProtocol.h"
#import "PSSetProtocol.h"
#import "PSCaseInsensitiveContainerFactory.h"
#import "PSCaseSensitiveContainerFactory.h"
#import "PSTypeConvertor.h"


#import "PSTable.h"
#import "PSColumn.h"
#import "PSSqlBuilder.h"
#import "PSDbConfig.h"
#import "PSDbConnection.h"
#import "PSDbKit.h"
#import "convenientmacros.h"
#import "objc.h"
#import "assert.h"
