//
//  SQLMigrate.m
//  SQLMigrate
//
//  Created by nanfang on 7/21/12.
//  Copyright (c) 2012 lvtuxiongdi.com. All rights reserved.
//

#import "SQLMigrate.h"
#import "DBUtils.h"

@implementation SQLMigrate

+ (void)migrate:(FMDatabase*)db
{
    int version = [DBUtils dbVersion:db];
    NSLog(@"current db version=%d", version);
    // TODO migrate from version
    
    // TODO update version
    int new_version= version;
    NSArray* sqls = [[NSBundle mainBundle] pathsForResourcesOfType:@"sql" inDirectory:@""];
    for(NSString* sql in sqls){
        NSLog(@"%@", sql);
    }
        
    if(new_version>version){
        [db executeUpdate:[NSString stringWithFormat:@"PRAGMA user_version=%d", new_version]];
        NSLog(@"updated to version=%d", [DBUtils dbVersion:db]);
    }
}


@end
