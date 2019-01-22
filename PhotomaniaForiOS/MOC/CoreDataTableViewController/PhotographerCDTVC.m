//
//  PhotographerCDTVC.m
//  PhotomaniaForiOS
//
//  Created by JihoonPark on 28/11/2018.
//  Copyright © 2018 JihoonPark. All rights reserved.
//

#import "PhotographerCDTVC.h"
#import "Photographer+CoreDataProperties.h"
#import "PhotosByPhotographersCDTVC.h"
#import "PhotoDatabaseAvailability.h"

@interface PhotographerCDTVC()

@end

@implementation PhotographerCDTVC

-(void)awakeFromNib{
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        self.managedObjectContext = [note.userInfo objectForKey:PhotoDatabaseAvailabilityContext];
    }];
    self.debug = YES;
}

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext{
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)]];
    request.fetchLimit = 100;
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Photographer Cell"];
    Photographer * photographer = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell.textLabel setText:photographer.name];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if([detailVC isKindOfClass:[UINavigationController class]]){
        detailVC = [((UINavigationController *)detailVC).viewControllers firstObject];
        [self prepareViewController:detailVC forSegue:nil fromIndexPath:indexPath];
    }
}

#pragma mark - Navigation
-(void)prepareViewController:(id)vc forSegue:(NSString *)segueIdentifier fromIndexPath:(NSIndexPath *)indexPath{
    Photographer * photographer = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if([vc isKindOfClass:[PhotosByPhotographersCDTVC class]]){
        if(![segueIdentifier length] || [segueIdentifier isEqualToString:@"Show Photos by Photographer"]){
            PhotosByPhotographersCDTVC *pbpcdtvc = (PhotosByPhotographersCDTVC*)vc;
            pbpcdtvc.photographer = photographer;
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSIndexPath * indexPath = nil;
    if([sender isKindOfClass:[UITableViewCell class]]){
        indexPath = [self.tableView indexPathForCell:sender];
        [self prepareViewController:segue.destinationViewController forSegue:segue.identifier fromIndexPath:indexPath];
    }
}
@end
