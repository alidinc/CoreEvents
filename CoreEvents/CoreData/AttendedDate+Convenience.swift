//
//  AttendedDate+Convenience.swift
//  CoreEvents
//
//  Created by Ali Dinç on 30/07/2021.
//

import CoreData

extension AttendedDate {
    
    @discardableResult
    convenience init(date: Date, event: Event, context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        self.date = date
        self.event = event
    }
}


