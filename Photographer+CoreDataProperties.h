//
//  Photographer+CoreDataProperties.h
//  PhotomaniaForiOS
//
//  Created by JihoonPark on 28/11/2018.
//  Copyright © 2018 JihoonPark. All rights reserved.
//
//

#import "Photographer+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Photographer (CoreDataProperties)

+ (NSFetchRequest<Photographer *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) Photo *photos;

@end

NS_ASSUME_NONNULL_END
