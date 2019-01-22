//
//  Photographer+CoreDataProperties.m
//  PhotomaniaForiOS
//
//  Created by JihoonPark on 28/11/2018.
//  Copyright © 2018 JihoonPark. All rights reserved.
//
//

#import "Photographer+CoreDataProperties.h"

@implementation Photographer (CoreDataProperties)

+ (NSFetchRequest<Photographer *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
}

@dynamic name;
@dynamic photos;

@end
