//
//  OrderHistoryListVC.m
//  GiftGiv
//
//  Created by Srinivas G on 06/08/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "OrderHistoryListVC.h"

@implementation OrderHistoryListVC
@synthesize orderHistoryTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
#pragma mark - TableView Data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *cellIdentifier;
	cellIdentifier=[NSString stringWithFormat:@"Cell%d",indexPath.row];
	tableView.backgroundColor=[UIColor clearColor];
	OrderListCustomCell *cell = (OrderListCustomCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
	if (cell == nil) {
        
        cell=[[[NSBundle mainBundle]loadNibNamed:@"OrderListCustomCell" owner:self options:nil] lastObject];
		
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
                
        if(indexPath.row==0){
            cell.profileNameLbl.textColor=[UIColor colorWithRed:0 green:0.66 blue:0.67 alpha:1.0];
            cell.orderStatusLbl.text=@"Request Sent";
            cell.orderDateLbl.text=@"August 2nd";
            
        }
        else if(indexPath.row==1){
            cell.profileNameLbl.text=@"Viola Carter";
            cell.profileNameLbl.textColor=[UIColor colorWithRed:0 green:0.66 blue:0.67 alpha:1.0];
            
            cell.orderStatusLbl.text=@"Pending";
            cell.orderDateLbl.text=@"July 30th";
        }
        else if(indexPath.row==2){
            cell.profileNameLbl.text=@"Max Hollaway";
            cell.profileNameLbl.textColor=[UIColor blackColor];
            cell.orderStatusLbl.text=@"Complete!";
            cell.orderDateLbl.text=@"July 23rd";
        }
        
        //Dynamic[fit] label width respected to the size of the text
        CGSize status_maxSize = CGSizeMake(113, 21);
        CGSize status_new_size=[cell.orderStatusLbl.text sizeWithFont:cell.orderStatusLbl.font constrainedToSize:status_maxSize lineBreakMode:UILineBreakModeTailTruncation];
        cell.orderStatusLbl.frame=CGRectMake(60, 29, status_new_size.width, 21);
        
        CGSize orderDate_maxSize = CGSizeMake(90, 21);
        CGSize orderDate_newSize = [cell.orderDateLbl.text sizeWithFont:cell.orderDateLbl.font constrainedToSize:orderDate_maxSize lineBreakMode:UILineBreakModeTailTruncation];
        
        cell.orderDateLbl.frame= CGRectMake(cell.orderStatusLbl.frame.origin.x+3+cell.orderStatusLbl.frame.size.width, 29, orderDate_newSize.width, 21);
		
	}
    
	return cell;
}
#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //detailed order history
    OrderHistoryDetailsVC *orderDetails=[[OrderHistoryDetailsVC alloc]initWithNibName:@"OrderHistoryDetailsVC" bundle:nil];
    [self.navigationController pushViewController:orderDetails animated:YES];
    [orderDetails release];
    
}
#pragma mark -
- (IBAction)backToMenu:(id)sender {
    if([[[self.navigationController viewControllers] objectAtIndex:1] isKindOfClass:[HomeScreenVC class]]){
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
    }
    else {
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];
    }
}

- (IBAction)settingsAction:(id)sender {
    SettingsVC *settings=[[SettingsVC alloc]initWithNibName:@"SettingsVC" bundle:nil];
    [self.navigationController pushViewController:settings animated:YES];
    [settings release];
}
#pragma mark -
- (void)viewDidUnload
{
    [self setOrderHistoryTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [orderHistoryTable release];
    [super dealloc];
}
@end
