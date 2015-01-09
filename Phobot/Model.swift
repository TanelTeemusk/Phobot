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
    
    let appdelegate = UIApplication.sharedApplication().delegate as AppDelegate;
    
    var likedusers:[InstaItem] = [];
    
    
    func savePersonData(str:String){
        
        var person = getPersonData();
        let managedContext = appdelegate.managedObjectContext!;
        
        if person == nil {
            
            let entity = NSEntityDescription.entityForName("Person", inManagedObjectContext: managedContext);
            person = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext);
        }
        
        person.setValue(str, forKey: "access_token");
        
        var error:NSError?;
        if !managedContext.save(&error){
            println("COULD NOT SAVE PERSON DATA");
        }else{
            println("DATA SAVE OK");
        }
        
        
        
        
    }
    
    func getPersonData() -> NSManagedObject!{
        var ret:NSManagedObject!;
        let managedContext = appdelegate.managedObjectContext!;
        let fetchRequest = NSFetchRequest(entityName: "Person");
        var error: NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            var itms = results;
            if(itms.count != 0){
                ret = itms[0] as NSManagedObject;
                var token = ret.valueForKey("access_token") as String;
                println("Got results from coredata and they are \(token)")
            }
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        return ret;
    }
    
    func initPastLikes(){
        cleanUpOldUsers()
        
        let managedContext = appdelegate.managedObjectContext!;
        
        let fetchRequest = NSFetchRequest(entityName: "LikedUsers");
        
        var error: NSError?
        var fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?

        
        if let results = fetchedResults {
        
        
        
        if(results.count != 0){
        
            for itm in results{
                var instaitem = InstaItem()
                instaitem.username = itm.valueForKey("username") as String
                instaitem.mediaid = itm.valueForKey("mediaid") as String
                instaitem.url = itm.valueForKey("url") as String
                instaitem.userid = itm.valueForKey("userid") as String
                
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
        var fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        
        if fetchedResults!.count > 1000{
            var iterations = (fetchedResults!.count-1000)
            for var i=0;i<iterations;i++ {
                var first = fetchedResults?[i]
                managedContext.deleteObject(first!)
                }
            println("Deleted \(iterations) objects")
        }
        
        
    }
    
    
}
