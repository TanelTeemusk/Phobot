//
//  Model.swift
//  Phobot
//
//  Created by Tanel Teemusk on 22/12/14.
//  Copyright (c) 2014 Tanel Teemusk. All rights reserved.
//

import UIKit
import CoreData;

class Model {
    
    var managedUsers = [NSManagedObject]();
    
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
    
    var likedusers:[InstaItem] = [];
    
    var total_likes : Int {
        get {
            var returnValue = NSUserDefaults.standardUserDefaults().objectForKey("total_likes") as? Int
            if returnValue == nil      //Check for first run of app
            {
                returnValue = 0; //Default value
            }
            return returnValue!
        }
        set (newValue) {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "total_likes")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var account_data:Array<String> = []
        /*
        {
        get {
            var returnValue = NSUserDefaults.standardUserDefaults().objectForKey("account_data")? as? NSArray
            if returnValue == nil      //Check for first run of app
            {
                returnValue = []; //Default value
            }
            return returnValue!
        }
        set (newValue) {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "account_data")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }*/

    
    func savePersonData(str:String){
        
        account_data.append(str)
        NSUserDefaults.standardUserDefaults().setObject(account_data, forKey: "account_data")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        
    }
    
    func getPersonData() -> NSArray!{
        var returnValue = NSUserDefaults.standardUserDefaults().objectForKey("account_data") as? NSArray
        if returnValue == nil      //Check for first run of app
        {
            returnValue = []; //Default value
        }
        account_data = returnValue as! Array
        return account_data
        }
    
    func logout(){
        account_data = []
        NSUserDefaults.standardUserDefaults().setObject(account_data, forKey: "account_data")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func initPastLikes(){
        cleanUpOldUsers()
        
        let managedContext = appdelegate.managedObjectContext!;
        
        let fetchRequest = NSFetchRequest(entityName: "LikedUsers");
        
        var error: NSError?
        var fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?

        
        if let results = fetchedResults {
        
        
        
        if(results.count != 0){
        
            for itm in results{
                var instaitem = InstaItem()
                instaitem.username = itm.valueForKey("username") as! String
                instaitem.mediaid = itm.valueForKey("mediaid") as! String
                instaitem.url = itm.valueForKey("url") as! String
                instaitem.userid = itm.valueForKey("userid") as! String
                
                likedusers.append(instaitem)
                }
        
            }
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        println("Past likes inited. found \(likedusers.count) items")
        
    }
    
    func getPastLikedUsers() -> [InstaItem]{

        return likedusers
    }
    func addPastLikedUser(itm:InstaItem){
        likedusers.append(itm)
        
        
        println("Adding past liked user \(itm.username)")
        
        let managedContext = appdelegate.managedObjectContext!;
        
        let entity = NSEntityDescription.entityForName("LikedUsers", inManagedObjectContext: managedContext);
        let likeduser = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext);
        
        
        likeduser.setValue(itm.username, forKey: "username");
        likeduser.setValue(itm.url, forKey: "url");
        likeduser.setValue(itm.userid, forKey: "userid");
        likeduser.setValue(itm.mediaid, forKey: "mediaid");
        
        
        var error:NSError?;
        if !managedContext.save(&error){
        println("COULD NOT SAVE PERSON DATA");
        }else{
        println("DATA SAVE OK");
        }
        
        
    }
    
    func cleanUpOldUsers(){
        
        
        let managedContext = appdelegate.managedObjectContext!;
        let fetchRequest = NSFetchRequest(entityName: "LikedUsers");
        
        var error: NSError?
        var fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
        
        
        if fetchedResults!.count > 1000{
            var iterations = (fetchedResults!.count-1000)
            for var i=0;i<iterations;i++ {
                var first = fetchedResults?[i]
                managedContext.deleteObject(first!)
                }
            println("Deleted \(iterations) objects")
        }
        
        
    }
    
    var maxlikes : Int {
        get {
            var returnValue = NSUserDefaults.standardUserDefaults().objectForKey("maxlikes") as? Int
            if returnValue == nil      //Check for first run of app
            {
                returnValue = 20; //Default value
            }
            return returnValue!
        }
        set (newValue) {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "maxlikes")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

}
