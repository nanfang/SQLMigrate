//
//  SQLMigrate.h
//  SQLMigrate
//
//  Created by nanfang on 7/21/12.
//  Copyright (c) 2012 lvtuxiongdi.com All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface SQLMigrate : NSObject
+ (void)migrate:(FMDatabase*)db;
@end
