//
//  CoreDataStack.swift
//  CoreEvents
//
//  Created by Ali Dinç on 30/07/2021.
//

import CoreData

enum CoreDataStack {
    static let container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreEvents")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    static var context: NSManagedObjectContext { return container.viewContext }
    
    static func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context \(error)")
            }
        }
    }
}
