//
//  FeedLoader.swift
//  Phobot
//
//  Created by Tanel Teemusk on 14/01/15.
//  Copyright (c) 2015 Tanel Teemusk. All rights reserved.
//

import UIKit

protocol FeedLoaderDelegate{
    func feedLoaded(data:JSON?, errors:Bool)
}

class FeedLoader: NSObject {
    var delegate:FeedLoaderDelegate! = nil
    
    func loadFeed(url:String){
        let escaped_url:String = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        var url: NSURL = NSURL(string: escaped_url)!
        
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.allowsCellularAccess = true
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            println("Task completed")
            
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println("Error loading feed \(error.localizedDescription)")
                self.delegate.feedLoaded(nil,errors:true)

            }
            
            var err: NSError?
            
            dispatch_async(dispatch_get_main_queue(), {
                let json = JSON(data: data)
                self.delegate.feedLoaded(json,errors:false)
            })
            
        })
        task.resume()

    
    }
    
}
