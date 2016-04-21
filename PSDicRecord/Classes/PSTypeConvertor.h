//
//  PSTypeConvertor.h
//  PSExtensions
//
//  Created by PoiSon on 16/1/1.
//  Copyright © 2016年 yerl. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PSSQLiteTypeNULL @"NULL"
#define PSSQLiteTypeINTEGER @"INTEGER"
#define PSSQLiteTypeREAL @"REAL"
#define PSSQLiteTypeTEXT @"TEXT"
#define PSSQLiteTypeBLOG @"BLOG"

typedef struct sqlite3_stmt sqlite3_stmt;

/**
 *  Property vlaue convertor
 *  convert property type to objc type
 */
@protocol PSTypeConvertor<NSObject>
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) Class objcType;
@property (nonatomic, readonly) NSString *dataType;
@property (nonatomic, readonly) NSMethodSignature *setterSignature;
@property (nonatomic, readonly) NSMethodSignature *getterSignature;

- (void)bindObject:(id)obj toColumn:(int)idx inStatement:(sqlite3_stmt *)statement;

- (id)getBuffer:(void *)buffer fromObject:(id)obj;
- (id)objectForBuffer:(void *)buffer;
@end
