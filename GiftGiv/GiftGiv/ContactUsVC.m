//
//  ContactUsVC.m
//  GiftGiv
//
//  Created by Srinivas G on 10/30/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

#import "ContactUsVC.h"

@implementation ContactUsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)internalLinkActions:(id)sender {
    switch ([sender tag]) {
            //mail
        case 1:
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"mailto://info@giftgiv.com"]];
            break;
            //phone
        case 2:
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"tel://425-985-3735"]];
            break;
            //terms
        case 3:
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://thegiftgiv.com/terms.html"]];
            break;
            //policy
        case 4:
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://thegiftgiv.com/"]];
            break;
            
            
    }
}
- (IBAction)backToHomeScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -
- (void)viewDidUnload
{
        
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
    
    [super dealloc];
}
@end
