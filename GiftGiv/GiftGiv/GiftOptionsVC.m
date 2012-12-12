//
//  GiftOptionsVC.m
//  GiftGiv
//
//  Created by Srinivas G on 25/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "GiftOptionsVC.h"


@implementation GiftOptionsVC

@synthesize giftCategoryPageControl;
@synthesize profilePicImg;
@synthesize profileNameLbl;
@synthesize eventNameLbl;
@synthesize searchFld;
@synthesize searchGiftsBgView;


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
    fm=[NSFileManager defaultManager];
    
    [self showProgressHUD:self.view withMsg:nil];
    
    NSMutableDictionary *selectedEventDetails=[[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedEventDetails"];
    
    eventNameLbl.text=[selectedEventDetails objectForKey:@"eventName"];
    
    profileNameLbl.text=[[selectedEventDetails objectForKey:@"userName"] uppercaseString];
    NSString *profilePicId;
    
    if([selectedEventDetails objectForKey:@"linkedIn_userID"]){
        profilePicId= [selectedEventDetails objectForKey:@"linkedIn_userID"];
    }
    else{
        profilePicId= [selectedEventDetails objectForKey:@"userID"];
    }
    
    NSString *filePath = [GetCachesPathForTargetFile cachePathForProfilePicFileName:[NSString stringWithFormat:@"%@.png",profilePicId]];
    
    if([fm fileExistsAtPath:filePath]){
        profilePicImg.image=[UIImage imageWithContentsOfFile:filePath];
    }
    else{
        profilePicImg.image=[ImageAllocationObject loadImageObjectName:@"profilepic_dummy" ofType:@"png"];
    }
        
    _searchBgImg.image=[[ImageAllocationObject loadImageObjectName:@"strip" ofType:@"png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    pageActiveImage = [[ImageAllocationObject loadImageObjectName:@"dotactive2" ofType:@"png"] retain];
    pageInactiveImage = [[ImageAllocationObject loadImageObjectName:@"dotinactive2" ofType:@"png"] retain];
    
    
    //Dynamic[fit] label width respected to the size of the text
    CGSize profileName_maxSize = CGSizeMake(160, 21);
    CGSize profileName_new_size=[profileNameLbl.text sizeWithFont:profileNameLbl.font constrainedToSize:profileName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    profileNameLbl.frame=CGRectMake(60, 63, profileName_new_size.width, 21);
    
    CGSize eventName_maxSize = CGSizeMake(320-(profileNameLbl.frame.origin.x+profileNameLbl.frame.size.width+3),21);//123, 21);
    CGSize eventName_newSize = [eventNameLbl.text sizeWithFont:eventNameLbl.font constrainedToSize:eventName_maxSize lineBreakMode:UILineBreakModeTailTruncation];
    
    eventNameLbl.frame= CGRectMake(profileNameLbl.frame.origin.x+5+profileNameLbl.frame.size.width, 64, eventName_newSize.width, 21);
    
    [self makeRequestToGetCategories];
    

}
-(void)retrieveGiftThumbnails{
    
    int giftItemsCount=[listOfAllGiftItems count];
    dispatch_queue_t ImageLoader_Q;
    
    ImageLoader_Q=dispatch_queue_create("Gift thumbnail", NULL);
    for(int i=0;i<giftItemsCount;i++){
        NSString *filePath = [GetCachesPathForTargetFile cachePathForGiftItemFileName:[NSString stringWithFormat:@"%@.png",[[[listOfAllGiftItems objectAtIndex:i]objectForKey:@"GiftDetails"] giftId]]];
        if(![fm fileExistsAtPath:filePath]){
            
            dispatch_async(ImageLoader_Q, ^{
                
                NSString *urlStr=[[[listOfAllGiftItems objectAtIndex:i]objectForKey:@"GiftDetails"] giftImageUrl];
                
                NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
                UIImage *thumbnail = [UIImage imageWithData:data];
                
                
                int GCDValue=[self getTheGCDFirstNum:thumbnail.size.width secondNum:thumbnail.size.height];
                int aspectRatioX=thumbnail.size.width/GCDValue;
                int aspectRatioY=thumbnail.size.height/GCDValue;
                
                float newWidth;
                float newHeight;
                //125-40==> such that it will give 20px white space around the thumbnail in the teal colored box
                if(thumbnail.size.width>thumbnail.size.height){
                    newWidth=120-20;
                    newHeight=((120-20)*aspectRatioY)/aspectRatioX;
                    
                }
                else if(thumbnail.size.width<thumbnail.size.height){
                    newWidth=((120-20)*aspectRatioX)/aspectRatioY;
                    newHeight=120-20;
                    
                }
                else{
                    newWidth=120-20;
                    newHeight=120-20;
                    
                }
                UIImage *targetImg=[thumbnail imageByScalingProportionallyToSize:CGSizeMake(newWidth, newHeight)];
                
                
                if(targetImg!=nil) {
                    NSString *filePath = [GetCachesPathForTargetFile cachePathForGiftItemFileName:[NSString stringWithFormat:@"%@.png",[[[listOfAllGiftItems objectAtIndex:i]objectForKey:@"GiftDetails"] giftId]]]; //Add the file name
                    [UIImagePNGRepresentation(targetImg) writeToFile:filePath atomically:YES]; //Write the file
                    
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        CGPoint scrollContentOffset=_giftsBgScroll.contentOffset;
                        
                        [(UITableView*)[_giftsBgScroll viewWithTag:100+scrollContentOffset.x/320] reloadData];
                        
                    });
                }
                
            });
            
        }
        
                
    }
    dispatch_release(ImageLoader_Q);
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    
}
-(void)makeRequestToGetCategories{
    
    if([CheckNetwork connectedToNetwork]){
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
        NSString *soapmsgFormat=[NSString stringWithFormat:@"<tem:GetCategories/>"];
        
        NSString *soapRequestString=SOAPRequestMsg(soapmsgFormat);
        GGLog(@"GetCategories..%@",soapRequestString);
        NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"GetCategories"];
        
        GiftCategoriesRequest *giftCats=[[GiftCategoriesRequest alloc]init];
        [giftCats setGiftCatDelegate:self];
        [giftCats makeGiftCategoriesRequest:theRequest];
        [giftCats release];
    }
    else{
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        [self stopHUD];
        AlertWithMessageAndDelegate(@"GiftGiv", @"Please check your network connection", nil);
    }
    
}

#pragma mark - Get gift categories Request delegate
-(void) responseForGiftCategories:(NSMutableArray*)categoriesList{
    
    if([categoriesList count]){
        giftCategoriesList=[[NSMutableArray alloc] initWithArray:categoriesList];
        
        if([CheckNetwork connectedToNetwork]){
            NSString *soapmsgFormat=[NSString stringWithFormat:@"<tem:GetGiftItemforPhone/>"];
            
            NSString *soapRequestString=SOAPRequestMsg(soapmsgFormat);
            GGLog(@"GiftItems..%@",soapRequestString);
            NSMutableURLRequest *theRequest=[CoomonRequestCreationObject soapRequestMessage:soapRequestString withAction:@"GetGiftItemforPhone"];
            
            GiftItemsRequest *giftItems=[[GiftItemsRequest alloc]init];
            [giftItems setGiftItemsDelegate:self];
            [giftItems makeGiftItemsRequest:theRequest];
            [giftItems release];
        }
        else{
            [self stopHUD];
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
            AlertWithMessageAndDelegate(@"GiftGiv", @"Please check your network connection", nil);
        }
        
        
        
    }
    else{
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        [self stopHUD];
    }
    
    
    
}
-(void) requestFailed{
    GGLog(@"gift options request failed..");
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    [self stopHUD];
    AlertWithMessageAndDelegate(@"GiftGiv", @"Request has failed. Please try again later", nil);
}
#pragma mark - Gift Items
-(void) responseForGiftItems:(NSMutableArray*)listOfGifts{
    GGLog(@"Received gift items..");
    if([listOfAllGiftItems count]){
        [listOfAllGiftItems removeAllObjects];
        [listOfAllGiftItems release];
        listOfAllGiftItems=nil;
    }
    if(listOfAllGiftItems==nil){
        listOfAllGiftItems=[[NSMutableArray alloc]init];
    }
    [listOfAllGiftItems addObjectsFromArray:listOfGifts];
    
    NSMutableIndexSet *indexSet=[[NSMutableIndexSet alloc] init];

    for(int i=0;i<[giftCategoriesList count];i++){
        if(![self checkWhetherGiftItemsAvailableInACategory:[[giftCategoriesList objectAtIndex:i]catId]]){
            [indexSet addIndex:i];     
        }
    }
       
    [giftCategoriesList removeObjectsAtIndexes:indexSet];
    [indexSet release];
    
    totalCats=[giftCategoriesList count];
    _giftsBgScroll.contentSize=CGSizeMake(320*(totalCats+3), _giftsBgScroll.bounds.size.height);
    if([[_giftsBgScroll subviews] count]){
        for(id subView in [_giftsBgScroll subviews]){
            if([subView isKindOfClass:[UILabel class]] || [subView isKindOfClass:[UITableView class]]){
                [subView removeFromSuperview];
            }
        }
    }
    
    for(int i=0;i<totalCats+1;i++){
        UILabel *giftcatHeadingLbl=[[UILabel alloc]initWithFrame:CGRectMake(17+(320*(i+1)),1,292,42)];
        giftcatHeadingLbl.autoresizesSubviews=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        //GGLog(@"count %d and %d",totalGroups,i);
        
        giftcatHeadingLbl.tag=i+1;
        if(i!=0)
            [giftcatHeadingLbl setText:[[giftCategoriesList objectAtIndex:i-1]catName]];
        [giftcatHeadingLbl setTextColor:[UIColor blackColor]];
        [giftcatHeadingLbl setFont:[UIFont fontWithName:@"Helvetica-Light" size:20]];
        [giftcatHeadingLbl setBackgroundColor:[UIColor clearColor]];
        
        
        [_giftsBgScroll addSubview:giftcatHeadingLbl];
        [giftcatHeadingLbl release];
        
        UITableView *tempGiftsTable=[[UITableView alloc]initWithFrame:CGRectMake(320*(i+1), 45, 320, _giftsBgScroll.bounds.size.height-45)];
        tempGiftsTable.autoresizesSubviews=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [tempGiftsTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        
        tempGiftsTable.tag=i+101;
        
        [tempGiftsTable setDataSource:self];
        [tempGiftsTable setDelegate:self];
        [_giftsBgScroll addSubview:tempGiftsTable];
        [tempGiftsTable release];
    }
    
    giftCategoryPageControl.numberOfPages=totalCats+1;
    giftCatNum=1;
    giftCategoryPageControl.currentPage=giftCatNum;
    [_giftsBgScroll scrollRectToVisible:CGRectMake(640,0,320,416) animated:NO];
    if(currentGiftItems!=nil){
        if([currentGiftItems count])
            [currentGiftItems removeAllObjects];
        [currentGiftItems release];
        currentGiftItems=nil;
    }
   
    [self loadCurrentGiftItemsRespectiveToCategory];
    [self retrieveGiftThumbnails];
      
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    [self stopHUD];
}
-(void)loadCurrentGiftItemsRespectiveToCategory{
    
    if([listOfAllGiftItems count]){
        if(currentGiftItems==nil){
            currentGiftItems=[[NSMutableArray alloc]init];
        }
        [currentGiftItems addObject:[NSMutableArray arrayWithObject:@""]];
        for(GiftCategoryObject *giftCategory in giftCategoriesList){
            
            NSMutableArray *tempListOfGiftsForCategory=[[NSMutableArray alloc]init];
            for(NSMutableDictionary *giftItemDict in listOfAllGiftItems){
                
                if([[giftCategory catId] isEqualToString:[[giftItemDict objectForKey:@"GiftDetails"]giftCategoryId]]){
                    
                    [tempListOfGiftsForCategory addObject:giftItemDict];
                }
                
            }
            [currentGiftItems addObject:tempListOfGiftsForCategory];
            [tempListOfGiftsForCategory release];
           
        }
            
    }
    for (id subview in [_giftsBgScroll subviews]){
        if([subview isKindOfClass:[UITableView class]]){
            [(UITableView*)subview reloadData];
        }
    }
}
#pragma mark -
-(BOOL)checkWhetherGiftItemsAvailableInACategory:(NSString*)categoryId{
    
    if([listOfAllGiftItems count]){
        
        for(NSMutableDictionary *giftItemDict in listOfAllGiftItems){
            
            if([categoryId isEqualToString:[[giftItemDict objectForKey:@"GiftDetails"]giftCategoryId]]){
                return YES;
            }
            
        }
    }
    return NO;
}
#pragma mark -

- (IBAction)cancelTheSearch:(id)sender {
    [searchFld setText:@""];
    [searchFld resignFirstResponder];
    
    isSearchEnabled=NO;
    
    [_giftsBgScroll scrollRectToVisible:CGRectMake(640,_giftsBgScroll.frame.origin.y ,320,343) animated:NO];
    giftCategoryPageControl.currentPage=1;
}

- (IBAction)backToEvents:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)giftCategoriesPaeControlAction:(id)sender {
    
    for (int i = 0; i < [giftCategoryPageControl.subviews count]; i++)
    {
        if(i==0){
            UIImageView* dot = [giftCategoryPageControl.subviews objectAtIndex:i];
            dot.frame = CGRectMake(dot.frame.origin.x, dot.frame.origin.y, 10, 10);
            
            if (i == giftCategoryPageControl.currentPage){
                
                dot.image =[ImageAllocationObject loadImageObjectName:@"searchdotactive2" ofType:@"png"] ;
            }
            else{
                
                dot.image = [ImageAllocationObject loadImageObjectName:@"searchdotinactive2" ofType:@"png"] ;
            }
            
            
        }
        else{
            UIImageView* dot = [giftCategoryPageControl.subviews objectAtIndex:i];
            dot.frame = CGRectMake(dot.frame.origin.x, dot.frame.origin.y, 8, 8);
            if (i == giftCategoryPageControl.currentPage)
                dot.image = pageActiveImage;
            else
                dot.image = pageInactiveImage;
        }
    }
    giftCatNum=giftCategoryPageControl.currentPage;
    CGRect frame = _giftsBgScroll.frame;
    frame.origin.y = 0;
    frame.origin.x = frame.size.width * (giftCategoryPageControl.currentPage+1);
    frame.origin.y = 0;
    [_giftsBgScroll scrollRectToVisible:frame animated:YES];
        
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (_giftsBgScroll.contentOffset.x == 0) {
		// user is scrolling to the left from view 1 to view 4
		// reposition offset to show view 4 that is on the right in the scroll view
		[_giftsBgScroll scrollRectToVisible:CGRectMake(320*(totalCats+1),_giftsBgScroll.frame.origin.y ,320,343) animated:NO];
	}
	else if (_giftsBgScroll.contentOffset.x == 320*(totalCats+2)) {
		// user is scrolling to the right from view 4 to view 1
		// reposition offset to show view 1 that is on the left in the scroll view
		[_giftsBgScroll scrollRectToVisible:CGRectMake(320,_giftsBgScroll.frame.origin.y,320,343) animated:NO];
	}
    
    
}
- (void)scrollViewDidScroll:(UIScrollView *)sender{
    // The key is repositioning without animation
 
    if([sender isEqual:_giftsBgScroll]){
        CGFloat pageWidth = sender.frame.size.width;
        int pagenum = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth);
        giftCategoryPageControl.currentPage = pagenum;
        
        if(giftCategoryPageControl.currentPage!=0){
            isSearchEnabled=NO;
            if([searchGiftsBgView superview]){
                searchFld.text=@"";
                [searchFld resignFirstResponder];
                [searchGiftsBgView removeFromSuperview];
            }
            if([[currentGiftItems objectAtIndex:0] count]){
                if([[currentGiftItems objectAtIndex:0]count]==1)
                {
                    if([[[currentGiftItems objectAtIndex:0]objectAtIndex:0] isKindOfClass:[NSDictionary class]]){
                        [[currentGiftItems objectAtIndex:0]replaceObjectAtIndex:0 withObject:[NSMutableArray arrayWithObject:@""]];
                    }
                    
                }
                else{
                  
                    [[currentGiftItems objectAtIndex:0] removeAllObjects];
                    [[currentGiftItems objectAtIndex:0]addObject:[NSMutableArray arrayWithObject:@""]];
                }
                
            }
            if([[_giftsBgScroll subviews]count])
                [(UITableView*)[[_giftsBgScroll subviews] objectAtIndex:1] reloadData];
            
        }
        else {
            isSearchEnabled=YES;
            searchGiftsBgView.frame=CGRectMake(0, 0, 320, 44);
            if(![searchGiftsBgView superview]){
                
                [self.view addSubview:searchGiftsBgView];
            }
            [searchFld becomeFirstResponder];
           
            
            if([[_giftsBgScroll viewWithTag:1] isKindOfClass:[UIButton class]])
                [(UIButton*)[_giftsBgScroll viewWithTag:1] setTitle:@"" forState:UIControlStateNormal];
            else{
                [(UILabel*)[_giftsBgScroll viewWithTag:1] setText:@""];
            }
            
        }
        
        
    }
}

#pragma mark - Tableview
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if([currentGiftItems count]){
        int tableViewTag=tableView.tag%100;
        
        //GGLog(@"%d,%d,%d,%d",totalCats,[currentGiftItems count],tableViewTag-1,[[currentGiftItems objectAtIndex:tableViewTag-1] count]);
        int totalGiftsInCategory=[[currentGiftItems objectAtIndex:tableViewTag-1] count];
        
        if(totalGiftsInCategory==1){
            if(![[[currentGiftItems objectAtIndex:tableViewTag-1] objectAtIndex:0]isKindOfClass:[NSDictionary class]])
                return 0;
        }
        if(totalGiftsInCategory%2==0)
            return totalGiftsInCategory/2;
        else
            return totalGiftsInCategory/2+1;
    }
    
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int tableViewTag=tableView.tag%100;
    //int totalGiftsInCategory=[[currentGiftItems objectAtIndex:tableViewTag-1] count];
	static NSString *cellIdentifier;
	cellIdentifier=[NSString stringWithFormat:@"Cell%d%d",indexPath.row,tableViewTag];
	
	GiftCustomCell *cell = (GiftCustomCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
	if (cell == nil) {
        
        cell=[[[NSBundle mainBundle]loadNibNamed:@"GiftCustomCell" owner:self options:nil] lastObject];
		
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        [cell.giftIcon_one.layer setBorderColor:[[UIColor colorWithRed:0.0 green:0.66 blue:0.68 alpha:1.0]CGColor]];
        [cell.giftIcon_one.layer setBorderWidth:2.0];
        [cell.giftIcon_two.layer setBorderColor:[[UIColor colorWithRed:0.0 green:0.66 blue:0.68 alpha:1.0]CGColor]];
        [cell.giftIcon_two.layer setBorderWidth:2.0];
        [cell.giftIcon_one addTarget:self action:@selector(giftTileIconTapped:) forControlEvents:UIControlEventTouchUpInside];
        [cell.giftIcon_two addTarget:self action:@selector(giftTileIconTapped:) forControlEvents:UIControlEventTouchUpInside];
		
	}
    cell.tag=indexPath.row;
    cell.tableTagForCell=tableViewTag;
    cell.giftTitle_one.text=[[[[currentGiftItems objectAtIndex:tableViewTag-1]objectAtIndex:(indexPath.row*2)]objectForKey:@"GiftDetails"] giftTitle];
    
    NSArray *priceArray_one=[[[[[currentGiftItems objectAtIndex:tableViewTag-1]objectAtIndex:(indexPath.row*2)] objectForKey:@"GiftDetails"] giftPrice] componentsSeparatedByString:@";"];
        
    if([priceArray_one count]>1){
        ;
        cell.giftPrice_one.text=[NSString stringWithFormat:@"$%@ - $%@",[priceArray_one objectAtIndex:0],[priceArray_one objectAtIndex:[priceArray_one count]-1]];
    }
    else{
        NSString *priceValue=[[[[currentGiftItems objectAtIndex:tableViewTag-1]objectAtIndex:(indexPath.row*2)]objectForKey:@"GiftDetails"] giftPrice];
        if(priceValue!=nil && ![priceValue isEqualToString:@""])
            cell.giftPrice_one.text=[NSString stringWithFormat:@"$%@",priceValue];
                    
    }
    UIImage *tempImg_one=[[[[currentGiftItems objectAtIndex:tableViewTag-1]objectAtIndex:(indexPath.row*2)]objectForKey:@"GiftDetails"] giftThumbnail];
            
    if(tempImg_one==nil){
        NSString *giftItem_OnePath = [GetCachesPathForTargetFile cachePathForGiftItemFileName:[NSString stringWithFormat:@"%@.png",[[[[currentGiftItems objectAtIndex:tableViewTag-1]objectAtIndex:(indexPath.row*2)] objectForKey:@"GiftDetails"] giftId]]];
        
        if([fm fileExistsAtPath:giftItem_OnePath]){
            tempImg_one=[UIImage imageWithContentsOfFile:giftItem_OnePath];
            [[[[currentGiftItems objectAtIndex:tableViewTag-1]objectAtIndex:(indexPath.row*2)]objectForKey:@"GiftDetails"] setGiftThumbnail:tempImg_one];
        }
    }
    
    
    if(tempImg_one!=nil){
        
        [cell.giftImg_one setImage:tempImg_one];
       
    }
        
    if([[currentGiftItems objectAtIndex:tableViewTag-1] count]>(indexPath.row*2)+1){
        cell.giftIcon_two.hidden=NO;
        cell.giftPrice_two.hidden=NO;
        cell.giftTitle_two.hidden=NO;
        cell.giftTitle_two.text=[[[[currentGiftItems objectAtIndex:tableViewTag-1]objectAtIndex:(indexPath.row*2)+1] objectForKey:@"GiftDetails"]giftTitle];
        
        NSArray *priceArray_two=[[[[[currentGiftItems objectAtIndex:tableViewTag-1]objectAtIndex:(indexPath.row*2)+1] objectForKey:@"GiftDetails"]giftPrice] componentsSeparatedByString:@";"];
        
        if([priceArray_two count]>1){
            
            cell.giftPrice_two.text=[NSString stringWithFormat:@"$%@ - $%@",[priceArray_two objectAtIndex:0],[priceArray_two objectAtIndex:[priceArray_two count]-1]];
        }
        else{
            
            NSString *priceValue_2=[[[[currentGiftItems objectAtIndex:tableViewTag-1]objectAtIndex:(indexPath.row*2)+1]objectForKey:@"GiftDetails"] giftPrice];
            if(priceValue_2!=nil && ![priceValue_2 isEqualToString:@""])
                cell.giftPrice_two.text=[NSString stringWithFormat:@"$%@",priceValue_2];
            
        }
        UIImage *tempImg_two=[[[[currentGiftItems objectAtIndex:tableViewTag-1]objectAtIndex:(indexPath.row*2)+1]objectForKey:@"GiftDetails"] giftThumbnail];
        
        if(tempImg_two==nil){
            NSString *giftIconFilePath = [GetCachesPathForTargetFile cachePathForGiftItemFileName:[NSString stringWithFormat:@"%@.png",[[[[currentGiftItems objectAtIndex:tableViewTag-1]objectAtIndex:(indexPath.row*2)+1]objectForKey:@"GiftDetails"] giftId]]];
            
            if([fm fileExistsAtPath:giftIconFilePath]){
                tempImg_two=[UIImage imageWithContentsOfFile:giftIconFilePath];
                [[[[currentGiftItems objectAtIndex:tableViewTag-1]objectAtIndex:(indexPath.row*2)+1]objectForKey:@"GiftDetails"] setGiftThumbnail:tempImg_two];
            }
        }
        
        if(tempImg_two!=nil){
            
            [cell.giftImg_two setImage:tempImg_two];
            
        }
                
    }
    
    else{
        cell.giftIcon_two.hidden=YES;
        cell.giftPrice_two.hidden=YES;
        cell.giftTitle_two.hidden=YES;
    }
    
    
	return cell;
}
#pragma mark -
-(void)giftTileIconTapped:(id)sender{
    
    int rowNum=[(GiftCustomCell*)[(UIButton*)sender superview] tag];
    int tableTag=[(GiftCustomCell*)[(UIButton*)sender superview]tableTagForCell];
    int columNum=[sender tag];
    GiftItemObject *selectedGift=[[[currentGiftItems objectAtIndex:tableTag-1]objectAtIndex:(rowNum*2+columNum)-1]objectForKey:@"GiftDetails"];

    //gift cards
    if([[selectedGift.giftPrice componentsSeparatedByString:@";"] count]>1){
        GiftCardDetailsVC *giftCardDetails=[[GiftCardDetailsVC alloc]initWithNibName:@"GiftCardDetailsVC" bundle:nil];
        giftCardDetails.giftItemInfo=selectedGift;
        [self.navigationController pushViewController:giftCardDetails animated:YES];
        [giftCardDetails release];
    }
    else{
        GGLog(@"%@",selectedGift.giftPrice);
        if([selectedGift.giftPrice isEqualToString:@""]){
            FreeGiftItemDetailsVC *freeGiftItemDetails=[[FreeGiftItemDetailsVC alloc]initWithNibName:@"FreeGiftItemDetailsVC" bundle:nil];
            
            freeGiftItemDetails.giftItemInfo=selectedGift;
            [self.navigationController pushViewController:freeGiftItemDetails animated:YES];
            [freeGiftItemDetails release];
            
        }
        else{
            Gift_GreetingCardDetailsVC *greetingCardDetails=[[Gift_GreetingCardDetailsVC alloc]initWithNibName:@"Gift_GreetingCardDetailsVC" bundle:nil];
            if(![selectedGift.giftImageBackSideUrl length])
                greetingCardDetails.isGreetingCard=NO;
            else if([selectedGift.giftImageBackSideUrl length])
                greetingCardDetails.isGreetingCard=YES;
            greetingCardDetails.giftItemInfo=selectedGift;
            [self.navigationController pushViewController:greetingCardDetails animated:YES];
            [greetingCardDetails release];
        }
       
    }
    
}
#pragma mark - GCD
-(int)getTheGCDFirstNum:(int)width secondNum:(int)height{
   
    //Once we get the greatest value, we should divide the numerator and denominator with greatest value to get aspect ratio
    
    int greatest = 1;
        
    // determine if width or height is larger
    int smaller = ( width < height ) ? width : height;
        
    // test all numbers up to smaller to see if
    // they are divisors of both width and height
    for ( int z = 2; z <= smaller; z++ )
        if ( ( width % z == 0 ) && ( height % z == 0 ) )
            greatest = z;
        
    return greatest;
    
    
}
#pragma mark - Search

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_1{
   
    [searchFld resignFirstResponder];
   
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar_1{
    [searchFld becomeFirstResponder];
}
- (void)searchBar:(UISearchBar *)searchBar_1 textDidChange:(NSString *)searchText{
    
    
    if([searchFld.text isEqualToString:@""]){
        if([[currentGiftItems objectAtIndex:0] count]){
            if([[currentGiftItems objectAtIndex:0]count]==1)
            {
                if([[[currentGiftItems objectAtIndex:0]objectAtIndex:0] isKindOfClass:[NSDictionary class]]){
                    [[currentGiftItems objectAtIndex:0]replaceObjectAtIndex:0 withObject:[NSMutableArray arrayWithObject:@""]];
                }
                
            }
            else{
                
                [[currentGiftItems objectAtIndex:0] removeAllObjects];
                [[currentGiftItems objectAtIndex:0]addObject:[NSMutableArray arrayWithObject:@""]];
            }
            
        }
    }
    if([listOfAllGiftItems count]){
        
        NSMutableArray *tempSearchedArray=[[NSMutableArray alloc]init];
        for (NSMutableDictionary *giftItem in listOfAllGiftItems)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                      @"(SELF contains[cd] %@)", searchFld.text];
            
            BOOL resultName = [predicate evaluateWithObject:[[giftItem objectForKey:@"GiftDetails"]giftTitle]];
            if(resultName)
                
            {
                [tempSearchedArray addObject:giftItem];
                                
            }
            
            
        }
        [currentGiftItems replaceObjectAtIndex:0 withObject:tempSearchedArray];
        if([[_giftsBgScroll viewWithTag:1] isKindOfClass:[UIButton class]])
            [(UIButton*)[_giftsBgScroll viewWithTag:1] setTitle:searchFld.text forState:UIControlStateNormal];
        else{
            [(UILabel*)[_giftsBgScroll viewWithTag:1] setText:searchFld.text];
        }
        [tempSearchedArray release];
    }
    
    [self performSelector:@selector(reloadTheSearchGiftsBitDelay) withObject:nil afterDelay:0.01];
}
-(void)reloadTheSearchGiftsBitDelay{
   [(UITableView*)[[_giftsBgScroll subviews] objectAtIndex:1] reloadData];
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
    [self setProfilePicImg:nil];
    [self setProfileNameLbl:nil];
    [self setEventNameLbl:nil];
    [self setGiftCategoryPageControl:nil];
    [self setSearchGiftsBgView:nil];
    [self setSearchFld:nil];
    [self setGiftsBgScroll:nil];
    [self setSearchBgImg:nil];
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
    
    if([[_giftsBgScroll subviews] count]){
        for(id subView in [_giftsBgScroll subviews]){
            if([subView isKindOfClass:[UILabel class]] || [subView isKindOfClass:[UITableView class]]){
                [subView removeFromSuperview];
            }
        }
    }
    
    [pageActiveImage release];
    [pageInactiveImage release]; 
    
    if([giftCategoriesList count])
        [giftCategoriesList removeAllObjects];
    if(giftCategoriesList!=nil){
        [giftCategoriesList release];
        giftCategoriesList=nil;
    }
    if([listOfAllGiftItems count])
        [listOfAllGiftItems removeAllObjects];
    if(listOfAllGiftItems!=nil){
        [listOfAllGiftItems release];
        listOfAllGiftItems=nil;
    }
    
    if([currentGiftItems count])
        [currentGiftItems removeAllObjects];
    if(currentGiftItems!=nil){
        [currentGiftItems release];
        currentGiftItems=nil;
    }
    
    
    [profilePicImg release];
    [profileNameLbl release];
    [eventNameLbl release];
    [giftCategoryPageControl release];
    
    [searchGiftsBgView release];
    [searchFld release];
    [_giftsBgScroll release];
    [_searchBgImg release];
    [super dealloc];
}

@end
