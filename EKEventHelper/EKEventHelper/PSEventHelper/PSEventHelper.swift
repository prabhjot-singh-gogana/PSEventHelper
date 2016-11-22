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
        _ = determineStatus()
    }
    
	fileprivate func determineStatus() -> Bool {

		let type = EKEntityType.event
		let stat = EKEventStore.authorizationStatus(for: type)
		switch stat {
		case .authorized:
			return true
		case .notDetermined:
			self.requestAccess(to: type, completion: { _, _ in })
			return false
		case .restricted:
			return false
		case .denied:
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
		if let calendar: EKCalendar = self.calendarWithName(PRODUCT_NAME) {
			return calendar
		}
		let cal = EKCalendar(for: .event, eventStore: self)
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
		if let calendar: EKCalendar = self.calendarWithName(PRODUCT_NAME) {
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
	fileprivate func calendarWithName(_ name: String) -> EKCalendar? {
		let cals = self.calendars(for: .event)
		return cals.filter { $0.title == name }.first
	}

	/**
	 This method is used to create the Simple Event

	 - parameter title: event title which will show on iCal Event
	 - parameter notes: notes is desciption of event which will show on iCal Event
	 - parameter dates: dates is the tupel where satrt and end date will be set
	 */
	func createSimpleEvent (_ title: String?, notes: String?, andWithDates dates: (startDate: Date?, endDate: Date?)) {
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
		(ev.startDate, ev.endDate) = (dates.startDate == nil ? Date() : dates.startDate!, dates.endDate == nil ? Date() : dates.endDate!)
		do {
			try self.save(ev, span: .thisEvent, commit: true)
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
	func createRecurringEvent (_ title: String?, notes: String?, withDates dates: (startDate: Date?, endDate: Date?), andWithFrequencyType frequencyType: EKRecurrenceFrequency = .daily) {
		if !self.determineStatus() {
			print("not authorized")
			return
		}
		guard let cal = self.createCalendar() else {
			print("failed to find calendar")
			return
		}
    // Using below code for fortnightly
		let recursRule = EKRecurrenceRule(recurrenceWith:frequencyType , interval: 1, end: EKRecurrenceEnd(end: dates.endDate == nil ? Date() : dates.endDate!))
		let ev = EKEvent(eventStore: self)
		ev.title = title == nil ? "" : title!
		ev.addRecurrenceRule(recursRule)
		ev.calendar = cal
		ev.notes = notes == nil ? "" : notes!
    // need a start date and end date
		(ev.startDate, ev.endDate) = (dates.startDate == nil ? Date() : dates.startDate!, dates.startDate == nil ? Date() : dates.startDate!)

		do {
			try self.save(ev, span: .futureEvents, commit: true)
		} catch {
			print("save recurring event \(error)")
			return
		}
		print("no errors")

	}

}
