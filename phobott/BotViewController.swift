//
//  ViewController.swift
//  Phobot
//
//  Created by Tanel Teemusk on 22/12/14.
//  Copyright (c) 2014 Tanel Teemusk. All rights reserved.
//
import CoreData
import UIKit

class BotViewController: UIViewController, InstaWrapperDelegate, UITextFieldDelegate {
    
    
    
    let clientid = "cc2ae60f511240f8a2462937bb612924";
    let clientsecret = "b0ad13876e1f4d889879ec2f225fdbea";
    var access_token = "";
    
    @IBOutlet weak var txt_countdown: UILabel!
    @IBOutlet weak var loginview: UIView!
    @IBOutlet weak var login_btn: UIButton!
    @IBOutlet weak var btn_startbot: UIButton!
    @IBOutlet weak var txt_hashtag: UITextField!
    
    @IBOutlet weak var txt_debug: UITextView!
    
    var model = Model();
    var loader:InstaWrapper = InstaWrapper();
    var botting:Bool = false;
    var bot_method = ""
    
    var textarea_text:String = "";
    
    
    

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        println("Bot method: \(bot_method)")
        loader.model = model
        loader.bot_method = bot_method
        self.title = bot_method
        
        let persobj = model.getPersonData();
        if(persobj.count != 0){
            access_token = persobj[0] as! String
            println("token is: \(access_token)")
            self.loginview.removeFromSuperview()
            
            loader.delegate = self
            
            //appendDebug("Access token: \(access_token) \n");
            
            
            loader.model = self.model
            loader.token = self.access_token
            loader.secret = self.clientsecret
            loader.clientid = self.clientid
            dispatch_async(dispatch_get_main_queue(), {
                self.model.initPastLikes()
            })
            
            
        }
        txt_hashtag.delegate = self
        appendDebug("Init complete \n");
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        initBotting()
        return true
    }
    
    func keyboardWillShow(notification: NSNotification){
        // println("Kb show. adjust views on the screen to keyboard")
    }
    func keyboardWillHide(keyboardWillHide: NSNotification){
        // println("kb hide. make views full height")
    }
    
    func appendDebug(str:String){
        
        self.textarea_text = str+self.textarea_text;
        self.txt_debug.text = self.textarea_text
        
    }
    func notifyDebug(text:String){
        
        self.appendDebug(text)
        
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func LogToInstagram(sender: AnyObject) {
        println("LOG INTO INSTAGRAM");
        doOAuthInstagram();
    }
    
    
    func doOAuthInstagram(){
        let oauthswift = OAuth2Swift(
            consumerKey:    clientid,
            consumerSecret: clientsecret,
            authorizeUrl:   "https://api.instagram.com/oauth/authorize",
            responseType:   "token"
        )
        oauthswift.authorizeWithCallbackURL( NSURL(string: "igcc2ae60f511240f8a2462937bb612924://authorize")!, scope: "likes+comments", state:"INSTAGRAM", success: {
            credential, response in
            
            self.access_token = credential.oauth_token;
            self.model.savePersonData(credential.oauth_token);
            self.loginview.removeFromSuperview();
            
            
            }, failure: {(error:NSError!) -> Void in
                println(error.localizedDescription)
        })
    }
    
    
    
    @IBAction func startBotting(sender: AnyObject) {
        
        initBotting()
        
    }
    func initBotting(){
        var tag = txt_hashtag.text;
        if(tag == ""){
            appendDebug("Please type a hashtag to track \n");
            
            return;
        }
        
        
        if(botting){
            loader.killBottingSession();
            txt_hashtag.enabled = true
        }else{
            appendDebug("Botting: #\(txt_hashtag.text) \n")
            btn_startbot.setTitle("Stop Liking", forState: UIControlState.Normal);
            loader.getByTag(txt_hashtag.text)
            txt_hashtag.resignFirstResponder()
            txt_hashtag.enabled = false
        }
        
        botting = !botting;
    }
    func killedBotting() {
        
        btn_startbot.setTitle("Start Liking", forState: UIControlState.Normal);
    }
    
    
    func updateCountdown(txt:String){
        if(txt == ""){
            txt_countdown.text = ""
        }else{
            txt_countdown.text = "next in \(txt)s"
        }
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        println("View will disappear")
        loader.killBottingSession()
    }
    
    
    
    
}

