//
//  PhotosByPhotographersCDTVC.m
//  PhotomaniaForiOS
//
//  Created by JihoonPark on 28/11/2018.
//  Copyright © 2018 JihoonPark. All rights reserved.
//

#import "PhotosByPhotographersCDTVC.h"
#import "ImageViewController.h"
#import "Photo+CoreDataProperties.h"

@interface PhotosByPhotographersCDTVC()

@end

@implementation PhotosByPhotographersCDTVC

- (void)viewDidload{
    [super viewDidLoad];
    self.debug = YES;
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (void)setPhotographer:(Photographer *)photographer{
    _photographer = photographer;
    self.title = photographer.name;
    [self setupFetchedResultsController];
}

- (void)setupFetchedResultsController{
    NSManagedObjectContext * context = self.photographer.managedObjectContext;
    if(context) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"whoTook = %@", self.photographer];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    }
    else{
        self.fetchedResultsController = nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Photo Cell"];
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell.textLabel setText:photo.title];
    [cell.detailTextLabel setText:photo.subtitle];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if([detailVC isKindOfClass:[UINavigationController class]]){
        detailVC = [((UINavigationController *)detailVC).viewControllers firstObject];
        [self prepareViewController:detailVC forSegue:nil fromIndexPath:indexPath];
    }
}

#pragma mark - Navigation
-(void)prepareViewController:(id)vc forSegue:(NSString *)segueIdentifier fromIndexPath:(NSIndexPath *)indexPath{
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if([vc isKindOfClass:[UINavigationController class]]){
        vc = [((UINavigationController *)vc).viewControllers firstObject];
    }
    
    if([vc isKindOfClass:[ImageViewController class]]){
        ImageViewController *ivc = (ImageViewController *)vc;
        ivc.imageURL = [NSURL URLWithString:photo.imageURL];
        ivc.title = photo.title;
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
