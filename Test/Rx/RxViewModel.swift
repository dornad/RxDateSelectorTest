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
    
    // Properties
    
    public var startDate:Variable<NSDate?>
    public var endDate:Variable<NSDate?>
    public var timeZone:Variable<NSTimeZone>
    public var allDay:Variable<Bool>
    public var selectedRowType:Variable<SectionType?>
    
    // Helpers and Transformers
    
    public let dateFormatter:NSDateFormatter = NSDateFormatter()
    
    // Init
    
    required public init(startDate:NSDate? = nil, endDate:NSDate? = nil, timeZone:NSTimeZone = NSTimeZone.localTimeZone(), allDay: Bool=false) {
        
        self.dateFormatter.dateFormat = "EEE, MMM d, yyyy h:mm a"
        
        self.startDate = Variable(NSDate())
        self.endDate = Variable(NSDate())
        self.timeZone = Variable(timeZone)
        self.allDay = Variable(allDay)
        self.selectedRowType = Variable(nil)
        
    }
}

extension RxViewModel {
    
    public var rows:Driver<[RowDesc]> {
        
        return combineLatest(self.startDate,self.endDate,self.timeZone,self.selectedRowType){ d1, d2, _, selected -> [RowDesc] in
            
            var rows:[RowDesc] = [
                (.StartDate,    .Missing),//d1 == nil ? .Missing : .Present),
                (.EndDate,      .Missing),//d2 == nil ? .Missing : .Present),
                (.TimeZone,     .Present),
                (.AllDay,       .Missing)
            ]
            
            if let selected = selected {
                
                rows[selected.toInt()] = (selected, .Selected)
            }
            return rows
        }
        .asDriver(onErrorJustReturn:[])
        
    }
    
    public func getStringObservableForRowType(type:DateSelectorSectionType) -> Observable<String> {        
        return Variable( getStringForRowType(type) ).asObservable()
    }
    
    private func getStringForRowType(type:SectionType) -> String {
        
        if type.isDateType() {
            
            // Special case: Return the current date if the selectedType is the value in the event pipe
            if self.selectedRowType.value == type {
                return self.dateFormatter.stringFromDate(NSDate())
            }
            
            if let date = (type == .StartDate) ? self.startDate.value : self.endDate.value {
                return self.dateFormatter.stringFromDate(date)
            }
            
            // Finally, return the "empty" string
            return "\"empty\""
        }
        else {
            return self.timeZone.value.name
        }
    }
}
