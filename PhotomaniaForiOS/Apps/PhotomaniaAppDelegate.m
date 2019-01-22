//
//  AppDelegate.m
//  PhotomaniaForiOS
//
//  Created by JihoonPark on 28/11/2018.
//  Copyright © 2018 JihoonPark. All rights reserved.
//

#import "PhotomaniaAppDelegate.h"
#import "PhotomaniaAppDelegate+MOC.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "PhotoDatabaseAvailability.h"

@interface PhotomaniaAppDelegate () <NSURLSessionDownloadDelegate, UISplitViewControllerDelegate>
@property (copy, nonatomic) void (^ flickrDownloadBackgroundURLSessionCompleteHandler)(void);
@property (strong, nonatomic) NSURLSession * flickrDownloadSession;
@property (strong, nonatomic) NSTimer * flickrForegroundFetchTimer;
@property (strong, nonatomic) NSManagedObjectContext * photoDatabaseContext;

@end

#define FLICKR_FETCH @"Flickr Just Upload Fetch"

@implementation PhotomaniaAppDelegate

- (void)startFlickrFetch{
    NSLog(@"startFlickrFetch");
    [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        if(![downloadTasks count]){
            NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
            task.taskDescription = FLICKR_FETCH;
            [task resume];
        }
        else{
            for (NSURLSessionDownloadTask *task in downloadTasks) [task resume];
        }
    }];
}

-(void)startFlickrFetch:(NSTimer *)timer{
    [self startFlickrFetch];
}

-(NSURLSession *)flickrDownloadSession{
    if(!_flickrDownloadSession){
        static dispatch_once_t onceToken;
        dispatch_once (&onceToken, ^{
            NSURLSessionConfiguration * urlSessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:FLICKR_FETCH];
            urlSessionConfig.allowsCellularAccess = NO;
            self->_flickrDownloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        });
    }
    return _flickrDownloadSession;
}

-(NSArray *)flickrPhotoAtURL:(NSURL *)url{
    NSDictionary * flickrPropertyList;
    NSData * flickrJSONData = [NSData dataWithContentsOfURL:url];
    if(flickrJSONData){
        flickrPropertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONData options:0 error:NULL];
    }
    return [[flickrPropertyList valueForKey:@"photos"] valueForKey:@"photo"];
}

-(void)setPhotoDatabaseContext:(NSManagedObjectContext *)photoDatabaseContext{
    _photoDatabaseContext = photoDatabaseContext;
    NSDictionary * userInfo = self.photoDatabaseContext ? @{
                                                            PhotoDatabaseAvailabilityContext : self.photoDatabaseContext
                                                            } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDatabaseAvailabilityNotification object:self userInfo:userInfo];
}

#pragma mark - NSURLSessionDownloadDelegate
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    if([downloadTask.taskDescription isEqualToString:FLICKR_FETCH]){
        NSManagedObjectContext *context = self.photoDatabaseContext;
        if(context){
            NSArray *photos = [self flickrPhotoAtURL:location];
            [context performBlock:^{
                [Photo loadPhotosFromFlickrArray:photos intoManagedObjectContext:context];
                [context save:NULL];
            }];
        }
        else{
            [self flickrDownloadTasksMightBeComplete];
        }
    }
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
}

-(void)flickrDownloadTasksMightBeComplete{
    if(self.flickrDownloadBackgroundURLSessionCompleteHandler){
        [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
            if(![downloadTasks count]) {
                void (^completionHandler)(void) = self.flickrDownloadBackgroundURLSessionCompleteHandler;
                self.flickrDownloadBackgroundURLSessionCompleteHandler = nil;
                if(completionHandler){
                    completionHandler();
                }
            }
        }];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    if(![[splitViewController class] isEqual:UINavigationController.class]){
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
        splitViewController.delegate=self;
    }
    self.photoDatabaseContext = [self createMainQueueManagedObjectContext];
    [self startFlickrFetch];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

-(BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(nonnull UIViewController *)secondaryViewController ontoPrimaryViewController:(nonnull UIViewController *)primaryViewController{
    //splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryOverlay;
    return YES;
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"PhotomaniaForiOS"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
