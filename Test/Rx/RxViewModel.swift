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
    
    public let dateFormatter:NSDateFormatter = NSDateFormatter()
    
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
    
    /// Converts the start date variable into a SectionState observable.
    private var observableForStartDate: Observable<SectionState> {
        return self.transformDateVariableIntoObservable(self.startDate)
    }
    
    /// Converts the start date variable into a SectionState observable.
    private var observableForEndDate: Observable<SectionState> {
        return self.transformDateVariableIntoObservable(self.endDate)
    }
    
    /**
     Performs the transformation from a NSDate -> SectionState.
     
     - parameter startVariable: Left side of our transformation equation:  
     An Observable (implemented as a Variable) wrapping a date object.
     
     - returns: A Observable wrapping the corresponding SectionState.
     */
    private func transformDateVariableIntoObservable(startVariable : Variable<NSDate?>) -> Observable<SectionState> {
        return startVariable
            .distinctUntilChanged({ (lhs, rhs) -> Bool in
                
                // This closure ensures that we are only sending events when the changes
                // between dates are more than 1 minute.
                
                guard let rhs = rhs else {
                    return false
                }
                if let lhs = lhs {
                    return abs( lhs.timeIntervalSinceDate(rhs) ) <= 60
                }
                return true
            })
            .map { $0 == nil ? SectionState.Missing : SectionState.Present }
    }
    
    /// The reactive source of data.
    public var rows:Driver<[SectionDesc]> {
        
        // We are merging our data objects (NSDate, NSDate, NSTimeZone, Bool) and an additional property (which is the "current" selected row).
        // and producing a list of type SectionDesc from it.
        
        // self.selectedRowType is included in here to ensure that changes in the selected row propagate down the Rx pipe.
        
        return combineLatest(self.observableForStartDate, self.observableForEndDate, self.allDay, self.timeZone, self.selectedRowType) {
                value, value2, value3, _, _ -> [SectionDesc] in
                // Build our list of SectionDesc.
                return [
                    (.StartDate,    value),
                    (.EndDate,      value2),
                    (.TimeZone,     .Present), // Timezone is always present (will always be set to the user's local timezone)
                    (.AllDay,       value3 ? .Present : .Missing)
                ]
            }
            .map({ rows -> [SectionDesc] in
                
                // This map function inserts the "Selected" values in the outgoing data.
                
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
