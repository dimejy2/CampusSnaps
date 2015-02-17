//
//  StreamViewController.swift
//  CampusSnaps
//
//  Created by Oladimeji Abidoye on 2/14/15.
//  Copyright (c) 2015 Dimeji Abidoye. All rights reserved.
//

import UIKit

class StreamViewController : UIViewController {
    
    let date = NSDate()
    let calendar = NSCalendar.currentCalendar()

    
    
    var Photos :[AnyObject] = []
    
    
    @IBOutlet weak var imagePreview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        }
    
    
    @IBAction func get(sender: AnyObject) {
        
        var query = PFQuery(className:"Photo")
        query.whereKey("approved", equalTo:"true")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                NSLog("Successfully retrieved \(objects.count) scores.")
                // Do something with the found objects
                for object in objects {
                    NSLog("%@", object.objectId)
                }
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
            }
        }
    }
}