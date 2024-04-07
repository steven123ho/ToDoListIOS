//
//  ContactsViewController.swift
//  My Contact List
//
//  Created by user246123 on 3/5/24.
//

import UIKit
import CoreData

class ContactsViewController: UIViewController, UITextFieldDelegate, DateControllerDelegate {
    

    var currentContact: Contact?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var sgmtEditMode: UISegmentedControl!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var btnChange: UIButton!
    @IBOutlet weak var lblBirthdate: UILabel!
    @IBOutlet weak var priorityPicker: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Populates data from selecting a contact
        if currentContact != nil {
            txtName.text = currentContact!.subject
            txtAddress.text = currentContact!.streetAddress
            let formatter = DateFormatter()
            
            //populating for date by first formatting date
            formatter.dateStyle = .short
            if currentContact!.dueDate != nil {
                lblBirthdate.text = formatter.string(from: currentContact!.dueDate!)
            }
            
            //populate priority segment picker
            if currentContact!.priority == "Low" {
                priorityPicker.selectedSegmentIndex = 0
            } else if currentContact!.priority == "Medium" {
                priorityPicker.selectedSegmentIndex = 1
            } else {
                priorityPicker.selectedSegmentIndex = 2
            }
        }
        
        changeEditMode(self)
        
        let textFields: [UITextField] = [txtName, txtAddress]
        
        for textfield in textFields {
            textfield.addTarget(self, 
                                action: #selector(UITextFieldDelegate.textFieldShouldEndEditing(_:)),
                                for: UIControl.Event.editingDidEnd)
        }
        
        priorityPicker.addTarget(self, action: #selector(priorityShouldEndEditing(_:)), for: .valueChanged)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if currentContact == nil {
            let context = appDelegate.persistentContainer.viewContext
            currentContact = Contact(context: context)
        }
        currentContact?.subject = txtName.text
        currentContact?.streetAddress = txtAddress.text
        
        return true
    }
    
    @objc func priorityShouldEndEditing (_ segmentControl: UISegmentedControl) ->Bool {
        if priorityPicker.selectedSegmentIndex == 0 {
            currentContact?.priority = "Low"
        } else if priorityPicker.selectedSegmentIndex == 1 {
            currentContact?.priority = "Medium"
        } else {
            currentContact?.priority = "High"
        }
        return true
    }
    
    
    
    @objc func saveContact() {
        appDelegate.saveContext()
        sgmtEditMode.selectedSegmentIndex = 0
        changeEditMode(self)
    }
    
    //Implementing DateControllerDelegate Protocol function for Changing birthdate
    func dateChanged(date: Date) {
        if currentContact == nil {
            let context = appDelegate.persistentContainer.viewContext
            currentContact = Contact(context: context)
        }
        currentContact?.dueDate = date
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        lblBirthdate.text = formatter.string(from: date)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "segueContactDate") {
            let dateController = segue.destination as! DateViewController
            dateController.delegate = self
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    @IBAction func changeEditMode(_ sender: Any) {
        let textFields: [UITextField] = [txtName, txtAddress]
        
        if sgmtEditMode.selectedSegmentIndex == 0 {
            for textField in textFields {
                textField.isEnabled = false
                textField.borderStyle = UITextField.BorderStyle.none
            }
            btnChange.isHidden = true
            priorityPicker.isEnabled = false
            navigationItem.rightBarButtonItem = nil
        } else if sgmtEditMode.selectedSegmentIndex == 1 {
            for textField in textFields {
                textField.isEnabled = true
                textField.borderStyle = UITextField.BorderStyle.roundedRect
            }
            btnChange.isHidden = false
            priorityPicker.isEnabled = true
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.saveContact))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotification()
    }

    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func unregisterKeyboardNotification() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardDidShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            var contentInset = self.scrollView.contentInset
            contentInset.bottom = keyboardSize.height
            
            self.scrollView.contentInset = contentInset
            self.scrollView.scrollIndicatorInsets = contentInset
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        var contentInset = self.scrollView.contentInset
        contentInset.bottom = 0
        
        self.scrollView.contentInset = contentInset
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
