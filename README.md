# Phobot
Instagram bot iPhone app. Will add likes to a chosen hashtag. written in swift.

###Ok, it works as follows:
- you open the app and log in with instagram account
- back to app you'll see a textfield on top. Add a hashtag without "#" in there
- Tap "Start Liking" and liking will start
App will search for entered hashtag photos. If found it'll add like to it. 
The photo liked will have to fall under the following conditions.
It has less than 20 likes already, User has not been liked before (1000 memorized)

###How to make it work

You need intalled xcode to compile this project.
Also you need to make your own instagram app. you can do this at
http://instagram.com/developer/
Register new application and you'll get cliend ID and client secret from there. Add them yo ViewController.swift class on top in these lines:

let clientid = "YOUR CLIENT ID HERE";
let clientsecret = "YOUR CLIENT SECRET";
Run the app on simulator or on your phone and you're good to go.

###Specs

Written in Swift
App uses Core Data to save information
