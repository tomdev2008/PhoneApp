//
//  EventDetailsVC.m
//  GiftGiv
//
//  Created by Srinivas G on 24/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "EventDetailsVC.h"

@implementation EventDetailsVC
@synthesize profileImgView;
@synthesize nameLbl;
@synthesize eventNameLbl;
@synthesize eventDateLbl;
@synthesize likesCommentsLbl;
@synthesize commentsTable;
@synthesize eventDescription;
@synthesize eventImg;
@synthesize isPhotoTagged;

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
    
    //Dynamic[fit] label width respected to the size of the text
    CGSize eventName_maxSize = CGSizeMake(115, 21);
    CGSize eventName_new_size=[eventNameLbl.text sizeWithFont:eventNameLbl.font constrainedToSize:eventName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    eventNameLbl.frame=CGRectMake(70, 87, eventName_new_size.width, 21);
    
    CGSize eventDate_maxSize = CGSizeMake(88, 21);
    CGSize eventDate_newSize = [eventDateLbl.text sizeWithFont:eventDateLbl.font constrainedToSize:eventDate_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    
    eventDateLbl.frame= CGRectMake(eventNameLbl.frame.origin.x+3+eventNameLbl.frame.size.width, 87, eventDate_newSize.width, 21);
    
    if(isPhotoTagged){
        //event photo's default frame 10, 120,300,170
        eventImg.frame=CGRectMake(10, 120, 300, 170);
        [self.view addSubview:eventImg];
        likesCommentsLbl.frame=CGRectMake(13, 290, 221, 21);
        commentsTable.frame=CGRectMake(10, 319, 300, 80);
    }
    else{
        //event description's default frame 5, 115, 310, 100
        eventDescription.frame=CGRectMake(5, 115, 310, 100);
        [self.view addSubview:eventDescription];
        CGSize eventDescription_maxSize = CGSizeMake(310, 100);
        CGSize eventDescription_newSize=[eventDescription.text sizeWithFont:eventDescription.font constrainedToSize:eventDescription_maxSize lineBreakMode:UILineBreakModeWordWrap];
        eventDescription.frame=CGRectMake(5, 115,310, eventDescription_newSize.height+28);
        //NSLog(@"%@",NSStringFromCGSize(eventDescription_newSize));
        
        
        likesCommentsLbl.frame=CGRectMake(13, eventDescription.frame.origin.y+eventDescription.frame.size.height+5, 221, 21);
        
        commentsTable.frame=CGRectMake(10,likesCommentsLbl.frame.origin.y+21+5, 300,400-(likesCommentsLbl.frame.origin.y+21+5));
    }
    
    
}
#pragma mark - TableView Data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 5;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *cellIdentifier;
	cellIdentifier=[NSString stringWithFormat:@"Cell%d",indexPath.row];
	tableView.backgroundColor=[UIColor clearColor];
	CommentsCustomCell *cell = (CommentsCustomCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
	if (cell == nil) {
        
        cell=[[[NSBundle mainBundle]loadNibNamed:@"CommentsCustomCell" owner:self options:nil] lastObject];
		
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
        NSString *profileNameAndComment;
        /*if(indexPath.row%2==0)
         profileNameAndComment=@"Kushal Happy married life how are you fine thank you Happy married life how are you fine thank Kushal Happy married life how are you fine thank you Happy married life how are you fine thank Kushal Happy married life how are you fine thank you Happy married life how are you fine thank";
         else*/
        profileNameAndComment=@"Kushal congratulations";
        NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:profileNameAndComment];
        // for those calls we don't specify a range so it affects the whole string
        attrStr.font=[UIFont fontWithName:@"Helvetica" size:14];
        [attrStr setTextColor:[UIColor blackColor]];
        
        [attrStr setTextColor:[UIColor colorWithRed:0 green:0.67 blue:0.66 alpha:1.0] range:[profileNameAndComment rangeOfString:@"Kushal"]];
        [attrStr setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14] range:[profileNameAndComment rangeOfString:@"Kushal"]];
        cell.commentsLbl.attributedText = attrStr;
        cell.commentsLbl.textAlignment = UITextAlignmentLeft;
		
	}
    
	return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:14.0];
    CGSize constraintSize = CGSizeMake(246.0f, MAXFLOAT);
    NSString *commentText;
    /*if(indexPath.row%2==0)
     commentText=@"Kushal Happy married life how are you fine thank you Happy married life how are you fine thank Kushal Happy married life how are you fine thank you Happy married life how are you fine thank Kushal Happy married life how are you fine thank you Happy married life how are you fine thank";
     else*/
    commentText=@"Kushal congratulations";
    CGSize labelSize = [commentText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    if(labelSize.height>40)
        return labelSize.height+5;
    
    return 44+5;
}
#pragma mark - 
- (IBAction)backToEventsList:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showGiftCategories:(id)sender {
    GiftOptionsVC *giftOptions=[[GiftOptionsVC alloc]initWithNibName:@"GiftOptionsVC" bundle:nil];
    [self.navigationController pushViewController:giftOptions animated:YES];
    [giftOptions release];
}
#pragma mark -
- (void)viewDidUnload
{
    [self setProfileImgView:nil];
    [self setNameLbl:nil];
    [self setEventNameLbl:nil];
    [self setEventDateLbl:nil];
    [self setEventDescription:nil];
    [self setEventImg:nil];
    [self setLikesCommentsLbl:nil];
    [self setCommentsTable:nil];
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
    [profileImgView release];
    [nameLbl release];
    [eventNameLbl release];
    [eventDateLbl release];
    [eventDescription release];
    [eventImg release];
    [likesCommentsLbl release];
    [commentsTable release];
    [super dealloc];
}

@end
