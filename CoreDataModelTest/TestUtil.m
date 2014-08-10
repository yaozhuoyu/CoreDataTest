//
//  TestUtil.m
//  CoreDataModelTest
//
//  Created by 姚卓禹 on 14-8-10.
//  Copyright (c) 2014年 姚卓禹. All rights reserved.
//

#import "TestUtil.h"
#import "Student.h"
#import "Techer.h"

@implementation TestUtil

- (void)onTest{
    //需要先导入数据
    [self createDataForMergePolicyTest];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        //[self testNoMergePolicyForTwoMocWithPsc];
        
        //[self testMergeByPropertyStoreTrumpMergePolicyForTwoMocWithPsc];
        
        //[self testMergeByPropertyObjectTrumpMergePolicyPolicyForTwoMocWithPsc];
        
        //[self testRollbackMergePolicyForTwoMocWithPsc];
        
        //[self testOverwriteMergePolicyForTwoMocWithPsc];
        
        [self testNoMergePolicyForTwoMocWithParentChild];
    });
    
}

//1.测试两个moc的冲突处理，连个moc分别连接psc, 默认的mergepolicy->NSErrorMergePolicy
- (void)testNoMergePolicyForTwoMocWithPsc{
    NSPersistentStoreCoordinator *coordinator = [self.appDelegate persistentStoreCoordinator];
    
    //创建两个moc
    NSManagedObjectContext *mangeObjectContext1 = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [mangeObjectContext1 performBlockAndWait:^{
        [mangeObjectContext1 setPersistentStoreCoordinator:coordinator];
    }];
    
    NSManagedObjectContext *mangeObjectContext2 = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [mangeObjectContext2 performBlockAndWait:^{
        [mangeObjectContext2 setPersistentStoreCoordinator:coordinator];
        [mangeObjectContext2 setMergePolicy:NSErrorMergePolicy]; //NSErrorMergePolicy 也是默认的mergepolicy
    }];
    
    
    //分别从两个moc中取出mo
    NSFetchRequest *techerFetch = [NSFetchRequest fetchRequestWithEntityName:@"Techer"];
    [techerFetch setFetchLimit:1];
    
    __block NSArray *techerArray1 = nil;
    [mangeObjectContext1 performBlockAndWait:^{
        techerArray1 = [mangeObjectContext1 executeFetchRequest:techerFetch error:NULL];
    }];
    
    Techer *techer1 = [techerArray1 firstObject];
    NSLog(@"techer1 %@, name(%@)",techer1, techer1.name);
    
    __block NSArray *techerArray2 = nil;
    [mangeObjectContext2 performBlockAndWait:^{
        techerArray2 = [mangeObjectContext2 executeFetchRequest:techerFetch error:NULL];
    }];
    
    Techer *techer2 = [techerArray2 firstObject];
    NSLog(@"techer2 %@name(%@)",techer2, techer2.name);
    
    
    //修改techer1的name，存储，在去修改techer2的name，save，看是否发生冲突
    
    [mangeObjectContext1 performBlockAndWait:^{
        NSError *error = nil;
        techer1.name = @"change 1";
        [mangeObjectContext1 save:&error];
        if (error) {
            NSLog(@"save techer1 error (%@)",error);
        }
    }];
    
    [mangeObjectContext2 performBlockAndWait:^{
        NSError *error = nil;
        techer2.name = @"change 2";
        [mangeObjectContext2 save:&error];
        if (error) {
            NSLog(@"save techer2 error (%@)",error);
        }
    }];
    
    /*
     在save mangeObjectContext2的时候发生冲突，error为：
     
     save techer2 error (Error Domain=NSCocoaErrorDomain Code=133020 "The operation couldn’t be completed. (Cocoa error 133020.)" UserInfo=0x99233b0 {conflictList=(
     "NSMergeConflict (0x9923350) for NSManagedObject (0x991f9b0) with objectID '0x8e25220 <x-coredata://5D6ED301-9FFA-42BB-8ABA-3078A908A240/Techer/p1>' with oldVersion = 1 and newVersion = 2 and old object snapshot = {\n    name = tttt;\n} and new cached row = {\n    name = \"change 1\";\n}"
     
     */
    
}

//2.测试两个moc的冲突处理，连个moc分别连接psc, 默认的mergepolicy->NSMergeByPropertyStoreTrumpMergePolicy
- (void)testMergeByPropertyStoreTrumpMergePolicyForTwoMocWithPsc{
    NSPersistentStoreCoordinator *coordinator = [self.appDelegate persistentStoreCoordinator];
    
    //创建两个moc
    NSManagedObjectContext *mangeObjectContext1 = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [mangeObjectContext1 performBlockAndWait:^{
        [mangeObjectContext1 setPersistentStoreCoordinator:coordinator];
    }];
    
    NSManagedObjectContext *mangeObjectContext2 = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [mangeObjectContext2 performBlockAndWait:^{
        [mangeObjectContext2 setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
        [mangeObjectContext2 setPersistentStoreCoordinator:coordinator];
    }];
    
    
    //分别从两个moc中取出mo
    NSFetchRequest *techerFetch = [NSFetchRequest fetchRequestWithEntityName:@"Techer"];
    [techerFetch setFetchLimit:1];
    
    __block NSArray *techerArray1 = nil;
    [mangeObjectContext1 performBlockAndWait:^{
        techerArray1 = [mangeObjectContext1 executeFetchRequest:techerFetch error:NULL];
    }];
    
    Techer *techer1 = [techerArray1 firstObject];
    NSLog(@"techer1 %@, name(%@)",techer1, techer1.name);
    
    __block NSArray *techerArray2 = nil;
    [mangeObjectContext2 performBlockAndWait:^{
        techerArray2 = [mangeObjectContext2 executeFetchRequest:techerFetch error:NULL];
    }];
    
    Techer *techer2 = [techerArray2 firstObject];
    NSLog(@"techer2 %@name(%@)",techer2, techer2.name);
    
    
    //修改techer1的name，存储，在去修改techer2的name，save，看是否发生冲突
    
    [mangeObjectContext1 performBlockAndWait:^{
        NSError *error = nil;
        //techer1.name = @"change 1";
        [mangeObjectContext1 deleteObject:techer1];
        [mangeObjectContext1 save:&error];
        if (error) {
            NSLog(@"save techer1 error (%@)",error);
        }
    }];
    
    [mangeObjectContext2 performBlockAndWait:^{
        NSError *error = nil;
        techer2.name = @"change 2";
        [mangeObjectContext2 save:&error];
        if (error) {
            NSLog(@"save techer2 error (%@)",error);
        }
    }];
    
    /*
     没有出错，但是因为合并策略为NSMergeByPropertyStoreTrumpMergePolicy，所以techer的name没有设置为change 2，还是store中的change 1
     */
    
}

//3.测试两个moc的冲突处理，连个moc分别连接psc, 默认的mergepolicy->NSMergeByPropertyObjectTrumpMergePolicy
- (void)testMergeByPropertyObjectTrumpMergePolicyPolicyForTwoMocWithPsc{
    NSPersistentStoreCoordinator *coordinator = [self.appDelegate persistentStoreCoordinator];
    
    //创建两个moc
    NSManagedObjectContext *mangeObjectContext1 = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [mangeObjectContext1 performBlockAndWait:^{
        [mangeObjectContext1 setPersistentStoreCoordinator:coordinator];
    }];
    
    NSManagedObjectContext *mangeObjectContext2 = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [mangeObjectContext2 performBlockAndWait:^{
        [mangeObjectContext2 setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        [mangeObjectContext2 setPersistentStoreCoordinator:coordinator];
    }];
    
    
    //分别从两个moc中取出mo
    NSFetchRequest *techerFetch = [NSFetchRequest fetchRequestWithEntityName:@"Techer"];
    [techerFetch setFetchLimit:1];
    
    __block NSArray *techerArray1 = nil;
    [mangeObjectContext1 performBlockAndWait:^{
        techerArray1 = [mangeObjectContext1 executeFetchRequest:techerFetch error:NULL];
    }];
    
    Techer *techer1 = [techerArray1 firstObject];
    NSLog(@"techer1 %@, name(%@)",techer1, techer1.name);
    
    __block NSArray *techerArray2 = nil;
    [mangeObjectContext2 performBlockAndWait:^{
        techerArray2 = [mangeObjectContext2 executeFetchRequest:techerFetch error:NULL];
    }];
    
    Techer *techer2 = [techerArray2 firstObject];
    NSLog(@"techer2 %@name(%@)",techer2, techer2.name);
    
    
    //修改techer1的name，存储，在去修改techer2的name，save，看是否发生冲突
    
    [mangeObjectContext1 performBlockAndWait:^{
        NSError *error = nil;
        techer1.name = @"change 1";
        [mangeObjectContext1 save:&error];
        if (error) {
            NSLog(@"save techer1 error (%@)",error);
        }
    }];
    
    [mangeObjectContext2 performBlockAndWait:^{
        NSError *error = nil;
        techer2.name = @"change 2";
        [mangeObjectContext2 save:&error];
        if (error) {
            NSLog(@"save techer2 error (%@)",error);
        }
    }];
    
    /*
     没有出错，但是因为合并策略为NSMergeByPropertyObjectTrumpMergePolicy，所以techer的name设置为change 2，以内存中的为准
     */
    
}

//4.测试两个moc的冲突处理，连个moc分别连接psc, 默认的mergepolicy->NSRollbackMergePolicy
- (void)testRollbackMergePolicyForTwoMocWithPsc{
    NSPersistentStoreCoordinator *coordinator = [self.appDelegate persistentStoreCoordinator];
    
    //创建两个moc
    NSManagedObjectContext *mangeObjectContext1 = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [mangeObjectContext1 performBlockAndWait:^{
        [mangeObjectContext1 setPersistentStoreCoordinator:coordinator];
    }];
    
    NSManagedObjectContext *mangeObjectContext2 = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [mangeObjectContext2 performBlockAndWait:^{
        [mangeObjectContext2 setMergePolicy:NSRollbackMergePolicy];
        [mangeObjectContext2 setPersistentStoreCoordinator:coordinator];
    }];
    
    
    //分别从两个moc中取出mo
    NSFetchRequest *studentFetch = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [studentFetch setSortDescriptors:@[sortDescriptor]];
    [studentFetch setFetchLimit:2];
    
    __block NSArray *studentArray1 = nil;
    [mangeObjectContext1 performBlockAndWait:^{
        studentArray1 = [mangeObjectContext1 executeFetchRequest:studentFetch error:NULL];
    }];
    
    for (int i = 0; i < [studentArray1 count]; i++) {
        Student *student = [studentArray1 objectAtIndex:i];
        NSLog(@"moc1 student %@, name(%@)",student, student.name);
    }
    
    
    __block NSArray *studentArray2 = nil;
    [mangeObjectContext2 performBlockAndWait:^{
        studentArray2 = [mangeObjectContext2 executeFetchRequest:studentFetch error:NULL];
    }];
    
    for (int i = 0; i < [studentArray2 count]; i++) {
        Student *student = [studentArray2 objectAtIndex:i];
        NSLog(@"moc2 student %@, name(%@)",student, student.name);
    }
    
    
    //修改studentArray1的name，存储，在去修改studentArray2的name，save，看是否发生冲突
    
    [mangeObjectContext1 performBlockAndWait:^{
        NSError *error = nil;
        //只修改数组中的第一个student的值
        Student *stu = [studentArray1 firstObject];
        stu.name = @"change name1";
        
        [mangeObjectContext1 save:&error];
        if (error) {
            NSLog(@"save techer1 error (%@)",error);
        }
    }];
    
    [mangeObjectContext2 performBlockAndWait:^{
        NSError *error = nil;
        //修改两个值
        Student *stu = [studentArray2 firstObject];
        stu.name = @"change name2";
        stu.home = @"change home2";
        

        
        [mangeObjectContext2 save:&error];
        if (error) {
            NSLog(@"save techer2 error (%@)",error);
        }
    }];
    
    /*
     NSRollbackMergePolicy
     会将对象整个状态回滚，在上面的例子中，虽然mangeObjectContext1中stu的home属性没有改变，但是因为mangeObjectContext2合并的时候发生冲突，冲突的策略是回滚，所以stu.home = @"change home2"也不会被保存。
     最后的结果为name = change name1, home = beijing。
     
     如果上面的例子中合并策略是NSMergeByPropertyStoreTrumpMergePolicy,则最后mangeObjectContext2中stu的home属性会保存，最后为  name = change name1, home = change home2。
     
     */
    
}

//5.测试两个moc的冲突处理，连个moc分别连接psc, 默认的mergepolicy->NSOverwriteMergePolicy
- (void)testOverwriteMergePolicyForTwoMocWithPsc{
    NSPersistentStoreCoordinator *coordinator = [self.appDelegate persistentStoreCoordinator];
    
    //创建两个moc
    NSManagedObjectContext *mangeObjectContext1 = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [mangeObjectContext1 performBlockAndWait:^{
        [mangeObjectContext1 setPersistentStoreCoordinator:coordinator];
    }];
    
    NSManagedObjectContext *mangeObjectContext2 = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [mangeObjectContext2 performBlockAndWait:^{
        [mangeObjectContext2 setMergePolicy:NSOverwriteMergePolicy];
        [mangeObjectContext2 setPersistentStoreCoordinator:coordinator];
    }];
    
    
    //分别从两个moc中取出mo
    NSFetchRequest *studentFetch = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [studentFetch setSortDescriptors:@[sortDescriptor]];
    [studentFetch setFetchLimit:2];
    
    __block NSArray *studentArray1 = nil;
    [mangeObjectContext1 performBlockAndWait:^{
        studentArray1 = [mangeObjectContext1 executeFetchRequest:studentFetch error:NULL];
    }];
    
    for (int i = 0; i < [studentArray1 count]; i++) {
        Student *student = [studentArray1 objectAtIndex:i];
        NSLog(@"moc1 student %@, name(%@)",student, student.name);
    }
    
    
    __block NSArray *studentArray2 = nil;
    [mangeObjectContext2 performBlockAndWait:^{
        studentArray2 = [mangeObjectContext2 executeFetchRequest:studentFetch error:NULL];
    }];
    
    for (int i = 0; i < [studentArray2 count]; i++) {
        Student *student = [studentArray2 objectAtIndex:i];
        NSLog(@"moc2 student %@, name(%@)",student, student.name);
    }
    
    
    //修改studentArray1的name，存储，在去修改studentArray2的name，save，看是否发生冲突
    
    [mangeObjectContext1 performBlockAndWait:^{
        NSError *error = nil;
        //只修改数组中的第一个student的值
        Student *stu = [studentArray1 firstObject];
        stu.name = @"change name1";
        stu.home = @"change home1";
        
        [mangeObjectContext1 save:&error];
        if (error) {
            NSLog(@"save techer1 error (%@)",error);
        }
    }];
    
    [mangeObjectContext2 performBlockAndWait:^{
        NSError *error = nil;
        //修改两个值
        Student *stu = [studentArray2 firstObject];
        stu.name = @"change name2";

        
        [mangeObjectContext2 save:&error];
        if (error) {
            NSLog(@"save techer2 error (%@)",error);
        }
    }];
    
    /*
     NSOverwriteMergePolicy
     会将对象整个状态覆盖重写，在上面的例子中，虽然mangeObjectContext1中stu的home属性修改了，但是因为mangeObjectContext2合并的时候name属性发生冲突，冲突的策略是覆盖重写，因为stu.home还是最初的值，所以有写到数据库重了。
     最后的结果为name = change name2, home = beijing。
     
     如果上面的例子中合并策略是NSMergeByPropertyObjectTrumpMergePolicy,则最后mangeObjectContext2中stu的home属性不会写入到数据库，因为没有发生改变，最后为  name = change name2, home = change home1。
     
     */
    
}

/*
 有一种情况需要注意，当一个context删除了一个对象，而另外一个对象修改了此对象，在保存的时候，如果想要放弃修改，选择删除，则合并策略选择Rollback，如果想要放弃删除，则选择Overwrite；选择propertyStoreTrump和propertyObjectTrump这两种策略和Rollback效果一样.
*/

//////////////////////////////////////////////////////////////////////////////////////

/*
 对于 child，parent 关系的moc，经测试不会存在合并冲突的问题。
 1.但是发现了一个有趣的但又想想比较合理的现象，当分别从child moc和parent moc中取出managedOjectID相同的两个对象（parentMo, childMo）之后，如果先修改parentMo的一个属性的值a，但是不save，这个时候再去修改childMo中对应的属性的值b，同时save，在save成功之后，parentMo对应的属性的值会自动变味b。
*/
- (void)testNoMergePolicyForTwoMocWithParentChild{
    NSPersistentStoreCoordinator *coordinator = [self.appDelegate persistentStoreCoordinator];
    
    //创建两个moc
    NSManagedObjectContext *parentMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [parentMOC performBlockAndWait:^{
        [parentMOC setPersistentStoreCoordinator:coordinator];
    }];
    
    NSManagedObjectContext *childMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [childMOC performBlockAndWait:^{
        [childMOC setParentContext:parentMOC];
    }];
    
    
    //分别从两个moc中取出mo
    NSFetchRequest *techerFetch = [NSFetchRequest fetchRequestWithEntityName:@"Techer"];
    [techerFetch setFetchLimit:1];
    
    __block NSArray *techerArray1 = nil;
    [parentMOC performBlockAndWait:^{
        techerArray1 = [parentMOC executeFetchRequest:techerFetch error:NULL];
    }];
    
    Techer *techer1 = [techerArray1 firstObject];
    NSLog(@"techer1 %@, name(%@)",techer1, techer1.name);
    
    __block NSArray *techerArray2 = nil;
    [childMOC performBlockAndWait:^{
        techerArray2 = [childMOC executeFetchRequest:techerFetch error:NULL];
    }];
    
    Techer *techer2 = [techerArray2 firstObject];
    NSLog(@"techer2 %@, name(%@)",techer2, techer2.name);
    

    [parentMOC performBlockAndWait:^{
        techer1.name = @"parent";
    }];
    
    NSLog(@"techer1 is delete %d", [techer1 isDeleted]);
    
    NSLog(@"parent techer name %@", techer1.name);
    [childMOC performBlockAndWait:^{
        NSError *error = nil;
        techer2.name = @"child";
        //[childMOC deleteObject:techer2];
        [childMOC save:&error];
        if (error) {
            NSLog(@"1. save techer2 error (%@)",error);
        }else{
            [parentMOC performBlockAndWait:^{
                NSError *error = nil;
                //techer1.name = @"parent";
                [parentMOC save:&error];
                if (error) {
                    NSLog(@"2. save techer2 error (%@)",error);
                }
            }];
        }
    }];
    NSLog(@"parent techer name %@", techer1.name);
    NSLog(@"techer1 is delete %d", [techer1 isDeleted]);
    
//    [parentMOC performBlockAndWait:^{
//        NSError *error = nil;
//        //techer1.name = @"change 1";
//        [parentMOC save:&error];
//        if (error) {
//            NSLog(@"save techer1 error (%@)",error);
//        }
//    }];
    NSLog(@"END");
}
  
//////////////////////////////////////////////////////////////////////////////////////


- (void)createDataForMergePolicyTest {
    Student *student = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:self.appDelegate.managedObjectContext];
    student.name = @"yzy1";
    student.age = @(20);
    student.home = @"beijing";
    
    Student *student2 = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:self.appDelegate.managedObjectContext];
    student2.name = @"yzy2";
    student2.age = @(21);
    student2.home = @"shanghai";
    
    Techer *tt = [NSEntityDescription insertNewObjectForEntityForName:@"Techer" inManagedObjectContext:self.appDelegate.managedObjectContext];
    tt.name = @"tttt";
    
    [tt addStudentsObject:student];
    student2.techer = tt;
    
    [self.appDelegate saveContext];
}


@end
