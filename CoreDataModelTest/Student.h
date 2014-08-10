//
//  Student.h
//  CoreDataModelTest
//
//  Created by 姚卓禹 on 14-8-10.
//  Copyright (c) 2014年 姚卓禹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Techer;

@interface Student : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * home;
@property (nonatomic, retain) Techer *techer;

@end
