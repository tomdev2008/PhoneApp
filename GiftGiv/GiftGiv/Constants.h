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

#define WebServiceURL @"http://giftgivstage.cloudapp.net/giftgivservice/Service.svc"
//Staging: http://giftgivstage.cloudapp.net/giftgivservice/Service.svc?wsdl
//Local: http://10.11.32.211:81/Service.svc?wsdl
//Production: http://giftgiv.cloudapp.net/GiftGivService/Service.svc

#define SOAPRequestMsg(msgbody) [NSString stringWithFormat:@"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\">\n<soapenv:Header/>\n<soapenv:Body>\n%@\n</soapenv:Body>\n</soapenv:Envelope>",msgbody]


#define FacebookPicURL(userid) [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",userid]