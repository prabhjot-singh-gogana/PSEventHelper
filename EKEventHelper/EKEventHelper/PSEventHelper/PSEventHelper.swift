//
//  CalendarEvent.swift
//  LocalLift
//
//  Created by prabhjot singh on 3/2/16.
//  Copyright © 2016 prabhjot singh. All rights reserved.
//

import UIKit
import EventKit

let PRODUCT_NAME = "Any_Product_Name"

class PSEventHelper: EKEventStore {

    override init() {
        super.init()
        determineStatus()
    }
    
	private func determineStatus() -> Bool {

		let type = EKEntityType.Event
		let stat = EKEventStore.authorizationStatusForEntityType(type)
		switch stat {
		case .Authorized:
			return true
		case .NotDetermined:
			self.requestAccessToEntityType(type, completion: { _, _ in })
			return false
		case .Restricted:
			return false
		case .Denied:
            print("Need Authorization. Wouldn't you like to authorize this app to use your Calendar?")
			return false
		}
	}

	/**
	 This method is used to create the localift calendar if already created
	 */
	func createCalendar() -> EKCalendar? {
		if !self.determineStatus() {
			print("not authorized")
			return nil
		}
    // if already exit then it will return the calendar
		if let calendar: EKCalendar? = self.calendarWithName(PRODUCT_NAME) where calendar != nil {
			return calendar
		}
		let cal = EKCalendar(forEntityType: .Event, eventStore: self)
		cal.source = self.defaultCalendarForNewEvents.source // It will fetch the default source if iCloud is on the it will fetch the iCloud source and save there
		cal.title = PRODUCT_NAME
    // ready to save the new calendar into the eventStore!
		do {
			try self.saveCalendar(cal, commit: true)
		} catch {
			print("save calendar error: \(error)")
			return nil
		}

    // if already exit then it will return the calendar otherwise nil
		if let calendar: EKCalendar? = self.calendarWithName(PRODUCT_NAME) {
			return calendar
		} else {
			return nil
		}
	}

	/**
	 this method is used to fetch the calendar

	 - parameter name: any string which is exist on calendar
	 - returns: calendar object
	 */
	private func calendarWithName(name: String) -> EKCalendar? {
		let cals = self.calendarsForEntityType(.Event)
		return cals.filter { $0.title == name }.first
	}

	/**
	 This method is used to create the Simple Event

	 - parameter title: event title which will show on iCal Event
	 - parameter notes: notes is desciption of event which will show on iCal Event
	 - parameter dates: dates is the tupel where satrt and end date will be set
	 */
	func createSimpleEvent (title: String?, notes: String?, andWithDates dates: (startDate: NSDate?, endDate: NSDate?)) {
		if !self.determineStatus() {
			print("not authorized")
			return
		}
		guard let cal = self.createCalendar() else {
			print("failed to find calendar")
			return
		}
		let ev = EKEvent(eventStore: self)
		ev.title = title == nil ? "" : title!
		ev.notes = notes == nil ? "" : notes!
		ev.calendar = cal
		(ev.startDate, ev.endDate) = (dates.startDate == nil ? NSDate() : dates.startDate!, dates.endDate == nil ? NSDate() : dates.endDate!)
		do {
			try self.saveEvent(ev, span: .ThisEvent, commit: true)
		} catch {
			print("save simple event \(error)")
			return
		}
		print("no errors")
	}

	/**
	 This method is used to create the Reccuring Event

	 - parameter title:         event title which will show on iCal Event
	 - parameter notes:         notes is desciption of event which will show on iCal Event
	 - parameter dates:         dates is the tupel where satrt and end date will be set
	 - parameter frequencyType: frequncytype is enum which can be .Daily,.Weekly,.Monthly,.Yearly
	 */
	func createRecurringEvent (title: String?, notes: String?, withDates dates: (startDate: NSDate?, endDate: NSDate?), andWithFrequencyType frequencyType: EKRecurrenceFrequency = .Daily) {
		if !self.determineStatus() {
			print("not authorized")
			return
		}
		guard let cal = self.createCalendar() else {
			print("failed to find calendar")
			return
		}
    // Using below code for fortnightly
		let recursRule = EKRecurrenceRule(recurrenceWithFrequency:frequencyType , interval: 1, end: EKRecurrenceEnd(endDate: dates.endDate == nil ? NSDate() : dates.endDate!))
		let ev = EKEvent(eventStore: self)
		ev.title = title == nil ? "" : title!
		ev.addRecurrenceRule(recursRule)
		ev.calendar = cal
		ev.notes = notes == nil ? "" : notes!
    // need a start date and end date
		(ev.startDate, ev.endDate) = (dates.startDate == nil ? NSDate() : dates.startDate!, dates.startDate == nil ? NSDate() : dates.startDate!)

		do {
			try self.saveEvent(ev, span: .FutureEvents, commit: true)
		} catch {
			print("save recurring event \(error)")
			return
		}
		print("no errors")

	}

}
