//
//  EventController.swift
//  CoreEvents
//
//  Created by Ali Dinç on 30/07/2021.
//

import CoreData


class EventController {
    
    // MARK: - Properties
    static let shared = EventController()
    let eventScheduler = EventScheduler()
    
    var attendedEvents = [Event]()
    var notAttendedEvents = [Event]()
    
    var events: [[Event]] { [notAttendedEvents, attendedEvents] }
    
    private lazy var fetchRequest: NSFetchRequest<Event> = {
        let request = NSFetchRequest<Event>(entityName: "Event")
        request.predicate = NSPredicate(value: true)
        return request
    }()
    
    private init() { }
    
    // MARK: - CRUD Methods
    
    func createEvent(name: String, date: Date) {
        let newEvent = Event(name: name, date: date)
        notAttendedEvents.append(newEvent)
        saveToPersistentStore()
        eventScheduler.scheduleNotifications(for: newEvent)
    }
    
    func updateEvent(event: Event, newName: String, newDate: Date) {
        event.name = newName
        event.date = newDate
        saveToPersistentStore()
        
        if event.isAttended {
            eventScheduler.cancelNotifications(for: event)
        } else if !event.isAttended {
            eventScheduler.scheduleNotifications(for: event)
        }
    }
    
    func updateAttendedStatus(_ wasAttended: Bool, event: Event) {
        
        if wasAttended {
            AttendedDate(date: Date(), event: event)
            if let index = notAttendedEvents.firstIndex(of: event) {
                notAttendedEvents.remove(at: index)
                attendedEvents.append(event)
                
                eventScheduler.cancelNotifications(for: event)
            }
        } else {
            
            let mutableAttendedDates = event.mutableSetValue(forKey: "attendedDates")
            
            if let attendedDate = (mutableAttendedDates as? Set<AttendedDate>)?.first(where: { attendedDate in
                guard let date = attendedDate.date else { return false }
                return Calendar.current.isDate(date, inSameDayAs: Date())
            }) {
                mutableAttendedDates.remove(attendedDate)
                
                if let index = attendedEvents.firstIndex(of: event) {
                    attendedEvents.remove(at: index)
                    notAttendedEvents.append(event)
                    
                    eventScheduler.scheduleNotifications(for: event)
                }
            }
        }
            saveToPersistentStore()
    }
    
    func fetchEvents() {
        let events = (try? CoreDataStack.context.fetch(fetchRequest)) ?? []
        notAttendedEvents = events.filter { !$0.wasAttendedToday() }
        attendedEvents = events.filter { $0.wasAttendedToday() }
    }
    
    func deleteEvent(event: Event) {
        if let index = notAttendedEvents.firstIndex(of: event) {
            notAttendedEvents.remove(at: index)
        } else if let index = attendedEvents.firstIndex(of: event) {
            attendedEvents.remove(at: index)
        }
        
        CoreDataStack.context.delete(event)
        saveToPersistentStore()
        eventScheduler.cancelNotifications(for: event)
    }
    
    
    func markEventAsAttended(with id: String) {
        
        guard let uuid = UUID(uuidString: id),
              let event = notAttendedEvents.first(where: { $0.id == uuid.uuidString }) else { return }
        
        AttendedDate(date: Date(), event: event)
        CoreDataStack.saveContext()
    }
    
    func saveToPersistentStore() {
        CoreDataStack.saveContext()
    }
}


