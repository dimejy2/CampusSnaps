//
//  PreviewViewController.swift
//  CampusSnaps
//
//  Created by Oladimeji Abidoye on 2/14/15.
//  Copyright (c) 2015 Dimeji Abidoye. All rights reserved.
//

import UIKit

class PreviewViewController : UIViewController {
    
    @IBOutlet weak var imagePreview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let (_, fullFileName) = ViewController.getSnapFileName()
        imagePreview.image = UIImage(contentsOfFile: fullFileName)
    }
    
    
    
    @IBAction func sendPhoto(segue:UIStoryboardSegue) {
        println("Sending photo")
        
        let (fileName, snapFileName) = ViewController.getSnapFileName()
//        let friendsViewController = segue.sourceViewController as FriendsViewController
        
        // Upload to parse
        var uploadFile = PFFile(name: fileName, contentsAtPath: snapFileName)
        
        var photo = PFObject(className : "Photo" )
        photo.setObject( uploadFile, forKey: "myPicture")
        
        photo.saveInBackgroundWithBlock { (success:Bool, _) in
            if success {
                println("Photo uploaded to Parse")
            } else {
                // Show very sad panda
                println("FAILURE")
            }
        }

    }

    
    func getPhotos() {
        
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