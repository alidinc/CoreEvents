//
//  Event+Convenience.swift
//  CoreEvents
//
//  Created by Ali Dinç on 30/07/2021.
//

import CoreData

extension Event {
    
    @discardableResult
    convenience init(name: String, isAttended: Bool = false, date: Date, context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        self.name = name
        self.date = date
        self.isAttended = isAttended
        self.id = UUID().uuidString
    }
    
    
    func wasAttendedToday() -> Bool {
        guard let _ = (attendedDates as? Set<AttendedDate>)?.first(where: { attendedDate in
            guard let day = attendedDate.date else { return false }
            return Calendar.current.isDate(day, inSameDayAs: Date())
        }) else { return false }
        return true
    }
}
