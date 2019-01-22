//
//  Photo+Flickr.m
//  PhotomaniaForiOS
//
//  Created by JihoonPark on 28/11/2018.
//  Copyright © 2018 JihoonPark. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Photographer+Create.h"

#define ENTITY_NAME_PHOTO @"Photo"

@implementation Photo (Flickr)
+(void)loadPhotosFromFlickrArray:(NSArray *)photos intoManagedObjectContext:(NSManagedObjectContext *)context{
    for(NSDictionary * photo in photos){
        [self photoWithFlickrInfo:photo inManageObjectContext:context];
    }
}
+(Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary inManageObjectContext:(NSManagedObjectContext *)context{
    Photo * photo = nil;
    
    NSString *unique = photoDictionary[FLICKR_PHOTO_ID];
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:ENTITY_NAME_PHOTO];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@" , unique];
    
    NSError * error;
    NSArray * matches = [context executeFetchRequest:request error:&error];
    
    if( !matches || error || ([matches count] > 1)){
        //HANDLE ERROR
    }
    else if([matches count]){
        photo = [matches firstObject];
    }
    else{
        photo = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME_PHOTO inManagedObjectContext:context];
        photo.unique = unique;
        photo.title = [photoDictionary valueForKey:FLICKR_PHOTO_TITLE];
        photo.subtitle = [photoDictionary valueForKey:FLICKR_PHOTO_DESCRIPTION];
        photo.imageURL = [[FlickrFetcher URLforPhoto:photoDictionary format:(FlickrPhotoFormatLarge)]absoluteString];
        NSString * photographerName = [photoDictionary valueForKey:FLICKR_PHOTO_OWNER];
        photo.whoTook = [Photographer photographerWithName:photographerName inManagedObjectContext:context];
    }
    return photo;
}
@end
