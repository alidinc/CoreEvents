//
//  EventsTableViewController.swift
//  CoreEvents
//
//  Created by Ali Dinç on 30/07/2021.
//

import UIKit

class EventsTableViewController: UITableViewController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EventController.shared.fetchEvents()
        title = "Core Events"
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: NSNotification.Name(UIApplication.didBecomeActiveNotification.rawValue), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    // MARK: - Helpers
    
    @objc func reloadTableView() {
        EventController.shared.fetchEvents()
        self.tableView.reloadData()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.toEventDetailVC {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destination = segue.destination as? EventDetailViewController else { return }
            let event = EventController.shared.events[indexPath.section][indexPath.row]
            destination.event = event
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension EventsTableViewController {
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return EventController.shared.events.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EventController.shared.events[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellID, for: indexPath) as? EventTableViewCell else { return UITableViewCell() }
        
        let eventToSend = EventController.shared.events[indexPath.section][indexPath.row]
        cell.delegate = self
        cell.event = eventToSend
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Not to Attend"
        case 1:
            return "Events to Attend"
        default:
            return "Events"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.height / 6
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let eventToDelete = EventController.shared.events[indexPath.section][indexPath.row]
            EventController.shared.deleteEvent(event: eventToDelete)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

extension EventsTableViewController: EventCellAttendedDelegate {
    
    
    func isAttendedButtonTapped(wasAttended: Bool, event: Event) {
        EventController.shared.updateAttendedStatus(wasAttended, event: event)
        tableView.reloadData()
    }
}
