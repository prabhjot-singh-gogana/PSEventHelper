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
    
    let startDate = Date()
    let endDate = Date().dateByAddingDays(1)
    let calendarEvent = PSEventHelper() // intialaizing object intially for access

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        lblSDate.text = formatter.string(from: startDate)
        lblEDate.text = formatter.string(from: endDate)
        
    }
    
    @IBAction func toCreateEvent(_ sender: UIButton) {
        
        calendarEvent.createSimpleEvent(txtTitle.text, notes: txtNotes.text, andWithDates: (startDate, endDate))
        
//        calendar.createRecurringEvent(txtTitle.text, notes: txtNotes.text, withDates: (startDate, endDate), andWithFrequencyType: .Weekly)
    }

}

extension Date {
    func dateByAddingDays(_ days: Int) -> Date
    {
        var dateComp = DateComponents()
        dateComp.day = days
        return (Calendar.current as NSCalendar).date(byAdding: dateComp, to: self, options: NSCalendar.Options(rawValue: 0))!
    }
}

