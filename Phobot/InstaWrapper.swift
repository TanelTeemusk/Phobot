//
//  InstaWrapper.swift
//  Phobot
//
//  Created by Tanel Teemusk on 14/01/15.
//  Copyright (c) 2015 Tanel Teemusk. All rights reserved.
//

import UIKit

protocol InstaWrapperDelegate{
    func notifyDebug(text:String)
    func killedBotting()
    func updateCountdown(txt:String)
}

class InstaWrapper: NSObject,FeedLoaderDelegate,SendLikeDelegate {
    var delegate:InstaWrapperDelegate! = nil
    var model:Model?
    var loader:FeedLoader = FeedLoader()
    var sendlike = SendLike()
    var candidateSelector:AnyObject?
    
    //Instagram api specifics
    var secret:String = ""
    var token:String = ""
    var clientid:String = ""
    
    //Session variables
    var bot_method:String = "Classic" //Defaults to classic
    var cur_hashtag:String = ""
    var chosen_candidates:[InstaItem] = []
    
    var botting = false
    
    var next_url:String = ""
    var api_retries = 0
    
    var timer:NSTimer?
    var counttimer:NSTimer?
    var secs_left:Int = 0
    
    var current_session_liked:Int = 0
    var current_tag_liked:Int = 0
    
    var total_likes:Int = 0
    
    override init(){
        super.init()
        loader.delegate = self;
        sendlike.delegate = self;
    
        
    }
    
    
    func getByTag(tag:String){
        
        cur_hashtag = tag
        botting = true
        current_tag_liked = 0
        
        total_likes = model!.total_likes
        
        delegate.notifyDebug("##################### \n")
        delegate.notifyDebug("### Getting new data for #\(cur_hashtag) ### \n")
        
        
        let instagramURLString = "https://api.instagram.com/v1/tags/"+tag+"/media/recent?client_id=" + self.clientid
        next_url = instagramURLString
        sendlike.token = token
        
        loadData()
        
        
        
    }
    func loadData(){
        api_retries++
        loader.loadFeed(next_url)
    
    }
    
    
    func feedLoaded(data:JSON?,errors:Bool){
        println("FEED LOADE WOOT. errors: \(errors)")
        //println(data)
        let json = data!
        
        if(json == nil){
            println("SOMETHING WENT TRULY BAD in InstaWrapper \(api_retries)")
            if !botting {
                return
            }
            if(api_retries < 10){
                loadData()
            }else{
                delegate.notifyDebug("Something went awry. Not sure about the internet connection. I mean stuff does not look good. Try again or something. Maybe try to see if you're connecte to internet and stuff. I really have no idea what's going on, but I'm sure I can't put any likes right now on your behalf. Maybe try to contact my creator and letting him know what's going on? Maybe just hit yourself with a hammer or a brick? Maybe just go to instagram for yourself for a change and make some real likes by looking at those stupid crappy photos that your target group has taken? I mean I really have no answers right now. Go out and play. Talk to people. You've been botting too much lately.\n")
                killBottingSession()
            }
            return;
            
        }
        if bot_method != "Polling" {
            if json["pagination"]["next_url"].string != nil{
                next_url = json["pagination"]["next_url"].stringValue
            }else{
            next_url = "";
            }
        }
        
        let jsdata:Array! = json["data"].arrayValue
        var max_reached:Bool = false
        
        var candidates:[InstaItem] = []
        
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
        selectCandidates(candidates)
        api_retries = 0
        
        
    }
    func selectCandidates(arr:[InstaItem]){
        switch(bot_method){
        default:
            var selector = TargetSelectorClassic(chosen: chosen_candidates)
            selector.model = model
            var selec = selector.selectCandidate(arr)
            chosen_candidates = (selec)
            selec = []
        break
        }
        delegate.notifyDebug("Found \(chosen_candidates.count) for this url \n")
        if chosen_candidates.count == 0 && bot_method == "Polling" {
            delegate.notifyDebug("Found no items for now. Gonna try again in 10 minutes\n")
            killTimer()
            timer = NSTimer.scheduledTimerWithTimeInterval(600, target: self, selector: Selector("loadData"), userInfo: nil, repeats: true)
            startCountdown(600)
        }else{
            startLiking();
        }
        
        
    }
    
    func startLiking(){
        killTimer()
        timer = NSTimer.scheduledTimerWithTimeInterval(140, target: self, selector: Selector("likePhoto"), userInfo: nil, repeats: true)
        likePhoto()
        startCountdown(140)
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
            current_tag_liked++
            total_likes++
            model!.total_likes = total_likes
            
            startCountdown(140)
        }
        
        if chosen_candidates.count == 0{
            
            if next_url != "" {
                loadData()
            }else{
               
                delegate.notifyDebug("Found no items for now. Ending botting session\n")
                killBottingSession()
                
            }
            
        }
        
        
    }

    
    
    
    func killTimer(){
        if(timer != nil){
            timer!.invalidate()
        }
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


    
    
    
    
    func killBottingSession(){
        println("KILL ME")
        cur_hashtag = ""
        botting = false
        next_url = ""
        chosen_candidates = []
        killTimer()
        botting = false;
        
        if(delegate != nil){
            delegate.notifyDebug("Current Tag added likes: \(current_tag_liked) \n")
            delegate.notifyDebug("Total likes added: \(total_likes) \n")
            delegate.notifyDebug("##################### \n")
            delegate.killedBotting()
            counttimer?.invalidate()
            delegate.updateCountdown("")
        }
    }
    
    
    
    
}
