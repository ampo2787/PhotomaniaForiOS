//
//  PhotomaniaAppDelegate+MOC.h
//  Photomania
//


#import "PhotomaniaAppDelegate.h"

@interface PhotomaniaAppDelegate (MOC)

- (NSManagedObjectContext *)createMainQueueManagedObjectContext;

@end
