//
//  SelectMethodViewControllerTableViewController.swift
//  Phobot
//
//  Created by Tanel Teemusk on 14/01/15.
//  Copyright (c) 2015 Tanel Teemusk. All rights reserved.
//

import UIKit

class SelectMethodViewControllerTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource,UINavigationControllerDelegate  {

    @IBOutlet var maintable: UITableView!
    
    let table_structure = [["title":"Bot Methods","items":["Classic","Polling"], "footer":"Mostly use Classic. Use Polling if it's a popular hashtag. Polling will only choose from latest 20 items to like from."],
                        ["title":"", "items":["Settings"], "footer":""]]
    
    
    let botmethods = ["Classic","Polling"]
    let second_section = ["Settings"]
    let section_names = ["Bot Method",""]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
       
        
        self.maintable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        maintable.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return table_structure.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        var ret = 2
        var sec = table_structure[section] as NSDictionary
        let items = sec.objectForKey("items") as! NSArray
        
        return items.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        
        let sec = table_structure[indexPath.section] as NSDictionary
        let items = sec.objectForKey("items") as! NSArray
        cell.textLabel?.text = items[indexPath.row] as? String
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sec = table_structure[section] as NSDictionary
        let item = sec.objectForKey("title") as! String
        return item
    }
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) ->String? {
        let sec = table_structure[section] as NSDictionary
        let item = sec.objectForKey("footer") as! String
        return item

    }
    
   
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //CODE TO BE RUN ON CELL TOUCH
        println("CELL TAP. \(indexPath.row)")
        switch(indexPath.section){
        case 0:
            self.performSegueWithIdentifier("tobotting", sender: self)
        case 1:
            self.performSegueWithIdentifier("tosettings", sender: self)
        default:
            break
        }
        
    }


    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        let item_index = maintable.indexPathForSelectedRow()!
        
        if(item_index.section == 0){
            openBot(segue)
        }
        if(item_index.section == 1){
            openSettings(segue)
        }
        
        
    }
    func openBot(segue:UIStoryboardSegue){
        let item_index = maintable.indexPathForSelectedRow()!
        let destination = segue.destinationViewController as! BotViewController
        destination.bot_method = botmethods[item_index.row]

    }
    func openSettings(segue:UIStoryboardSegue){
        let destination = segue.destinationViewController as! SettingsViewController
    }
   
}
