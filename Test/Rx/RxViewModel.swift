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

// MARK: ViewModel - Properties, transformers and initializers

public class RxViewModel {
    
    // Properties
    
    // technically these properties are reactive, but we are listing them here
    // because they hold our data.
    
    public var startDate:Variable<NSDate?>
    public var endDate:Variable<NSDate?>
    public var timeZone:Variable<NSTimeZone>
    public var allDay:Variable<Bool>
    public var selectedRowType:Variable<SectionType?>
    
    // Helpers and Transformers
    
    let dateFormatter:NSDateFormatter = NSDateFormatter()
    
    // Initializers
    
    required public init(startDate:NSDate? = nil, endDate:NSDate? = nil, timeZone:NSTimeZone = NSTimeZone.localTimeZone(), allDay: Bool=false) {
        
        self.dateFormatter.dateFormat = "EEE, MMM d, yyyy h:mm a"
        
        self.startDate = Variable(startDate)
        self.endDate = Variable(endDate)
        self.timeZone = Variable(timeZone)
        self.allDay = Variable(allDay)
        self.selectedRowType = Variable(nil)
        
        if startDate == nil && endDate == nil {
            self.startDate.value = NSDate()
            self.selectedRowType.value = .StartDate
        }
    }
}

// MARK: ViewModel - Reactive methods and properties

extension RxViewModel {
    
    /**
     Performs the transformation from a NSDate -> SectionState.
     
     - parameter startVariable: Left side of our transformation equation:  
     An Observable (implemented as a Variable) wrapping a date object.
     
     - returns: A Observable wrapping the corresponding SectionState.
     */
    private func transformDateVariableIntoObservable(startVariable : Variable<NSDate?>) -> Observable<SectionState> {
        
        // distinctUntilChanged : ensure that we events are only generated when the changes between dates are more than 1 minute.
        
        return startVariable.distinctUntilChanged({ (lhs, rhs) -> Bool in
            guard let rhs = rhs else {
                return false
            }
            if let lhs = lhs {
                return abs( lhs.timeIntervalSinceDate(rhs) ) <= 60
            }
            return true
        })
            
        // map: Convert from NSDate? -> SectionState
            
        .map { $0 == nil ? SectionState.Missing : SectionState.Present }
    }
    
    /**
    The reactive source of data.
    
    We are merging our data objects (NSDate, NSDate, NSTimeZone, Bool) and an additional property (which is the "current" selected row).
    and producing a list of type SectionDesc from it.  self.selectedRowType is included in here to ensure that changes in the selected
    row propagate down the Rx pipe.
    */
    public var rows:Driver<[SectionDesc]> {
        
        // @see transformDateVariableIntoObservable: for an explanation of these lines.
        let startDateObs = transformDateVariableIntoObservable(self.startDate)
        let endDateObs = transformDateVariableIntoObservable(self.endDate)
        
        // ensure that we events are only generated when the boolean value "flips"
        let allDayObs = self.allDay.distinctUntilChanged()
            .map { $0 ? SectionState.Present : SectionState.Missing }
        
        return combineLatest(startDateObs, endDateObs, allDayObs, self.timeZone, self.selectedRowType) { d1, d2, aD, _, _ -> [SectionDesc] in
            return [
                (.StartDate,    d1),
                (.EndDate,      d2),
                (.TimeZone,     .Present), // Timezone is always present (will always be set to the user's local timezone)
                (.AllDay,       aD)
            ]
        }
        .map({ rows -> [SectionDesc] in
            if let selected:SectionType = self.selectedRowType.value where self.selectedRowType.value != SectionType.AllDay {
                var rs = rows
                rs[selected.toInt()] = (selected, SectionState.Selected)
                return rs
            }
            return rows
        })
        .asDriver(onErrorJustReturn:[])
    }
    
    /**
     Converts the data described by a SectionType object into a String observable.
     
     Used to create the "reactive" values of the labels in the table section header views.
     
     - parameter type: Which section do we want its value.
     
     - returns: An observable holding the (requested) transformed value
     */
    public func getStringObservableForRowType(type:SectionType) -> Observable<String> {

        if type.isDateType() {
            
            // dates will use the dataFormatter property.
            
            return (type == .StartDate ? self.startDate : self.endDate)
                .map({ date -> String in
                    
                    guard let date = date else {
                        return ""
                    }
                    return self.dateFormatter.stringFromDate(date)
                })
        }
            
        else if type == .TimeZone {
            
            // Timezones simply use their name property.
            return self.timeZone
                .map { return $0.name }
                .asObservable()
        }
        
        // everything else just returns an empty string.
            
        else {
            return Variable( "" ).asObservable()
        }
    }
    
}
