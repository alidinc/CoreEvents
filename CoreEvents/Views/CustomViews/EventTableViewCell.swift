//
//  EventTableViewCell.swift
//  CoreEvents
//
//  Created by Ali Dinç on 30/07/2021.
//

import UIKit

protocol EventCellAttendedDelegate: AnyObject {
    func isAttendedButtonTapped(wasAttended: Bool, event: Event)
}

class EventTableViewCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var isAttendedButton: UIButton!
    

    // MARK: - Properties
    var event: Event? {
        didSet {
            updateCellViews()
        }
    }

    weak var delegate: EventCellAttendedDelegate?
    private var wasAttendedToday = false
    
  
    // MARK: - Actions
    
    @IBAction func isAttendedButtonTapped(_ sender: Any) {
        guard let event = event else { return }
        wasAttendedToday.toggle()
        delegate?.isAttendedButtonTapped(wasAttended: wasAttendedToday, event: event)
    }
    
    
    // MARK: - Helpers
    
    func updateCellViews() {
        guard let event = event else { return }
        wasAttendedToday = event.wasAttendedToday()
        nameLabel.text = event.name
        let imageName = wasAttendedToday ? "seal.fill" : "seal"
        isAttendedButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
}


