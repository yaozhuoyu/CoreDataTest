//
//  AppDelegate.m
//  CoreDataModelTest
//
//  Created by 姚卓禹 on 14-6-20.
//  Copyright (c) 2014年 姚卓禹. All rights reserved.
//

#import "AppDelegate.h"
#import "Techer.h"
#import "Student.h"
#import "TestUtil.h"

@implementation AppDelegate{
    Techer *atecher;
    Student *astudent;
    TestUtil *testUtil_;
    
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //[self createData];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:self.managedObjectContext];
    
    //[self testCoreData];
    //[self importLargeDatas];
    
    //[self testManagedObjectContextInsertObjectMethod];
    //[self childContextSaveLargeDatas];
    
    testUtil_ = [[TestUtil alloc] init];
    testUtil_.appDelegate = self;
    [testUtil_ onTest];
    
    
    UIViewController *rrot = [[UIViewController alloc] init];
    self.window.rootViewController = rrot;
    return YES;
}




- (void)childContextSaveLargeDatas {
    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [childContext setParentContext:self.managedObjectContext];
    
    NSLog(@"begin import");
    for (NSUInteger index = 0; index < 5000; index++) {
        Techer *tt = [NSEntityDescription insertNewObjectForEntityForName:@"Techer" inManagedObjectContext:childContext];
        tt.name = [NSString stringWithFormat:@"techer name :(%d)", index];
        
        
        for (NSUInteger jndex = 0; jndex < 50; jndex++) {
            Student *student = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:childContext];
            student.name = [NSString stringWithFormat:@"student name :(%d)", jndex];
            [tt addStudentsObject:student];
        }
    }
    NSLog(@"end import");
    
    [childContext save:NULL];
    NSLog(@"save child context");
    [self saveContext];
    NSLog(@"save root context");
    [self.managedObjectContext reset];
    
    
}

- (void)testManagedObjectContextInsertObjectMethod {
    Techer *techer = [NSEntityDescription insertNewObjectForEntityForName:@"Techer" inManagedObjectContext:self.managedObjectContext];
    techer.name = [NSString stringWithFormat:@"techer name insert"];
    atecher = techer;
    
    Student *student = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:self.managedObjectContext];
    student.name = [NSString stringWithFormat:@"student name insert"];
    [techer addStudentsObject:student];
    astudent = student;
    
    NSLog(@"techer before save is fault %d , register count %d", [techer isFault], [[self.managedObjectContext registeredObjects] count]);
    [self saveContext];
    NSLog(@"techer after save is fault %d , register count %d", [techer isFault], [[self.managedObjectContext registeredObjects] count]);
    
    [self.managedObjectContext refreshObject:techer mergeChanges:NO];
    NSLog(@"techer after refreshObject is fault %d , register count %d", [techer isFault], [[self.managedObjectContext registeredObjects] count]);
    NSLog(@"student fault %d", [student isFault]);
}

- (void)importLargeDatas {
    NSLog(@"begin import  register count %d", [[self.managedObjectContext registeredObjects] count]);
    for (NSUInteger index = 0; index < 5000; index++) {
        Techer *tt = [NSEntityDescription insertNewObjectForEntityForName:@"Techer" inManagedObjectContext:self.managedObjectContext];
        tt.name = [NSString stringWithFormat:@"techer name :(%d)", index];
        
        
        for (NSUInteger jndex = 0; jndex < 50; jndex++) {
            Student *student = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:self.managedObjectContext];
            student.name = [NSString stringWithFormat:@"student name :(%d)", jndex];
            [tt addStudentsObject:student];
        }
    }
    NSLog(@"end import %d", [[self.managedObjectContext registeredObjects] count]);
    [self saveContext];
    NSLog(@"save import %d", [[self.managedObjectContext registeredObjects] count]);
    [self.managedObjectContext reset];
    NSLog(@"reset context %d", [[self.managedObjectContext registeredObjects] count]);
}


//- (void)objectDidChange:(NSNotification *)notification{
//    NSDictionary *dict = notification.userInfo;
//    NSLog(@"dict did change : %@", dict);
//}

- (void)createData {
    Student *student = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:self.managedObjectContext];
    student.name = @"yzy1";
    
    Student *student2 = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:self.managedObjectContext];
    student2.name = @"yzy2";
    
    Techer *tt = [NSEntityDescription insertNewObjectForEntityForName:@"Techer" inManagedObjectContext:self.managedObjectContext];
    tt.name = @"tttt";
    
    [tt addStudentsObject:student];
    student2.techer = tt;
    
    [self saveContext];
}

- (void)testCoreData {
    /*
    NSFetchRequest *existingFetch = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    //[existingFetch setReturnsObjectsAsFaults:NO];
    [existingFetch setRelationshipKeyPathsForPrefetching:@[@"techer"]];
    existingFetch.predicate = [NSPredicate predicateWithFormat:@"name == %@", @"yzy1"];
    NSArray *array = [self.managedObjectContext executeFetchRequest:existingFetch error:NULL];
    if ([array count] > 0) {
        Student *ss = [array firstObject];
        NSLog(@"ss  is Fault %d", [ss isFault]);
        NSLog(@" ss name %@", ss.name);
        NSLog(@"ss  is Fault %d", [ss isFault]);
        NSLog(@"ss techer is Fault  %d", [ss.techer isFault]);
        NSLog(@"ss techer  name  %@", ss.techer.name);
    }
    */
    //[self.managedObjectContext setStalenessInterval:0.0];
    NSFetchRequest *existingFetch = [NSFetchRequest fetchRequestWithEntityName:@"Techer"];
    //[existingFetch setRelationshipKeyPathsForPrefetching:@[@"students"]];
    existingFetch.predicate = [NSPredicate predicateWithFormat:@"name == %@", @"tttt"];
    NSArray *array = [self.managedObjectContext executeFetchRequest:existingFetch error:NULL];
    if ([array count] > 0) {
        Techer *tt = [array firstObject];
        NSLog(@"tt  is Fault %d", [tt isFault]);
        //NSLog(@"============tt students: %@", tt.students);
        NSLog(@"tt sname %@", tt.name);
        //Student *sss = [tt.students anyObject];
        tt.name = @"212121";
        [self.managedObjectContext processPendingChanges];
        NSLog(@"%@", [self.managedObjectContext updatedObjects]);
        //NSLog(@"tt s count %u", [tt.students count]);
        //NSLog(@"tt  is Fault %d", [tt isFault]);
        /////
        //Student *sss = [tt.students anyObject];
        //NSLog(@"!!!!!!!!!%@", sss.name);
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CoreDataModelTest" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CoreDataModelTest.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
