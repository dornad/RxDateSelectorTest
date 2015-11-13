//
//  ViewModelTest.swift
//  Test
//
//  Created by Daniel Rodriguez on 11/12/15.
//  Copyright © 2015 PaperlessPost. All rights reserved.
//

import UIKit

public class ViewModel {
    
    public var startDate: NSDate?
    public var endDate: NSDate?
    public var timeZone: NSTimeZone
    public var allDay: Bool
    public var selectedRowType: DateSelectorSectionType?
    
    public let dateFormatter:NSDateFormatter = NSDateFormatter()
    
    required public init(startDate:NSDate? = nil, endDate:NSDate? = nil, timeZone:NSTimeZone = NSTimeZone.localTimeZone(), allDay: Bool=false) {
        
        self.startDate = startDate
        self.endDate = endDate
        self.timeZone = timeZone
        self.allDay = allDay
        
        if startDate == nil && endDate == nil {
            self.startDate = NSDate()
            self.selectedRowType = .StartDate
        }
        
        self.dateFormatter.dateFormat = "EEE, MMM d, yyyy h:mm a"
    }
}

extension ViewModel {
    
    public var rows:[RowDesc] {
        
        return [
            (.StartDate,    self.startDate == nil ? .Missing : .Present),
            (.EndDate,      self.endDate == nil ? .Missing : .Present),
            (.TimeZone,     .Present),
            (.AllDay,       .Missing)
        ]
    }
    
    public func getStringForRowType(type:DateSelectorSectionType) -> String {
        
        if type.isDateType() {
            
            if let date = (type == .StartDate) ? self.startDate : self.endDate {
                // we have a date value, return it.
                return self.dateFormatter.stringFromDate(date)
            }
            // Special case: Return the current date if the selectedType is the value in the event pipe
            if let selectedRowType = self.selectedRowType {
                if selectedRowType == type {
                    return self.dateFormatter.stringFromDate(NSDate())
                }
            }
            // Finally, return the "empty" string
            return "\"empty\""
        }
        else {
            return self.timeZone.name
        }
    }
}
