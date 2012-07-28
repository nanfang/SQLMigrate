//
//  SQLMigrate.m
//  SQLMigrate
//
//  Created by nanfang on 7/21/12.
//  Copyright (c) 2012 lvtuxiongdi.com. All rights reserved.
//

#import "SQLMigrate.h"
#import "DBUtils.h"
#import "NSString+Ext.h"
static NSString * const MIGRATE_PATH = @"";
static NSString * const MIGRATE_EXT = @"migrate.sql";

@implementation SQLMigrate
+ (NSString*) fileName:(NSString*)filePath
{
    return [filePath substringFromIndex:[filePath lastIndexOf:@"/"]+1];  
}

+ (int) versionOfFile:(NSString*)filePath
{
    NSString *s = [self fileName:filePath]; 
    s = [s substringToIndex:[s indexOf:@"_"]];
    return [s intValue];
}

+ (void)migrate:(FMDatabase*)db
{
    [db beginTransaction];
    int current_version = [DBUtils dbVersion:db];
    int new_version= current_version;
    NSArray* sqls = [[NSBundle mainBundle] pathsForResourcesOfType:MIGRATE_EXT inDirectory:MIGRATE_PATH];
    [sqls sortedArrayUsingComparator:^(NSString *s1, NSString *s2){
        return [self versionOfFile:s1] - [self versionOfFile:s2];
    }];
    @try{
        for(NSString* sql in sqls){
            int version = [self versionOfFile:sql];
            if (version > current_version) {
                NSArray* clauses =[[NSString stringWithContentsOfFile:sql encoding:NSUTF8StringEncoding error:nil]componentsSeparatedByString:@";"];
                for(NSString *c in clauses){
                    NSString *clause = [c stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; 
                    if([clause isEqual:@""]){
                        continue;
                    }
                    if([db executeUpdate:clause]){
                        new_version = version;                
                    }else {
                        [NSException raise:@"Fail to migrate" format:@"error to run %@", [self fileName:sql]];
                    }
                }
                NSLog(@"executed %@", [self fileName:sql]);
            }
        }
        if(new_version>current_version){
            [db executeUpdate:[NSString stringWithFormat:@"PRAGMA user_version=%d", new_version]];
            NSLog(@"db is updated to version=%d", [DBUtils dbVersion:db]);
        }else {
            NSLog(@"db is already up to date, version=%d", [DBUtils dbVersion:db]);
        }
        [db commit];
        NSLog(@"migrate done");
    }@catch(NSException *exception){
        NSLog(@"%@: %@", [exception name], [exception reason]);
//        [db rollback];
        NSLog(@"migrate abort");
    }


}

@end
