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

// MARK: SelectedRowType Struct

/** A struct that isolates logic around selection, including Rx behavior.

Usage :

```
let selectedRow = SelectedRowType()

let reactiveData = selectedRow._currentSelection
    .asObservable()
    .subscribeNext { (selectedRowType:SectionType) -> Void in
        // do something with the data
    }

selectedRow.currentSelection = SectionType.StartDate
```
*/
public struct SelectedRowType {
    
    private var _previousSelection:SectionType?
    private var _currentSelection:Variable<SectionType?>
    
    public var currentSelection: SectionType? {
        get {
            return _currentSelection.value
        }
        set(newValue) {
            
            guard newValue != SectionType.AllDay else {
                return
            }
            
            if let existingSelection = _currentSelection.value {
                _previousSelection = existingSelection
            }
            
            _currentSelection.value = newValue
        }
    }
    
    init() {
        self._currentSelection = Variable(nil)
    }
}

// MARK: ViewModel - Properties, transformers and initializers

public class RxViewModel {
    
    // Properties
    
    // technically these properties are reactive, but we are listing them here
    // because they hold our data.
    
    public var startDate:Variable<NSDate?>
    public var endDate:Variable<NSDate?>
    public var timeZone:Variable<NSTimeZone>
    public var allDay:Variable<Bool>
    
    public var selectedRowType:SelectedRowType
    
    // Helpers and Transformers
    
    let dateFormatter:NSDateFormatter = NSDateFormatter()
    
    // Initializers
    
    required public init(startDate:NSDate? = nil, endDate:NSDate? = nil, timeZone:NSTimeZone = NSTimeZone.localTimeZone(), allDay: Bool=false) {
        
        self.dateFormatter.dateFormat = "EEE, MMM d, yyyy h:mm a"
        
        self.startDate = Variable(startDate)
        self.endDate = Variable(endDate)
        self.timeZone = Variable(timeZone)
        self.allDay = Variable(allDay)
        self.selectedRowType = SelectedRowType()
        
        if startDate == nil && endDate == nil {
            self.startDate.value = NSDate()
            self.selectedRowType.currentSelection = .StartDate
        }
    }
}

// MARK: ViewModel - Reactive methods and properties

extension RxViewModel {
    
    // distinctUntilChanged : ensure that we events are only generated when the changes between dates are more than 1 minute.    
    
    private func dateComparer( lhs:NSDate?, rhs:NSDate? ) -> Bool {
        
        guard let rhs = rhs else {
            return false
        }
        if let lhs = lhs {
            
            return abs( lhs.timeIntervalSinceDate(rhs) ) <= 60
        }
        return true
    }
    
    private func timeZoneComparer( lhs:NSTimeZone, rhs:NSTimeZone ) -> Bool {
        
        return lhs != rhs
    }

    /**
    The reactive source of data.
    
    We are merging our data objects (NSDate, NSDate, NSTimeZone, Bool) and an additional property (which is the "current" selected row).
    and producing a list of type SectionDesc from it.  self.selectedRowType is included in here to ensure that changes in the selected
    row propagate down the Rx pipe.
    */
    public var rows:Driver<[SectionDesc]> {

        // For each model (NSDate?, NSDate?, NSTimeZone, Bool) transform the Variable<model> into its corresponding SectionState.
        
        return combineLatest(self.startDate, self.endDate, self.timeZone, self.allDay, self.selectedRowType._currentSelection) { (sDate, eDate, _, _, _) -> [SectionDesc] in
            
            let startDateState:SectionState = (sDate != nil) ? .Present : .Missing
            let endDateState:SectionState = (eDate != nil) ? .Present : .Missing
            
                return [
                    (.StartDate, startDateState, .NotSelected),
                    (.EndDate,   endDateState,   .NotSelected),
                    (.TimeZone,  .Present,       .NotSelected),
                    (.AllDay,    .Present,       .NotSelected)
                ]
            }
            .map { (rows) -> [SectionDesc] in
                
                if let selected:SectionType = self.selectedRowType.currentSelection {
                    
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
