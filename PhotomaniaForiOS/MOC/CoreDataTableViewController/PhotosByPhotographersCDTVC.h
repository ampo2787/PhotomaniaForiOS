//
//  PhotosByPhotographersCDTVC.h
//  PhotomaniaForiOS
//
//  Created by JihoonPark on 28/11/2018.
//  Copyright © 2018 JihoonPark. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Photographer+CoreDataProperties.h"


@interface PhotosByPhotographersCDTVC : CoreDataTableViewController

@property (nonatomic, strong) Photographer * photographer;
@end

