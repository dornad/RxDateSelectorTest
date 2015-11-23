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

internal func dateComparer( lhs:NSDate?, rhs:NSDate? ) -> Bool {
    guard let rhs = rhs else {
        return true
    }

    if let lhs = lhs {
        return abs( lhs.timeIntervalSinceDate(rhs) ) > 60
    }
    return true
}

internal func timeZoneComparer( lhs:NSTimeZone, rhs:NSTimeZone ) -> Bool {
    return lhs != rhs
}

// MARK: ViewModel - Properties, transformers and initializers

public class RxViewModel {
    
    // Properties
    
    // technically these properties are reactive, but we are listing them here
    // because they hold our data.
    
    public var startDate:ValueHolder<NSDate?>
    public var endDate:ValueHolder<NSDate?>
    public var timeZone:ValueHolder<NSTimeZone>
    public var allDay:Variable<Bool>
    
    public var selectedRowType:ValueHolder<SectionType?>
    
    // Helpers and Transformers
    
    let dateFormatter:NSDateFormatter = NSDateFormatter()
    
    // Initializers
    
    required public init(startDate:NSDate? = nil, endDate:NSDate? = nil, timeZone:NSTimeZone = NSTimeZone.localTimeZone(), allDay: Bool=false) {
        
        self.dateFormatter.dateFormat = "EEE, MMM d, yyyy h:mm a"
        
        self.startDate          = ValueHolder(startDate,        callbackForValueSetting: dateComparer)
        self.endDate            = ValueHolder(endDate,          callbackForValueSetting: dateComparer)
        self.timeZone           = ValueHolder(timeZone,         callbackForValueSetting: timeZoneComparer)
        self.allDay             = Variable(allDay)
        
        // Handle Preselection.
        let preselection:SectionType? = startDate == nil && endDate == nil ? .StartDate : nil
        self.selectedRowType = ValueHolder(preselection, callbackForValueSetting: { return $1 != .AllDay })
        if preselection != nil {
            self.startDate.value = NSDate()
        }
    }
}

// MARK: ViewModel - Reactive methods and properties

extension RxViewModel {
    
    /**
    The reactive source of data.
    
    We are merging our data objects (NSDate, NSDate, NSTimeZone, Bool) and an additional property (which is the "current" selected row).
    and producing a list of type SectionDesc from it.  self.selectedRowType is included in here to ensure that changes in the selected
    row propagate down the Rx pipe.
    */
    public var rows:Driver<[SectionDesc]> {

        return self.combineSources()
            .map { (rows) -> [SectionDesc] in
                
                if let selected:SectionType = self.selectedRowType.value {
                    
                    var mutableRows = rows
                    let index = selected.toInt()
                    mutableRows[index] = (selected, rows[index].state, .Selected)
                    return mutableRows
                }
                return rows
            }
            .asDriver(onErrorJustReturn: [])
    }
    
    /**
     Combine our sources into a single observable.
     
     - returns: A observable of type SectionDesc
     */
    func combineSources()-> Observable<[SectionDesc]> {
        
        // For each model (NSDate?, NSDate?, NSTimeZone, Bool) transform its model into its corresponding SectionState.
        
        let data = combineLatest(
            self.startDate.rxVariable,
            self.endDate.rxVariable,
            self.timeZone.rxVariable,
            self.allDay,
            self.selectedRowType.rxVariable) { (v1, v2, v3, v4, v5) -> [SectionDesc] in
                
                let sDateState:SectionState = (v1 != nil) ? .Present : .Missing
                let eDateState:SectionState = (v2 != nil) ? .Present : .Missing
                
                return [
                    (.StartDate, sDateState, .NotSelected),
                    (.EndDate,   eDateState,   .NotSelected),
                    (.TimeZone,  .Present,       .NotSelected),
                    (.AllDay,    .Present,       .NotSelected)
                ]
        }
        return data
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
            let source = (type == .StartDate ? self.startDate.rxVariable : self.endDate.rxVariable)

            return source.map({ date -> String in
                guard let date = date else {
                    return ""
                }
                return self.dateFormatter.stringFromDate(date)
            })
        }
            
        else if type == .TimeZone {
            
            return self.timeZone.rxVariable
                .map { return $0.name }
                .asObservable()
        }
        

        else {
            return Variable( "" ).asObservable()
        }
    }
    
}
