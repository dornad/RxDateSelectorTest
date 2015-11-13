//
//  ViewModelTest.swift
//  Test
//
//  Created by Daniel Rodriguez on 11/12/15.
//  Copyright © 2015 PaperlessPost. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class RxViewModel {
    
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

extension RxViewModel {
    
    public var rows:Driver<[RowDesc]> {
        
        let v1:Variable<NSDate?> = Variable(startDate)
        let v2:Variable<NSDate?> = Variable(endDate)
        
        return combineLatest(v1, v2) { d1, d2 -> [RowDesc] in
            return [
                (.StartDate,    d1 == nil ? .Missing : .Present),
                (.EndDate,      d2 == nil ? .Missing : .Present),
                (.TimeZone,     .Present),
                (.AllDay,       .Missing)
            ]
        }
        .map { (rows:[RowDesc]) -> [RowDesc] in
            return rows
        }
        .asDriver(onErrorJustReturn: [])
    }
    
    public func getStringObservableForRowType(type:DateSelectorSectionType) -> Observable<String> {
        
        if type.isDateType() {
            
            let v1 = (type == .StartDate) ? Variable(startDate) : Variable(endDate)
            let v2 = Variable(selectedRowType)
            
            return combineLatest(v1, v2) { date, _ in return date }
                .map{ date -> String in
                    if let date = date {
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
        }
        else {
            return Variable(timeZone).map { return $0.name }
        }
    }
    
    public func getAllDayObservable() -> Observable<Bool> {
        return Variable(allDay).asObservable()
    }
    
}
