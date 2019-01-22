//
//  Photographer+Create.m
//  PhotomaniaForiOS
//
//  Created by JihoonPark on 28/11/2018.
//  Copyright © 2018 JihoonPark. All rights reserved.
//

#import "Photographer+Create.h"
#define ENTITY_NAME_PHOTOGRAPHER @"Photographer"

@implementation Photographer (Create)
+(Photographer *)photographerWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context{
    Photographer *photographer = nil;
    
    if([name length]){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:ENTITY_NAME_PHOTOGRAPHER];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        
        NSError *errer;
        NSArray *matches = [context executeFetchRequest:request error:&errer];
        if(!matches || [matches count] > 1){
            
        }
        else if(![matches count]){
            photographer = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME_PHOTOGRAPHER inManagedObjectContext:context];
            photographer.name = name;
        }
        else{
            photographer = [matches lastObject];
        }
    }
    return photographer;
}

@end
