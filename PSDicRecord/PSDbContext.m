//
//  PSDbContext.m
//  PSDicRecord
//
//  Created by yan on 16/2/6.
//  Copyright © 2016年 PoiSon. All rights reserved.
//

#import "PSDicRecord_private.h"


@implementation PSDbContext{
    NSMutableArray *_registedModel;
}

- (instancetype)init{
    PSAssert(NO, @"use initWithDatasource:forConfig: instead");
    return self = [self initWithDatasource:@"" forConfig:@""];
}

- (instancetype)initWithDatasource:(NSString *)dataSource{
    return [self initWithDatasource:dataSource forConfig:@"main"];
}

- (nonnull instancetype)initWithDatasource:(nonnull NSString*)datasource forConfig:(nonnull NSString *)configName{
    PSAssert(datasource.length, @"datasource can not be nil or empty");
    PSAssert(configName.length, @"configName can not be nil or empty");
    if (self = [super init]) {
        _registedModel = [NSMutableArray new];
        
        _datasource = datasource;
        _configName = configName;
    }
    return self;
}

- (NSString *)description{
    NSMutableString *result = [NSMutableString new];
    for (id value in _registedModel) {
        doIf(result.length, [result appendString:@","]);
        [result appendFormat:@"%@", value];
    }
    
    return [NSString stringWithFormat:@"<PSDicRecord %p>:\n{\n   Models : %@\n   Datasource : %@\n}", [super description], result, self.datasource];
}

- (NSString *)debugDescription{
    NSMutableString *result = [NSMutableString new];
    for (id value in _registedModel) {
        doIf(result.length, [result appendString:@","]);
        [result appendFormat:@"%@", value];
    }
    return [NSString stringWithFormat:@"<PSDicRecord %p>:\n{\n   Models : %@\n   Datasource : %@\n}", [super description], result, self.datasource];
}

- (id<PSContainerFactory>)containerFactory{
    return _containerFactory?: [PSCaseSensitiveContainerFactory new];
}

- (void)registerModel:(Class)model{
    PSParameterAssert([model isSubclassOfClass:[PSModel class]]);
    [_registedModel addObject:model];
}

- (void)registerConvertor:(id<PSTypeConvertor>)convertor{
    PSParameterAssert([convertor conformsToProtocol:@protocol(PSTypeConvertor)]);
    [PSDbKit addConvertor:convertor];
}

- (void)createPathIfNotExists{
    NSString *databasePath = [self.datasource stringByDeletingLastPathComponent];
    NSFileManager *manager = [NSFileManager new];
    
    if ([manager fileExistsAtPath:databasePath]) {
        return ;
    }else{
        [manager createDirectoryAtPath:databasePath
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];
    }
}

- (void)start{
    PSAssert(self.datasource.length, @"you must set up a database");
    PSAssert(_registedModel.count, @"you must register one model at lease");
    [PSDbConnection showSqls:self.showSql];
    
    //Auto create path
    [self createPathIfNotExists];
    
    PSDbConfig *config = [[PSDbConfig alloc] initWithName:self.configName datasource:self.datasource];
    config.containerFactory = self.containerFactory;
    
    [PSDbKit addModel:[PSTable class] toConfigMapping:config];
    [PSDbKit addModel:[PSColumn class] toConfigMapping:config];
    [PSDbKit addConfig:config];
    
    NSDictionary<NSString *, PSTable *> *tableConfig = [self buildTableConfig:config];
    BOOL result = [[PSDb use:config.name] tx:^BOOL(PSDb * db){
        for (Class model in _registedModel) {
            NSString *tableName = [model tableName];
            PSTable *tableStruct = [tableConfig objectForKey:tableName];
            
            if (!tableStruct) {
                //create table
                tableStruct = [PSTable buildTableWithModel:model];
                PSAssert([db updateWithSql:[PSSqlBuilder forCreate:tableStruct]], @"execute creation failed");
                PSAssert([db batchSqls:[model migrateForm:0 to:tableStruct.version]], @"execute migration failed");
                PSAssert([tableStruct save], @"save table info for %@ failed", NSStringFromClass(model));
            }else{
                //update table
                PSAssert(tableStruct.type == model, @"init PSDicRecord fail cause conflict between %@ and %@", NSStringFromClass(tableStruct.type), NSStringFromClass(model));
                PSTable *currentStruct = [PSTable buildTableWithModel:model];
                
                if (tableStruct.version < currentStruct.version) {
                    
                    NSArray<PSRecord *> *records = [db find:[NSString stringWithFormat:@"pragma table_info ('%@')", currentStruct.name]];
                    
                    NSMutableArray<NSString *> *existedColumns = [NSMutableArray new];
                    for (PSRecord *record in records) {
                        [existedColumns addObject:[[record valueForKey:@"name"] lowercaseString]];
                    }
                    
                    //find new columns
                    NSMutableArray<PSColumn *> *newColumns = [NSMutableArray new];
                    for (PSColumn *column in currentStruct.cols) {
                        if (![tableStruct.cols containsObject:column] && ![existedColumns containsObject:column.name.lowercaseString]) {
                            [newColumns addObject:column];
                        }
                    }
                    
                    //build add column sqls
                    NSMutableArray<PSSql *> *addSqls = [NSMutableArray new];
                    for (PSColumn *column in newColumns) {
                        [addSqls addObject:[PSSqlBuilder forAddColumn:column toTable:currentStruct]];
                    }
                    
                    PSAssert([db batchSqls:addSqls], @"add columns failed");
                    
                    //execute migration
                    PSAssert([db batchSqls:[model migrateForm:tableStruct.version to:currentStruct.version]], @"execute migration failed");
                    
                    //add new column structure
                    currentStruct.ID = tableStruct.ID;
                    PSAssert([currentStruct updateAll], @"update table structure failed");
                    tableStruct = currentStruct;
                }
            }
            [PSDbKit addModel:model toConfigMapping:config];
            [PSDbKit addModel:model toTableMapping:tableStruct];
        }
        return YES;
    }];
    PSAssert(result, @"Initialize failed.");
}

- (NSDictionary<NSString *, PSTable *> *)buildTableConfig:(PSDbConfig *)config{
    // initialize
    PSDb *db = [PSDb use:config.name];
    
    PSTable *configTable = [PSTable buildTableWithModel:PSTable.class];
    [PSDbKit addModel:PSTable.class toTableMapping:configTable];
    PSAssert([db updateWithSql:[PSSqlBuilder forCreate:configTable]], @"unable to create config table");
    
    NSMutableDictionary<NSString *, PSTable *> *result = [NSMutableDictionary new];
    for (PSTable *table in [[PSTable dao] findAll]) {
        [result setObject:table forKey:[table name]];
    }
    return result;
}
@end
