//
//  SelectionClassic.swift
//  Phobot
//
//  Created by Tanel Teemusk on 14/01/15.
//  Copyright (c) 2015 Tanel Teemusk. All rights reserved.
//

import UIKit

class TargetSelectorClassic: NSObject {
    var model:Model?
    var chosen_candidates:[InstaItem] = []
    
     init(chosen:[InstaItem]){
        super.init()
        chosen_candidates = chosen
 
    }
    
    func selectCandidate(arr:[InstaItem])->[InstaItem]{
        var maxlikes = model?.maxlikes
        println("max likes: \(maxlikes!)")
        for c in arr{
            if c.likecount < maxlikes{
                addIfNotLikedBefore(c)
            }
        }

        return chosen_candidates
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

    
}
