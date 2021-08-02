//
//  EventsTableViewController.swift
//  CoreEvents
//
//  Created by Ali Dinç on 30/07/2021.
//

import UIKit

class EventsTableViewController: UITableViewController {
    
    // MARK: - Properties
    var filteredEvents = [[Event]]()
    let searchController = UISearchController(searchResultsController: nil)
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EventController.shared.fetchEvents()
        title = "Core Events"
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: NSNotification.Name(UIApplication.didBecomeActiveNotification.rawValue), object: nil)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Events to Attend"
        searchController.searchBar.returnKeyType = .go
        searchController.searchBar.barStyle = .black
        searchController.searchBar.searchTextField.backgroundColor = .label
        navigationItem.searchController = searchController
        definesPresentationContext = true
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
    
    func filterContent(searchText: String) {
        if searchText.count > 0 {
            filteredEvents = EventController.shared.events.map { $0.filter { $0.name?.contains(searchText) ?? false } }
        }
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.toEventDetailVC {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destination = segue.destination as? EventDetailViewController else { return }
            let event = filteredEvents[indexPath.section][indexPath.row]
            destination.event = event
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension EventsTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return isFiltering ? filteredEvents.count : EventController.shared.events.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? filteredEvents[section].count : EventController.shared.events[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellID, for: indexPath) as? EventTableViewCell else { return UITableViewCell() }
        
        let eventToSend = isFiltering ? filteredEvents[indexPath.section][indexPath.row] : EventController.shared.events[indexPath.section][indexPath.row]
        
        cell.delegate = self
        cell.event = eventToSend
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        let label = UILabel(frame: CGRect(x: 15, y: 10, width: view.frame.width * 0.8, height: 20))
        
        var sectionHeaderText: String {
                switch section {
                case 0:
                    return "Not to Attend"
                case 1:
                    return "Events to Attend"
                default:
                    return "Events"
                }
        }

        label.text = sectionHeaderText
        label.textColor = .white
        label.font = UIFont(name: "Galvji", size: 14)
        headerView.backgroundColor = .label
        headerView.addSubview(label)
        return headerView
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.height / 12
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let eventToDelete = isFiltering ? filteredEvents[indexPath.section][indexPath.row] : EventController.shared.events[indexPath.section][indexPath.row]
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
extension EventsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContent(searchText: searchBar.text!)
    }
}


