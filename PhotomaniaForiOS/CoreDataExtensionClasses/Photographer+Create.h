//
//  Photographer+Create.h
//  PhotomaniaForiOS
//
//  Created by JihoonPark on 28/11/2018.
//  Copyright © 2018 JihoonPark. All rights reserved.
//

#include "Photographer+CoreDataProperties.h"

@interface Photographer (Create)
+(Photographer *)photographerWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;
@end

