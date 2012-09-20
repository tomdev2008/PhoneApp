//
//  Constants.h
//  GiftGiv
//

//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

//Facebook APP ID
#define KFacebookAppId /*@"410784185600350"*/@"363735827035251"

//LinkedIn
static NSString *const kOAuthConsumerKey     = @"gfe65g59bgnz";
static NSString *const kOAuthConsumerSecret  = @"Ae4c7a2ZNHnnnmHo";

//Device currect OS version, which we used for page control color dots
#define currentiOSVersion [[[UIDevice currentDevice] systemVersion] doubleValue]

#define WebServiceURL @"http://giftgivstage.cloudapp.net/giftgivservice/Service.svc"
//Staging: http://giftgivstage.cloudapp.net/giftgivservice/Service.svc?wsdl
//Local: http://10.11.32.211:81/Service.svc?wsdl
//Production: http://giftgiv.cloudapp.net/GiftGivService/Service.svc

#define SOAPRequestMsg(msgbody) [NSString stringWithFormat:@"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\">\n<soapenv:Header/>\n<soapenv:Body>\n%@\n</soapenv:Body>\n</soapenv:Envelope>",msgbody]


#define FacebookPicURL(userid) [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",userid]


#define events_category_1 @"all upcoming"
#define events_category_2 @"birthdays"
#define events_category_3 @"events to celebrate"//@"relationships"
#define events_category_4 @"facebook contacts"//@"new job"
#define events_category_5 @"linkedIn contacts"//@"congratulations"

// Paypal API
#define MERCHANT_USERNAME /*@"gadda._1345733424_biz_api1.gmail.com"*/@"giftgivco_api1.gmail.com"
#define MERCHANT_PASSWORD /*@"1345733447"*/@"JRRX8T275RR2CUJ6"
#define MERCHANT_SIGNATURE /*@"AFcWxV21C7fd0v3bYYYRCpSSRl31A6Ag-LWYqcLdoPqXZc0llHvYYb8n"*/@"Arr0.D-RwOqYOFyV8ttxDMemqffWANgJJVGDAj8G8NGFu937Bfpf81Hm"
