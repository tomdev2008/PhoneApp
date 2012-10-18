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
    
    // Do any additional setup after loading the view from its nib.
    [self performSelector:@selector(makeRequestToGetOrders) withObject:nil afterDelay:0.1];
}

-(void)makeRequestToGetOrders{
    if([CheckNetwork connectedToNetwork]){
        [self showProgressHUD:self.view withMsg:nil];
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
        AlertWithMessageAndDelegate(@"GiftGiv", @"Please check your network connection", nil);
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
    cell.profileNameLbl.text=[[[ordersList objectAtIndex:indexPath.row] objectForKey:@"OrderDetails"] recipientName];
    NSString *dateString=[[[[[ordersList objectAtIndex:indexPath.row]objectForKey:@"OrderDetails"] dateofCreation] componentsSeparatedByString:@"T"] objectAtIndex:0];
    cell.orderDateLbl.text=[self updateDate:dateString];
    
    if([[ordersList objectAtIndex:indexPath.row]objectForKey:@"ProfilePicture"])
        cell.profilePic.image=[[ordersList objectAtIndex:indexPath.row]objectForKey:@"ProfilePicture"];
    
    if([[[[ordersList objectAtIndex:indexPath.row]objectForKey:@"OrderDetails"] status] isEqualToString:@"-1"]){
        cell.profileNameLbl.textColor=[UIColor colorWithRed:0 green:0.66 blue:0.67 alpha:1.0];
        cell.orderStatusLbl.text=@"waiting for recipient reply";
    }
    else if([[[[ordersList objectAtIndex:indexPath.row]objectForKey:@"OrderDetails"] status] isEqualToString:@"0"]){
        cell.profileNameLbl.textColor=[UIColor colorWithRed:0 green:0.66 blue:0.67 alpha:1.0];
        cell.orderStatusLbl.text=@"pending at store";
    }
    else if([[[[ordersList objectAtIndex:indexPath.row]objectForKey:@"OrderDetails"] status] isEqualToString:@"1"]){
        cell.profileNameLbl.textColor=[UIColor colorWithRed:0 green:0.66 blue:0.67 alpha:1.0];
        cell.orderStatusLbl.text=@"dispatched";
    }
    else if([[[[ordersList objectAtIndex:indexPath.row]objectForKey:@"OrderDetails"] status] isEqualToString:@"2"]){
        cell.profileNameLbl.textColor=[UIColor blackColor];
        cell.orderStatusLbl.text=@"delivered";
    }
    else if([[[[ordersList objectAtIndex:indexPath.row]objectForKey:@"OrderDetails"] status] isEqualToString:@"3"]){
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
-(void)retrieveProfilePictures{
    int ordersListCount=[ordersList count];
    
    for(int i=0;i<ordersListCount;i++){
        dispatch_queue_t ImageLoader_Q;
        ImageLoader_Q=dispatch_queue_create("Facebook profile picture network connection queue", NULL);
        dispatch_async(ImageLoader_Q, ^{
            
            NSString *urlStr=[[[ordersList objectAtIndex:i]objectForKey:@"OrderDetails"] profilePictureUrl];
            
            NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
            UIImage *thumbnail = [UIImage imageWithData:data];
            
            if(thumbnail==nil){
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    
                    NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithDictionary:[ordersList objectAtIndex:i]];
                    [tempDict setObject:[ImageAllocationObject loadImageObjectName:@"profilepic_dummy" ofType:@"png"] forKey:@"ProfilePicture"];
                    [ordersList replaceObjectAtIndex:i withObject:tempDict];
                    [tempDict release]; 
                    
                    [orderHistoryTable reloadData];
                });
                
            }
            else {
                
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithDictionary:[ordersList objectAtIndex:i]];
                    [tempDict setObject:thumbnail forKey:@"ProfilePicture"];
                    [ordersList replaceObjectAtIndex:i withObject:tempDict];
                    [tempDict release];  
                    [orderHistoryTable reloadData];
                    //[self loadCurrentGiftItemsForCategory:[[giftCategoriesList objectAtIndex:giftCatNum-1]catId]];
                });
            }
            
        });
        dispatch_release(ImageLoader_Q);
    }
}
#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //detailed order history
    OrderHistoryDetailsVC *orderDtls=[[OrderHistoryDetailsVC alloc]initWithNibName:@"OrderHistoryDetailsVC" bundle:nil];
    orderDtls.orderDetails=[[ordersList objectAtIndex:indexPath.row] objectForKey:@"OrderDetails"];
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
    [self performSelector:@selector(retrieveProfilePictures)];
}
-(void) requestFailed{
    [self stopHUD];
    AlertWithMessageAndDelegate(@"GiftGiv", @"Request has failed. Please try again later", nil);
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
