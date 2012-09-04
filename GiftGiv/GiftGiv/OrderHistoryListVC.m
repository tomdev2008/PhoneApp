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
@synthesize noHistoryLbl;
@synthesize startCelebBtn;

static NSDateFormatter *customDateFormat=nil;

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
    
    startCelebBtn.hidden=YES;
    noHistoryLbl.hidden=YES;
    
    ordersList=[[NSMutableArray alloc]init];
    [self showProgressHUD:self.view withMsg:nil];
    // Do any additional setup after loading the view from its nib.
    [self performSelector:@selector(makeRequestToGetOrders) withObject:nil afterDelay:0.1];
}

-(void)makeRequestToGetOrders{
    if([CheckNetwork connectedToNetwork]){
        NSString *soapmsgFormat=[NSString stringWithFormat:@"<tem:GetOrdersandUserDetails>\n<tem:senderId>%@</tem:senderId>\n</tem:GetOrdersandUserDetails>",[[NSUserDefaults standardUserDefaults]objectForKey:@"MyGiftGivUserId"]];
        
        NSString *soapRequestString=SOAPRequestMsg(soapmsgFormat);
        //NSLog(@"%@",soapRequestString);
        NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"GetOrdersandUserDetails"];
        
        GetListOfOrdersRequest *ordersReq=[[GetListOfOrdersRequest alloc]init];
        [ordersReq setListOfOrdersDelegate:self];
        [ordersReq getListOfOrdersRequest:theRequest];
        [ordersReq release];
    }
    else{
        AlertWithMessageAndDelegate(@"GiftGiv", @"Check your network settings", nil);
    }
}
#pragma mark - TableView Data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [ordersList count];
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
        
	}
    cell.profileNameLbl.text=[[ordersList objectAtIndex:indexPath.row] recipientName];
    NSString *dateString=[[[[ordersList objectAtIndex:indexPath.row] dateofCreation] componentsSeparatedByString:@"T"] objectAtIndex:0];
    cell.orderDateLbl.text=[self updateDate:dateString];//[CustomDateDisplay updatedDateToBeDisplayedForTheEvent:dateString];
    /*if([cell.orderDateLbl.text isEqualToString:@"Today"]||[cell.orderDateLbl.text isEqualToString:@"Yesterday"]||[cell.orderDateLbl.text isEqualToString:@"Tomorrow"]||[cell.orderDateLbl.text isEqualToString:@"Recent"]){
     cell.orderDateLbl.textColor=[UIColor colorWithRed:0 green:0.66 blue:0.68 alpha:1.0];
     cell.orderDateLbl.font=[UIFont fontWithName:@"Helvetica-Bold" size:7.0];
     }
     else{
     cell.orderDateLbl.font=[UIFont fontWithName:@"Helvetica" size:7.0];
     cell.orderDateLbl.textColor=[UIColor blackColor];
     }*/
    cell.profilePic.image=[(OrderObject*)[ordersList objectAtIndex:indexPath.row] profilePicImg];
    
    if([[[ordersList objectAtIndex:indexPath.row] status] isEqualToString:@"-1"]){
        cell.profileNameLbl.textColor=[UIColor colorWithRed:0 green:0.66 blue:0.67 alpha:1.0];
        cell.orderStatusLbl.text=@"waiting for recipient reply";
    }
    else if([[[ordersList objectAtIndex:indexPath.row] status] isEqualToString:@"0"]){
        cell.profileNameLbl.textColor=[UIColor colorWithRed:0 green:0.66 blue:0.67 alpha:1.0];
        cell.orderStatusLbl.text=@"pending at store";
    }
    else if([[[ordersList objectAtIndex:indexPath.row] status] isEqualToString:@"1"]){
        cell.profileNameLbl.textColor=[UIColor colorWithRed:0 green:0.66 blue:0.67 alpha:1.0];
        cell.orderStatusLbl.text=@"dispatched";
    }
    else if([[[ordersList objectAtIndex:indexPath.row] status] isEqualToString:@"2"]){
        cell.profileNameLbl.textColor=[UIColor blackColor];
        cell.orderStatusLbl.text=@"delivered";
    }
    else if([[[ordersList objectAtIndex:indexPath.row] status] isEqualToString:@"3"]){
        cell.profileNameLbl.textColor=[UIColor colorWithRed:0 green:0.66 blue:0.67 alpha:1.0];
        cell.orderStatusLbl.text=@"returned";
    }
    
    //Dynamic[fit] label width respected to the size of the text
    CGSize status_maxSize = CGSizeMake(133, 21);
    CGSize status_new_size=[cell.orderStatusLbl.text sizeWithFont:cell.orderStatusLbl.font constrainedToSize:status_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    cell.orderStatusLbl.frame=CGRectMake(60, 29, status_new_size.width, 21);
    
    CGSize orderDate_maxSize = CGSizeMake(80, 21);
    CGSize orderDate_newSize = [cell.orderDateLbl.text sizeWithFont:cell.orderDateLbl.font constrainedToSize:orderDate_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    
    cell.orderDateLbl.frame= CGRectMake(cell.orderStatusLbl.frame.origin.x+3+cell.orderStatusLbl.frame.size.width, 30, orderDate_newSize.width, 21);
    
	return cell;
}
-(NSString*)updateDate:(id)sourceDate{
    if(customDateFormat==nil){
        customDateFormat=[[NSDateFormatter alloc]init];
    }
    NSString *endDateString;
    
    if([sourceDate isKindOfClass:[NSString class]]){
        
        sourceDate=[NSString stringWithFormat:@"%@",sourceDate];
        
        [customDateFormat setDateFormat:@"yyyy-MM-dd"];
        NSDate *tempDate = [customDateFormat dateFromString:sourceDate];
        [customDateFormat setDateFormat:@"MMM dd"];
        endDateString=[customDateFormat stringFromDate:tempDate];
    }
    else{
        [customDateFormat setDateFormat:@"MMM dd"];
        endDateString=[customDateFormat stringFromDate:(NSDate*)sourceDate];
    }
    return endDateString;
}

#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //detailed order history
    OrderHistoryDetailsVC *orderDtls=[[OrderHistoryDetailsVC alloc]initWithNibName:@"OrderHistoryDetailsVC" bundle:nil];
    orderDtls.orderDetails=[ordersList objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:orderDtls animated:YES];
    [orderDtls release];
    
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
#pragma mark - GetListOfOrdersDelegate

-(void) receivedListOfOrder:(NSMutableArray*)listOfOrders{
    
    [self stopHUD];
    if([listOfOrders count]){
        orderHistoryTable.hidden=NO;
        startCelebBtn.hidden=YES;
        noHistoryLbl.hidden=YES;
    }
    else{
        orderHistoryTable.hidden=YES;
        startCelebBtn.hidden=NO;
        noHistoryLbl.hidden=NO;
    }
    if([ordersList count])
        [ordersList removeAllObjects];
    [ordersList addObjectsFromArray:listOfOrders];
    [orderHistoryTable reloadData];
}
-(void) requestFailed{
    [self stopHUD];
    AlertWithMessageAndDelegate(@"GiftGiv", @"Request has been failed. Please try again later", nil);
}
#pragma mark - ProgressHUD methods

- (void) showProgressHUD:(UIView *)targetView withMsg:(NSString *)titleStr  
{
	HUD = [[MBProgressHUD alloc] initWithView:targetView];
	
	// Add HUD to screen
	[targetView addSubview:HUD];
	
	// Regisete for HUD callbacks so we can remove it from the window at the right time
	HUD.delegate = self;
	
	HUD.labelText=titleStr;
	
	// Show the HUD while the provided method executes in a new thread
	[HUD show:YES];
	
}
- (void)stopHUD{
    if (![HUD isHidden]) {
        [HUD setHidden:YES];
    }
}
- (void)hudWasHidden:(MBProgressHUD *)hud
{
	[HUD removeFromSuperview];
	HUD=nil;
}
#pragma mark -
- (void)viewDidUnload
{
    [self setOrderHistoryTable:nil];
    [self setNoHistoryLbl:nil];
    [self setStartCelebBtn:nil];
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
    [ordersList release];
    [orderHistoryTable release];
    [noHistoryLbl release];
    [startCelebBtn release];
    [super dealloc];
}
@end
