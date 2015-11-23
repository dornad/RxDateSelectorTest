//
//  Common.swift
//  Test
//
//  Created by Daniel Rodriguez on 11/12/15.
//  Copyright © 2015 PaperlessPost. All rights reserved.
//

import UIKit

import RxSwift

extension String {
    var lastPathComponent: String {
        get {
            return (self as NSString).lastPathComponent
        }
    }
}

public func ENTER_LOG(@autoclosure message:  () -> String, filename: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
    
    print("\(filename.lastPathComponent) - \(function) - @% ENTER", message())
}

public func EXIT_LOG(@autoclosure message:  () -> String, filename: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
    
    print("\(filename.lastPathComponent) - \(function) - @% EXIT", message())
}

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
    
    public typealias CallbackType = (_:T,_:T) -> Bool
    
    /// The previous value used by the holder
    private var previousValue:T?
    
    private var myCallback: CallbackType? = nil
    
    public var rxVariable:Variable<T>
    
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
            rxVariable.value = newValue
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

// MARK: Custom Fonts

extension UIFont {
    
    // For testing purposes we are not including helvetica neue in the test project.  We are mapping this to the system font.
    
    public static func helveticaNeueLightFontWithSize(size:CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Light", size: size) ?? UIFont.systemFontOfSize(size)
    }
    
    public static func helveticaNeueMediumFontWithSize(size:CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Medium", size: size) ?? UIFont.systemFontOfSize(size)
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
        if value == 0 {
            return .StartDate
        } else if value == 1 {
            return .EndDate
        } else if value == 2 {
            return .TimeZone
        } else if value == 3 {
            return .AllDay
        } else {
            throw SectionTypeErrorType.UnexpectedIntValue("Values should be within the range [0..3]")
        }
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

// MARK: Time Zones

enum TimeZonePickerErrors : ErrorType {
    case NameInvalid
    case NotFound(message:String)
}

let managedTimeZones = [
    "Abu Dhabi":                    NSTimeZone(name:"Asia/Muscat"),
    "Adelaide":                     NSTimeZone(name:"Australia/Adelaide"),
    "Alaska":                       NSTimeZone(name:"America/Juneau"),
    "Athens":                       NSTimeZone(name:"Europe/Athens"),
    "Atlantic Time (Canada)":       NSTimeZone(name:"America/Halifax"),
    "Auckland":                     NSTimeZone(name:"Pacific/Auckland"),
    "Bangkok":                      NSTimeZone(name:"Asia/Bangkok"),
    "Buenos Aires":                 NSTimeZone(name:"America/Argentina/Buenos_Aires"),
    "Cape Verde Is.":               NSTimeZone(name:"Atlantic/Cape_Verde"),
    "Caracas":                      NSTimeZone(name:"America/Caracas"),
    "Central Time (US & Canada)":   NSTimeZone(name:"America/Chicago"),
    "Dhaka":                        NSTimeZone(name:"Asia/Dhaka"),
    "Eastern Time (US & Canada)":   NSTimeZone(name:"America/New_York"),
    "Hawaii":                       NSTimeZone(name:"Pacific/Honolulu"),
    "Hong Kong":                    NSTimeZone(name:"Asia/Hong_Kong"),
    "Islamabad":                    NSTimeZone(name:"Asia/Karachi"),
    "Kabul":                        NSTimeZone(name:"Asia/Kabul"),
    "Kathmandu":                    NSTimeZone(name:"Asia/Kathmandu"),
    "London":                       NSTimeZone(name:"Europe/London"),
    "Mid-Atlantic":                 NSTimeZone(name:"Atlantic/South_Georgia"),
    "Moscow":                       NSTimeZone(name:"Europe/Moscow"),
    "Mountain Time (US & Canada)":  NSTimeZone(name:"America/Denver"),
    "New Caledonia":                NSTimeZone(name:"Pacific/Noumea"),
    "New Delhi":                    NSTimeZone(name:"Asia/Kolkata"),
    "Newfoundland":                 NSTimeZone(name:"America/St_Johns"),
    "Nuku'alofa":                   NSTimeZone(name:"Pacific/Tongatapu"),
    "Pacific Time (US & Canada)":   NSTimeZone(name:"America/Los_Angeles"),
    "Paris":                        NSTimeZone(name:"Europe/Paris"),
    "Rangoon":                      NSTimeZone(name:"Asia/Rangoon"),
    "Samoa":                        NSTimeZone(name:"Pacific/Apia"),
    "Sydney":                       NSTimeZone(name:"Australia/Sydney"),
    "Tehran":                       NSTimeZone(name:"Asia/Tehran"),
    "Tokyo":                        NSTimeZone(name:"Asia/Tokyo")
];

func getTimezoneFromLabel( label: String ) throws -> NSTimeZone
{
    for (timezoneName, timezone) in managedTimeZones {
        
        if timezoneName == label {
            return timezone!
        }
    }
    
    throw TimeZonePickerErrors.NotFound(message: "NSTimeZone not found using label: \(label)")
}

func getTimezoneLabel( tz : NSTimeZone ) throws -> String {
    
    for (timezoneLabel, timezone) in managedTimeZones {
        if let timezone = timezone {
            if timezone.name == tz.name {
                return timezoneLabel
            }
        } else {
            throw TimeZonePickerErrors.NameInvalid
        }
    }
    throw TimeZonePickerErrors.NotFound(message: "NSTimeZone label not found for timezone.  Comparison key is: \(tz.name)")
}

