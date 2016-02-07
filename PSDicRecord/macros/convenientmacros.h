//
//  Macros for convenient
//
//  Created by PoiSon on 15/10/8.
//  Copyright © 2015年 yerl. All rights reserved.
//

#ifndef PS_CONVENIENT_MACROS_H
#define PS_CONVENIENT_MACROS_H

#define returnValIf(condition, val) if (!!(condition)){ return val;}
#define returnIf(condition)         if (!!(condition)){ return;    }
#define breakIf(condition)          if (!!(condition)){ break;     }
#define continueIf(condition)       if (!!(condition)){ continue;  }


#define doIf(condition, action) \
   do {                         \
      if(!!(condition)){        \
         action;                \
      }                         \
   } while(0)

//消除[NSObject performSelector:]引起的警告
#define SuppressPerformSelectorLeakWarning(action)                        \
   do {                                                                   \
      _Pragma("clang diagnostic push")                                    \
      _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
      action;                                                             \
      _Pragma("clang diagnostic pop")                                     \
   } while (0)

#define PSEnumOption(enum, value, comment) enum = value
#define PSExternString(key, comment) FOUNDATION_EXPORT NSString * const _Nonnull key;
#define PSExternStringVal(key, val) NSString * const key = val;

#endif