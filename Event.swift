//
//  Event.swift
//  Code Blue
//
//  Created by Erik Santana on 4/12/15.
//  Copyright (c) 2015 Erik Santana. All rights reserved.
//

import Foundation
import CoreData

class Event: NSManagedObject
{

    @NSManaged var name: String
    
    class func createInManagedObjectContext(_ moc: NSManagedObjectContext, name: String) -> Event
    {
        let newItem = NSEntityDescription.insertNewObject(forEntityName: "Event", into: moc) as! Event
        newItem.name = name
        return newItem
    }

}
