//
//  EventDetailViewController.swift
//  CoreEvents
//
//  Created by Ali Dinç on 30/07/2021.
//

import UIKit

class EventDetailViewController: UIViewController {

    // MARK: - Properties
    var event: Event?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDetailViews()
        nameTextField.delegate = self
    }

    // MARK: - Outlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // MARK: - Actions
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        guard let name = nameTextField.text, !name.isEmpty else { return }
        
        if let event = event {
            EventController.shared.updateEvent(event: event, newName: name, newDate: datePicker.date)
        } else {
            EventController.shared.createEvent(name: name, date: datePicker.date)
        }
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helpers
    
    func updateDetailViews() {
        guard let event = event else { return }
        nameTextField.text = event.name
        datePicker.date = event.date ?? Date()
    }
}


extension EventDetailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.endEditing(true)
        textField.resignFirstResponder()
        return true
    }
}
