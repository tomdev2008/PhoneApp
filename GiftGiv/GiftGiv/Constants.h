//
//  Constants.h
//  GiftGiv
//
//  Created by Srinivas G on 19/07/12.
//  Copyright (c) 2012 Teleparadigm Networks Limited. All rights reserved.
//

//Facebook APP ID
#define KFacebookAppId @"208184389305114"

//Device currect OS version, which we used for page control color dots
#define currentiOSVersion [[[UIDevice currentDevice] systemVersion] doubleValue]

#define WebServiceURL /*@"http://10.11.32.211:81/Service.svc"*/@"http://giftgivstage.cloudapp.net/giftgivservice/Service.svc"
//Staging: http://giftgivstage.cloudapp.net/giftgivservice/Service.svc
//Local: http://10.11.32.211:81/Service.svc
//Production: http://giftgiv.cloudapp.net/GiftGivService/Service.svc

#define SOAPRequestMsg(msgbody) [NSString stringWithFormat:@"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\">\n<soapenv:Header/>\n<soapenv:Body>\n%@\n</soapenv:Body>\n</soapenv:Envelope>",msgbody]


#define FacebookPicURL(userid) [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",userid]


#define events_category_1 @"all upcoming"
#define events_category_2 @"birthdays"
#define events_category_3 @"anniversaries"
#define events_category_4 @"new job"
#define events_category_5 @"congratulations"
