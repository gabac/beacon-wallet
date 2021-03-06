//
//  BWReceiptTableViewController.m
//  beacon-wallet-iphone
//
//  Created by Cyril Gabathuler on 12.05.14.
//  Copyright (c) 2014 Bahnhofstrasse24. All rights reserved.
//

#import "BWReceiptTableViewController.h"
#import "BWProduct.h"
#import "BWProductTableViewController.h"

@interface BWReceiptTableViewController ()

@property NSMutableArray *receiptDataItems;
@property NSArray *products;

@end

@implementation BWReceiptTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Receipt";
        self.tabBarItem.image = [UIImage imageNamed:@"ReceiptIcon"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.bottomLayoutGuide.length, 0);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex: 0];
    NSString* docFile = [docDir stringByAppendingPathComponent: @"Storage"];
    
    self.receiptDataItems = [NSKeyedUnarchiver unarchiveObjectWithFile:docFile];
    self.receiptDataItems = [[self.receiptDataItems reverseObjectEnumerator] allObjects];
    
    NSLog(@"%lu", [self.receiptDataItems count]);
    
    NSString* docFileProd = [docDir stringByAppendingPathComponent: @"Products"];
    
    self.products = [NSKeyedUnarchiver unarchiveObjectWithFile:docFileProd];
    
    [self.products enumerateObjectsUsingBlock:^(BWProduct *obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"barcode: %@", obj.barcodes);
    }];
    
    [self.tableView reloadData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.receiptDataItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    BWReceiptDataItem *dataItem = [self.receiptDataItems objectAtIndex:indexPath.row];
    
    if(dataItem.product) {
        cell.textLabel.text = dataItem.product.name;
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"No product found for: %@", dataItem.barcode];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BWProductTableViewController *productTableViewController = [[BWProductTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    //set product
    BWReceiptDataItem *dataItem = [self.receiptDataItems objectAtIndex:indexPath.row];
    
    if(dataItem.product) {
        productTableViewController.product = dataItem.product;
        [self.navigationController pushViewController:productTableViewController animated:YES];
    } else {
        //could do it with willSelectRow
        return;
    }
    
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.receiptDataItems removeObjectAtIndex:indexPath.row];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex: 0];
        NSString* docFile = [docDir stringByAppendingPathComponent: @"Storage"];
        
        [NSKeyedArchiver archiveRootObject:self.receiptDataItems toFile:docFile];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
