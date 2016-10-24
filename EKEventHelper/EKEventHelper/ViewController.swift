//
//  ViewController.swift
//  EKEventHelper
//
//  Created by prabhjot singh on 10/21/16.
//  Copyright © 2016 Prabhjot Singh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtNotes: UITextField!
    @IBOutlet weak var btnCreateEvent: UIButton!
    @IBOutlet weak var lblSDate: UILabel!
    @IBOutlet weak var lblEDate: UILabel!
    
    let startDate = NSDate()
    let endDate = NSDate().dateByAddingDays(1)
    let calendarEvent = PSEventHelper() // intialaizing object intially for access

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        lblSDate.text = formatter.stringFromDate(startDate)
        lblEDate.text = formatter.stringFromDate(endDate)
        
    }
    
    @IBAction func toCreateEvent(sender: UIButton) {
        
        calendarEvent.createSimpleEvent(txtTitle.text, notes: txtNotes.text, andWithDates: (startDate, endDate))
        
//        calendar.createRecurringEvent(txtTitle.text, notes: txtNotes.text, withDates: (startDate, endDate), andWithFrequencyType: .Weekly)
    }

}

extension NSDate {
    func dateByAddingDays(days: Int) -> NSDate
    {
        let dateComp = NSDateComponents()
        dateComp.day = days
        return NSCalendar.currentCalendar().dateByAddingComponents(dateComp, toDate: self, options: NSCalendarOptions(rawValue: 0))!
    }
}

