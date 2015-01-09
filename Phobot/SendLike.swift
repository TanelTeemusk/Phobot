//
//  SendLike.swift
//  Phobot
//
//  Created by Tanel Teemusk on 24/12/14.
//  Copyright (c) 2014 Tanel Teemusk. All rights reserved.
//

import UIKit

protocol SendLikeDelegate {
    func messageFromLikeClass(success:Bool, user:InstaItem, message:String)

}

class SendLike: NSObject {
    var delegate:SendLikeDelegate! = nil
    var token:String = ""
    //var data:NSMutableData = NSMutableData()
    var cur_user:InstaItem?;
    
    override init(){
    }
    
    func sendLikeToInstagram(itm:InstaItem){
        println("sending like to \(itm.mediaid)")
        cur_user = itm
        let _url = "https://api.instagram.com/v1/media/\(itm.mediaid)/likes?access_token=" + self.token
        let escaped_url:String = _url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        var url: NSURL = NSURL(string: escaped_url)!
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let poststr = "access_token=\(self.token)"
        let postvars = (poststr as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPBody = postvars
        
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("LIKING completed")
            
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            
            var err: NSError?
            
            dispatch_async(dispatch_get_main_queue(), {
                self.dataReceived(data)
            })
            
        })
        task.resume()
        /*
        
        
        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)!
        connection.start()
        
        */

    }
    func dataReceived(data:NSData){
        let json = JSON(data: data)
        
        let errcode:String = json["meta"]["code"].stringValue! //json["data"].arrayValue!
        println(errcode)
        println(json)
        
        if(errcode != "429"){
            
            delegate.messageFromLikeClass(true, user:cur_user!,message: "OK")
        }else{
            delegate.messageFromLikeClass(false, user:cur_user!,message: errcode)
            
        }
        
    }

    
    
    
    /*
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
        self.data.setData(data)
    }
    
    
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        var err: NSError
        
        
    
    }

*/
    

}
