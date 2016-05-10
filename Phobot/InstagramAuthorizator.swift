//
//  InstagramAuthorizator.swift
//  Phobot
//
//  Created by Tanel Teemusk on 22/12/14.
//  Copyright (c) 2014 Tanel Teemusk. All rights reserved.
//

import UIKit

class InstagramAuthorizator: NSObject {
    let oauthswift = OAuth2Swift(
        consumerKey:    "********",
        consumerSecret: "********",
        authorizeUrl:   "https://api.instagram.com/oauth/authorize",
        responseType:   "token"
    );

    

   
}
