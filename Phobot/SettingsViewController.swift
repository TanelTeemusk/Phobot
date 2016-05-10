//
//  SettingsViewController.swift
//  Phobot
//
//  Created by Tanel Teemusk on 14/01/15.
//  Copyright (c) 2015 Tanel Teemusk. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    var model = Model();
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var lbl_maxlikes: UILabel!
    @IBOutlet weak var logoutbtn: UIButton!
    
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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        slider.value = Float(maxlikes)
        lbl_maxlikes.text = "\(maxlikes)"
        
        
        if(model.getPersonData().count == 0){
            logoutbtn.enabled = false
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(sender: AnyObject) {
        model.logout()
        logoutbtn.enabled = false
    }
    
    @IBAction func sliderSlide(sender: AnyObject) {
        var val = Int(round(slider.value))
        var txt =   "\(val)"
        maxlikes = val
        if(Int(val) == 101){
            txt = "∞"
        }
        lbl_maxlikes.text = txt
    }

    
}
