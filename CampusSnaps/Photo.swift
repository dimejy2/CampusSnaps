//
//  Photo.swift
//  CampusSnaps
//
//  Created by Oladimeji Abidoye on 2/14/15.
//  Copyright (c) 2015 Dimeji Abidoye. All rights reserved.
//

import Foundation


class Photo : PFObject, PFSubclassing {
    
    override class func load() {
        self.registerSubclass()
    }
    
    class func parseClassName() -> String! {
        return "Photo"
    }
    
    var image: PFFile? {
        get { return objectForKey("image") as? PFFile }
        set { setObject(newValue, forKey: "image") }
    }
    
    
    
}