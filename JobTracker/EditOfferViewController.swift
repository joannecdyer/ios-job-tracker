//
//  EditOfferViewController.swift
//  JobTracker
//
//  Created by Joanne Dyer on 3/6/15.
//  Copyright (c) 2015 Joanne Maynard. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import CoreData

class EditOfferViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var dateReceivedBox: UITextField!
    @IBOutlet weak var salaryBox: UITextField!
    @IBOutlet weak var notesView: UITextView!
    
    var loadedBasic: JobBasic!
    
    private let datePickerView = UIDatePicker()
    private var salary: NSNumber?
    
    //MARK:- UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Offer"
        
        datePickerView.datePickerMode = UIDatePickerMode.Date
        datePickerView.addTarget(self, action: "updateDate", forControlEvents: UIControlEvents.ValueChanged)
        dateReceivedBox.inputView = datePickerView
        
        if let offer = loadedBasic.offer {
            title = "Edit Offer"
            notesView.text = offer.notes
            
            salary = offer.salary as NSNumber?
            if salary == nil {
                salaryBox.text = ""
            } else {
                salaryBox.text = Common.standardCurrencyFormatter.stringFromNumber(salary!)
            }
            
            let savedDate = offer.dateReceived as NSDate
            dateReceivedBox.text = Common.standardDateFormatter.stringFromDate(savedDate)
            datePickerView.date = savedDate
        } else {
            let today = datePickerView.date
            dateReceivedBox.text = Common.standardDateFormatter.stringFromDate(today)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //show toolbar only on edit offer (not create new)
        if loadedBasic.offer != nil {
            self.navigationController?.toolbarHidden = false
        } else {
            self.navigationController?.toolbarHidden = true
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.toolbarHidden = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is ShowDetailViewController {
            let destination = segue.destinationViewController as! ShowDetailViewController
            destination.loadedBasic = loadedBasic
        }
    }
    
    //MARK:-
    
    func updateDate() {
        let date = datePickerView.date
        dateReceivedBox.text = Common.standardDateFormatter.stringFromDate(date)
    }

    //MARK:- UITableViewDelegate
    
    //sets it up so that wherever in the cell they select the textbox starts editing.
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            dateReceivedBox.becomeFirstResponder()
        case 1:
            salaryBox.becomeFirstResponder()
        case 2:
            notesView.becomeFirstResponder()
        default:
            break
        }
    }
    
    //MARK:- UITextFieldDelegate
    
    //only called by salary text field
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newSalary = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        let decimalSeparator = Common.standardCurrencyFormatter.decimalSeparator!
        let expression = "^\\d*\\\(decimalSeparator)?\\d{0,2}$"
        let regex = try! NSRegularExpression(pattern: expression, options: [])
        let numberOfMatches = regex.numberOfMatchesInString(newSalary, options: [], range: NSMakeRange(0, newSalary.characters.count))
        if numberOfMatches == 0 {
            return false
        }
        if newSalary == "" {
            salary = nil
        } else {
            salary = Common.standardDecimalFormatter.numberFromString(newSalary)
        }
        return true
    }
    
    //see above
    func textFieldDidBeginEditing(textField: UITextField) {
        if salary != nil {
            textField.text = Common.standardDecimalFormatter.stringFromNumber(salary!)
        }
    }
    
    //see above
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text == "" {
            salary = nil
            return
        }
        salary = Common.standardDecimalFormatter.numberFromString(textField.text!)
        salaryBox.text = Common.standardCurrencyFormatter.stringFromNumber(salary!)
    }
    
    //MARK:- IBActions
    
    @IBAction func cancelClicked(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func saveClicked(sender: UIBarButtonItem) {
        saveDetails()
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func deleteClicked(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        let deleteAction = UIAlertAction(title: "Delete Offer", style: .Destructive, handler: { (action) in self.deleteOffer()
        })
        alertController.addAction(deleteAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK:- Core Data Changers
    
    private func saveDetails() {
        let managedContext = Common.managedContext
        var offer: JobOffer
        if loadedBasic.offer != nil {
            offer = loadedBasic.offer!
        } else {
            offer = NSEntityDescription.insertNewObjectForEntityForName("JobOffer", inManagedObjectContext: managedContext) as! JobOffer
            managedContext.insertObject(offer)
            loadedBasic.offer = offer
            offer.basic = loadedBasic
        }
        
        offer.notes = notesView.text
        offer.dateReceived = Common.standardDateFormatter.dateFromString(dateReceivedBox.text!)!
        offer.salary = salary
        
        do {
            try managedContext.save()
        } catch {
            print("Could not save.")
        }
    }
    
    private func deleteOffer() {
        if let offer = loadedBasic.offer {
            loadedBasic.offer = nil
            
            do {
                try Common.managedContext.save()
            } catch {
                print("Could not save.")
            }
            navigationController?.popViewControllerAnimated(true)
        }
    }
}
