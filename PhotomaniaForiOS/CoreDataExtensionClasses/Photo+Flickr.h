//
//  Photo+Flickr.h
//  PhotomaniaForiOS
//
//  Created by JihoonPark on 28/11/2018.
//  Copyright © 2018 JihoonPark. All rights reserved.
//

#import "Photo+CoreDataClass.h"

@interface Photo (Flickr)
+(Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary inManageObjectContext:(NSManagedObjectContext *)context;
+(void)loadPhotosFromFlickrArray:(NSArray *)photos intoManagedObjectContext:(NSManagedObjectContext *)context;
@end
