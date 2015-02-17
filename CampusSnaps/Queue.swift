//
//  Queue.swift
//  CampusSnaps
//
//  Created by Oladimeji Abidoye on 2/14/15.
//  Copyright (c) 2015 Dimeji Abidoye. All rights reserved.
//

import Foundation







public class Queue<T> {
    
    private var top: Node<T>! = Node<T>()
    
    //enqueue the specified object
    func enQueue(var key: T) {
        
        //check for the instance
        if (top == nil) {
            top = Node()
        }
        
        //establish the top node
        if (top.key == nil) {
            top.key = key;
            return
        }
        
        var childToUse: Node<T> = Node<T>()
        var current: Node = top
        
        
        //cycle through the list of items to get to the end.
        while (current.next != nil) {
            current = current.next!
        }
        
        
        //append a new item
        childToUse.key = key;
        current.next = childToUse;
        
    }
    
    func deQueue() -> T? {
        
        //determine if the key or instance exists
        let topitem: T? = self.top?.key
        
        if (topitem == nil) {
            return nil
        }
        
        //retrieve and queue the next item
        var queueitem: T? = top.key!
        
        
        //use optional binding
        if let nextitem = top.next {
            top = nextitem
        }
        else {
            top = nil
        }
        
        return queueitem
    }
    
    //check for the presence of a value
    func isEmpty() -> Bool {
        
        //determine if the key or instance exist
        if let topitem: T = self.top?.key {
            return false
        }
            
        else {
            return true
        }
        
    }
    
    
    //retrieve the top most item
    func peek() -> T? {
        return top.key!
    }
    
}