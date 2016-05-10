//
//  InstaLoader.swift
//  Phobot
//
//  Created by Tanel Teemusk on 23/12/14.
//  Copyright (c) 2014 Tanel Teemusk. All rights reserved.
//

import UIKit
import Foundation

protocol InstaLoaderDelegate{
    func notifyDebug(text:String)
    func killedBotting()
    func updateCountdown(txt:String)
}

class InstaLoader :NSObject, SendLikeDelegate{
    var delegate:InstaLoaderDelegate! = nil
    var model:Model?;
    //var clientid:String = ""
    var secert:String = ""
    var token:String = ""
    var clientid:String = ""
    var cur_hashtag:String = ""

    //var data:NSMutableData = NSMutableData()
    var candidates:[InstaItem] = []
    var chosen_candidates:[InstaItem] = [];
    //var appendDebug:AnyObject?
    var current_session_liked:Int = 0
    
    var botting:Bool = false;
    
    //Choose by those conditions
    let maxlikes:Int = 20
    
    var sendlike = SendLike()
    
    //###
    var timer:NSTimer?
    var next_url:String = ""
    
    var counttimer:NSTimer?
    var secs_left:Int = 0
    
    var api_retries:Int = 0
    
    override init(){
        super.init()
        sendlike.delegate = self;
    }
    
    
    func getByTag(tag:String){
        
        //kill session vars
        
        //data = NSMutableData()
        cur_hashtag = tag
        botting = true
        delegate.notifyDebug("##################### \n")
        delegate.notifyDebug("### Getting new data for #\(cur_hashtag) ### \n")
        let instagramURLString = "https://api.instagram.com/v1/tags/"+tag+"/media/recent?client_id=" + self.clientid
        next_url = instagramURLString
        connectToInstagram(instagramURLString)
        
        sendlike.token = token
    }
    
    func connectToInstagram(_url:String){
        if(_url == ""){
            killBottingSession()
            return
        }
        if !botting {return}
        //delegate.notifyDebug("ur: \(_url) \n")
        
        candidates = [];
        chosen_candidates = [];
        killTimer()
        
        let escaped_url:String = _url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        var url: NSURL = NSURL(string: escaped_url)!
        
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.allowsCellularAccess = true
        
        //var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)!
        //connection.start()
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            println("Task completed")
            
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
        
        api_retries++
    }
    
    
    func dataReceived(_data:NSData!) {
        var err: NSError
       
        
        
        let json = JSON(data: _data)
        
       // println(json)
        if(json == nil){
            println("SOMETHING WENT TRULY BAD in InstaLoader \(api_retries)")
            if !botting {
                return
            }
            if(api_retries < 10){
                connectToInstagram(next_url)
            }else{
                delegate.notifyDebug("Something went awry. Not sure about the internet connection. I mean stuff does not look good. Try again or something. Maybe try to see if you're connecte to internet and stuff. I really have no idea what's going on, but I'm sure I can't put any likes right now on your behalf. Maybe try to contact my creator and letting him know what's going on? Maybe just hit yourself with a hammer or a brick? Maybe just go to instagram for yourself for a change and make some real likes by looking at those stupid crappy photos that your target group has taken? I mean I really have no answers right now. Go out and play. Talk to people. You've been botting too much lately.\n")
                killBottingSession()
            }
            //killBottingSession()
            return;
            
        }
        if json["pagination"]["next_url"].string != nil {
            next_url = json["pagination"]["next_url"].stringValue
        }else{
            next_url = "";
        }
       
        let jsdata:Array! = json["data"].arrayValue
        var max_reached:Bool = false
        
        for itm in jsdata{
            if(itm["caption"]["text"].string != nil){
                var obj = InstaItem()
                var caption:String = itm["caption"]["text"].stringValue 
                
                var imgurl:String = itm["images"]["standard_resolution"]["url"].stringValue
                var date:String = itm["created_time"].stringValue
                var likecount:Int = itm["likes"]["count"].intValue
                var username:String = itm["user"]["username"].stringValue
                var userid:String = itm["user"]["id"].stringValue
                var mediaid:String = itm["id"].stringValue
                obj.caption = caption
                obj.url = imgurl
                obj.date = date
                obj.likecount = likecount
                obj.username = username
                obj.userid = userid
                obj.mediaid = mediaid
                candidates.append(obj)
            }
            
        }
        selectCandidates()
        api_retries = 0
        return
    }
    
    func selectCandidates(){
        for c in candidates{
            if c.likecount < maxlikes{
                
                addIfNotLikedBefore(c)
            
            }
        
        }
        delegate.notifyDebug("Found \(chosen_candidates.count) for this url \n")
        startLiking();
    }
    
    func addIfNotLikedBefore(c:InstaItem){
        var is_added:Bool = false
        let likedarr = model!.getPastLikedUsers()
        
        for like in likedarr{
            if like.username == c.username{
                is_added = true
                break
            }
        }
        if(!is_added){
            addIfNotAlreadyAdded(c)
        }
        
    }
    func addIfNotAlreadyAdded(c:InstaItem){
        var is_added:Bool = false
        
        for added in chosen_candidates{
            if(added.username == c.username){
                is_added = true
                break
            }
        }
        if(!is_added){
            chosen_candidates.append(c)
        }
    }
    
    
    func startLiking(){
        killTimer()
        timer = NSTimer.scheduledTimerWithTimeInterval(140, target: self, selector: Selector("likePhoto"), userInfo: nil, repeats: true)
        likePhoto()
        startCountdown(140)
       
        
    }
    func likePhoto(){
        if(!chosen_candidates.isEmpty){
            sendlike.sendLikeToInstagram(chosen_candidates[0])
        }
        
        if chosen_candidates.count == 0 && next_url == "" {
            delegate.notifyDebug("no more items for this tag\n")
            killBottingSession()
        }

    }
    
    func messageFromLikeClass(success:Bool,user:InstaItem, message:String){
        if(!success){
            
            delegate.notifyDebug("Overheated. Gonna try again in 3 minutes\n")
            killTimer()
            timer = NSTimer.scheduledTimerWithTimeInterval(180, target: self, selector: Selector("startLiking"), userInfo: nil, repeats: false)
            startCountdown(180)
        }else{
            let candidate = chosen_candidates.removeAtIndex(0)
            delegate.notifyDebug("added like to user:\(user.username)\n")
            model!.addPastLikedUser(user);
            current_session_liked++
            startCountdown(140)
        }
        
        if chosen_candidates.count == 0{
            if next_url != "" {
                // println("GET NEW INSTAGRAM DATA PLEASE\n\(next_url)")
                connectToInstagram(next_url)
            }else{
                killBottingSession()
            }
            
        }

        
    }
    
    func killTimer(){
        if(timer != nil){
            timer!.invalidate()
        }
    }
    func killBottingSession(){
        next_url = ""
        //data = NSMutableData()
        killTimer()
        botting = false;
        delegate.notifyDebug("Current Session added likes: \(current_session_liked) \n")
        delegate.notifyDebug("##################### \n")
        delegate.killedBotting()
        counttimer?.invalidate()
        delegate.updateCountdown("")
    }
    
    
    func startCountdown(secs:Int){
        counttimer?.invalidate()
        secs_left = secs
        counttimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("tick"), userInfo: nil, repeats: true)
    }
    func tick(){
        secs_left--
        var snd:String = "\(secs_left)"
        if secs_left < 1 {
            snd = ""
        }
        self.delegate.updateCountdown(snd)
    
    
    }
    
    


}
