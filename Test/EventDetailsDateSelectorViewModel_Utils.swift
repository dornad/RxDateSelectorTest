//
//  Common.swift
//  Test
//
//  Created by Daniel Rodriguez on 11/12/15.
//  Copyright © 2015 PaperlessPost. All rights reserved.
//

import UIKit

import RxSwift

// MARK: ValueHolder

/** A struct that allows types to be stored in Rx Observables, while providing their non-rx value, plus other benefits.

* Storage of (optional) previous value (for rollback purposes).
* Exposure of RxSwift Observable.
* (Optional) Value setter precondition

Usage Example:

```
let value = "Hello World"

let holder: ValueHolder<String> = RxValueHolder(value)

myValueHolder.rxVariable
    .asObservable()
    .subscribeNext { value -> Void in
        print("value = \(value)")
    }

myValueHolder.value = "Foo Bar"
```
*/
public struct ValueHolder<T> {
    
    /// A (generic) description for a function that receives two values of the same type and returns true if they match a condition.
    public typealias CallbackType = (_:T,_:T) -> Bool
    
    /// The previous value used by the holder
    private var previousValue:T?
    
    /// A callback that can check a condition before setting new values.
    private var myCallback: CallbackType? = nil
    
    /// A RxSwift Variable type
    public var rxVariable:Variable<T>
    
    /// The value stored by a ValueHolder type
    public var value: T {
        get {
            return self.rxVariable.value
        }
        set(newValue) {

            if let cb = self.myCallback {

                if cb(self.rxVariable.value, newValue) == false {
                    return
                }
            }
            
            self.previousValue = self.value
            self.rxVariable.value = newValue
        }
    }
    
    /**
     Initializes the ValueHolder with its initial value.
     
     - parameter initialValue: The initial instance to be stored.
     - parameter callback:     A closure that should return **false** if you want to prevent a value being stored.
     The signature of the closure must match the following: `T,T -> Bool`
     
     - returns: A ValueHolder instance with a value stored.
     */
    public init(_ initialValue:T, callbackForValueSetting callback: CallbackType? = nil) {
        
        self.myCallback = callback
        self.rxVariable = Variable(initialValue)
    }
}

// MARK: SectionType

public enum SectionTypeErrorType : ErrorType {
    case UnexpectedIntValue(String)
}

/**
 An enumeration of the possible values in each row of the event date selector.
 
 - StartDate: Start date of the event
 - EndDate:   End Date of the event
 - TimeZone:  The time zone.
 - AllDay:    Is the event all day.
 */
public enum SectionType {
    case StartDate, EndDate, TimeZone, AllDay
    
    /**
     The title for the tableview section header view's label.
     
     - returns: A string containing the corresponding title.
     */
    public func toTitleString() -> String {
        switch ( self ) {
        case .StartDate:
            return NSLocalizedString("STARTS", comment: "Label Title for Start Date in Date Picker")
        case .EndDate:
            return NSLocalizedString("ENDS", comment: "Label Title for End Date in Date Picker")
        case .TimeZone:
            return NSLocalizedString("TIME ZONE", comment: "Label Title for Time Zone in Date Picker")
        case .AllDay:
            return NSLocalizedString("ALL DAY", comment: "Label Title for ALL DAY in Date Picker")
        }
    }
}

// MARK: - SectionType util functions

extension SectionType {
    
    /**
     Convert from Int to SectionType.  Will throw error if it cannot be transformed.
     */
    public static func fromInt( value:Int ) throws -> SectionType {
        
        guard 0 ... 3 ~= value else {
            throw SectionTypeErrorType.UnexpectedIntValue("Values should be within the range \(0...3)")
        }
        
        var type = SectionType.StartDate
        if value == 1 {
            type = .EndDate
        } else if value == 2 {
            type = .TimeZone
        } else if value == 3 {
            type = .AllDay
        }
        
        return type
    }
    
    /**
     Convert from SectionType to Int.
     */
    public func toInt() -> Int {
        switch ( self ) {
        case .StartDate:
            return 0
        case .EndDate:
            return 1
        case .TimeZone:
            return 2
        case .AllDay:
            return 3
        }
    }
    
    /**
     Utility to determine if a SectionType contains a date, meaning either .StartDate or .EndDate
     
     - returns: true if the section type is a start date or end date.  False otherwise.
     */
    public func isDateType() -> Bool {
        return self == .StartDate || self == .EndDate
    }
}

// MARK: Section State

/**
 
 An enumeration describing the possible states of a Section.
 
 - Missing:  A data model in the ViewModel doesn't hold a value.
 
 - Present:  A data model in the ViewModel is currently holding a value, and it hasn't changed.

 - Dirty: A data model in the ViewModel has a value, and it differs from its initial state.

 */
public enum SectionState {
    case Present, Missing, Dirty;
}

/**
 A enumeration describing if the section is selected or not..
 
 - NotSelected: The section has not been selected.
 - Selected:    The section has been selected.
 */
public enum SectionSelection {
    case NotSelected, Selected
}


// MARK: Type Aliases

/// A SectionDesc (short for SectionDesc Descriptor) is a tuple between SectionType and SectionState.
public typealias SectionDesc = (type:SectionType, state:SectionState, selectionState:SectionSelection)
