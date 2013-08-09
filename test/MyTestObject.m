//
//  MyTestObject.m
//  test
//
//  Created by Michael Timbrook on 8/9/13.
//  Copyright (c) 2013 Michael Timbrook. All rights reserved.
//
//  This is an example application of how to use core data in AccessLecture
//  this is for referance to show some of the ways core data can be used.
//

#import "MyTestObject.h"
#import "AppDelegate.h"
#import "Favorites.h"

@implementation MyTestObject

- (void)run
{
    printf("----------------------------------------------\n");
    
    // First thing you need to do to use core data is get the managed object
    // context, it lives as a singleton in to AppDelegate
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = app.managedObjectContext;
    
    // We will start by writing data to the database, so later we can get it back
    // Favorites is a subclass of NSManagedObject, it provides and interface for
    // interacting with the database attributes. We'll set those now.
    
    Favorites *newFavorite = [NSEntityDescription insertNewObjectForEntityForName:@"Favorites" inManagedObjectContext:moc];
    
    [newFavorite setName:@"My Server Favorite"];
    [newFavorite setHostname:@"michaeltimbrook.com"];
    
    // We can now commit our changes to the database and check for errors
    
    NSError *err;
    [moc save:&err];
    
    if (!err) {
        NSLog(@"Hurray! We saved some data");
        // ARC will handle cleaning up our entity but let's help it along
        newFavorite = nil;
    }
    
    // Just do it a few more times...
    [self populateDatabaseWithContext:moc];
    
    // Now let's get that object back!
    // This time we need to create a template entity for core data to add to
    // We don't need to specify this one as a favorite because its not the object
    // we get back from core data. We use it in our request to describe what we
    // are querying
    
    NSEntityDescription *myDescription = [NSEntityDescription entityForName:@"Favorites" inManagedObjectContext:moc];
    NSFetchRequest *request = [NSFetchRequest new];
    [request setEntity:myDescription];
    
    // Now that are request is set up, let's tell it what we're looking for and
    // how we want our data back.
    // Core data use NSPredicates to handle querys. Predicates can be anything
    // from a sql like string to complex cocoa discriptors. For more look at
    // NSPredicate.
    
    NSPredicate *query = [NSPredicate predicateWithFormat:@"name like 'My Server Favorite*'"]; // This is everything
    NSSortDescriptor *sortBy = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]; // Queries can be sorted
    
    [request setPredicate:query];
    [request setSortDescriptors:@[sortBy]];
    
    // Time to acctually get the data
    
    NSArray *results = [moc executeFetchRequest:request error:&err];
    if (!err) {
        NSLog(@"Data!");
        for (Favorites *fav in results) {
            NSLog(@"%@ -> %@", fav.name, fav.hostname);
        }
    }
    
    printf("----------------------------------------------\n");
}

- (void)populateDatabaseWithContext:(NSManagedObjectContext *)moc
{
    for (int i = 1; i < 40; i++) {
        Favorites *newFavorite = [NSEntityDescription insertNewObjectForEntityForName:@"Favorites" inManagedObjectContext:moc];
        [newFavorite setName:[NSString stringWithFormat:@"My Server Favorite %d", i]];
        [newFavorite setHostname:@"michaeltimbrook.com"];
    }
    [moc save:nil];
}

@end
