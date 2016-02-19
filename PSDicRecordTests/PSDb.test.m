//
//  PSDbTests.m
//  PSDicRecord
//
//  Created by PoiSon on 16/1/30.
//  Copyright © 2016年 PoiSon. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PSDicRecord.h"
#import "Student.h"

@interface PSDbTests : XCTestCase

@end

@implementation PSDbTests
+ (void)setUp{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *dbPath = [[docDir stringByAppendingPathComponent:@"db"] stringByAppendingPathComponent:@"database.db"];
    
    [[NSFileManager new] removeItemAtPath:dbPath error:nil];
    
    PSDbContext *record = [[PSDbContext alloc] initWithDatasource:dbPath];
    record.showSql = YES;
    [record registerModel:[Student class]];
    [record start];
    
    NSMutableArray<PSSql *> *inserts = [NSMutableArray arrayWithCapacity:20];
    for (NSInteger i = 0; i < 20; i ++) {
        [inserts addObject:[PSSql buildSql:@"insert into student(name, age) values(?, ?)", [NSString stringWithFormat:@"张%@", @(i)], @(i)]];
    }
    NSAssert([[PSDb main] batchSqls:inserts], @"batch fail");
}

- (void)testUse{
    XCTAssertThrows([PSDb use:@"abc"], @"期望抛异常");
    PSDb *db = [PSDb use:nil];
    XCTAssertNotNil(db);
}
/** 测试查询. */
- (void)testQueryOne{
    NSNumber *count = [[PSDb main] queryOne:@"select count(1) from student"];
    XCTAssertNotNil(count);
    XCTAssertThrows([[PSDb main] queryOne:@"select * from student"]);
}
/** 测试查询. */
- (void)testUpdate{
    int count = [[PSDb main] update:@"update student set name = '张三' where name = ?", @"张3"];
    XCTAssertEqual(count, 1, @"更新数目不一致");
}

/** 测试查找. */
- (void)testFindRecords{
    NSArray *results = [[PSDb main] find:@"select * from student where 1 = ?", @(1)];
    XCTAssert(results.count);
}
- (void)testFindFistRecord{
    PSRecord *aStu1 = [[PSDb main] findFirst:@"select * from student where 1 = ?", @(1)];
    XCTAssertNotNil(aStu1);
    
    PSRecord *aStu2 = [[PSDb main] findFirst:@"select * from student where 1 = ? limit 1", @(1)];
    XCTAssertNotNil(aStu2);
}

- (void)testPage{
    PSPage *page = [[PSDb main] paginate:1 size:10 withSelect:@"select *" where:@"from student where 1 = ?", @(1)];
    XCTAssertNotNil(page);
    XCTAssertEqual(page.pageSize, 10);
    XCTAssertEqual(page.pageIndex, 1);
    XCTAssert(page.totalRow > page.pageSize);
    XCTAssert(page.totalPage > 1);
}

//- (void)testPerformanceInsert{
//    NSMutableArray *inserts = [NSMutableArray arrayWithCapacity:20];
//    for (NSInteger i = 0; i < 1200; i ++) {
//        [inserts addObject:format(@"insert into student(name, age) values('张%@', %@)", @(i), @(i))];
//    }
//    [self measureBlock:^{
//        [[PSDb new] batch:inserts];
//    }];
//}
@end
