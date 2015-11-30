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

// MARK: Time Zones

/**
Override the "+" operator to implement Dictionary joining

- parameter left:  a dictionary
- parameter right: another dictionary

- returns: A dictionary representing the union between the two dictionaries.
*/
func + <KeyType, ValueType> (left: Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) -> Dictionary<KeyType, ValueType> {
    
    var joined = left
    for (k,v) in right {
        joined.updateValue(v, forKey: k)
    }
    return joined
}

/**
 TimeZone Picker Errors
 
 - InvalidTimeZoneName: A NSTimeZone is being initialized with an incorrect name parameter.  i.e.:  `NSTimeZone -initWithName:`
 - NotFound:    No NSTimeZone instance was found that matches the provided search paramerers
 */
enum TimeZonePickerErrors : ErrorType {
    case InvalidTimeZoneName(message:String)
    case NotFound(message:String)
}

public struct TimeZoneConstants {
    
    /// A list of Strings that we show in time zone pickers for the UK.  
    /// The list is sorted alphabetically.
    /// Each item in this list is a key for a NSTimeZone instance stored inside managedTimeZones
    static let ukTimeZonesKeys: [String] = ["London"]
    
    /// A list of Strings that we show in time zone pickers for the USA.
    /// The list is sorted alphabetically.
    /// Each item in this list is a key for a NSTimeZone instance stored inside managedTimeZones
    static let usaTimeZonesKeys: [String] = [
        "Alaska",
        "Central Time (US & Canada)",
        "Eastern Time (US & Canada)",
        "Mountain Time (US & Canada)",
        "Pacific Time (US & Canada)"
    ]
    
    /// A list of Strings that we show in time zone pickers corresponding to zones not in the USA or UK
    /// The list is sorted alphabetically.
    /// Each item in this list is a key for a NSTimeZone instance stored inside managedTimeZones
    static let otherTimeZoneKeys: [String] = [
        "Abu Dhabi",
        "Adelaide",
        "Athens",
        "Atlantic Time (Canada)",
        "Auckland",
        "Bangkok",
        "Buenos Aires",
        "Cape Verde Is.",
        "Caracas",
        "Dhaka",
        "Hawaii",
        "Hong Kong",
        "Islamabad",
        "Kabul",
        "Kathmandu",
        "Mid-Atlantic",
        "Moscow",
        "New Caledonia",
        "New Delhi",
        "Newfoundland",
        "Nuku'alofa",
        "Paris",
        "Rangoon",
        "Samoa",
        "Sydney",
        "Tehran",
        "Tokyo",
    ]
    
    /// The list of all the timezones that should be displayed.
    static let managedTimeZones: [String:NSTimeZone?] = [
        "Central Time (US & Canada)":   NSTimeZone(name:"America/Chicago"),
        "Eastern Time (US & Canada)":   NSTimeZone(name:"America/New_York"),
        "Mountain Time (US & Canada)":  NSTimeZone(name:"America/Denver"),
        "Pacific Time (US & Canada)":   NSTimeZone(name:"America/Los_Angeles"),
        "Alaska":                       NSTimeZone(name:"America/Juneau"),
        "London":                       NSTimeZone(name:"Europe/London"),
        "Abu Dhabi":                    NSTimeZone(name:"Asia/Muscat"),
        "Adelaide":                     NSTimeZone(name:"Australia/Adelaide"),
        "Athens":                       NSTimeZone(name:"Europe/Athens"),
        "Atlantic Time (Canada)":       NSTimeZone(name:"America/Halifax"),
        "Auckland":                     NSTimeZone(name:"Pacific/Auckland"),
        "Bangkok":                      NSTimeZone(name:"Asia/Bangkok"),
        "Buenos Aires":                 NSTimeZone(name:"America/Argentina/Buenos_Aires"),
        "Cape Verde Is.":               NSTimeZone(name:"Atlantic/Cape_Verde"),
        "Caracas":                      NSTimeZone(name:"America/Caracas"),
        "Dhaka":                        NSTimeZone(name:"Asia/Dhaka"),
        "Hawaii":                       NSTimeZone(name:"Pacific/Honolulu"),
        "Hong Kong":                    NSTimeZone(name:"Asia/Hong_Kong"),
        "Islamabad":                    NSTimeZone(name:"Asia/Karachi"),
        "Kabul":                        NSTimeZone(name:"Asia/Kabul"),
        "Kathmandu":                    NSTimeZone(name:"Asia/Kathmandu"),
        "Mid-Atlantic":                 NSTimeZone(name:"Atlantic/South_Georgia"),
        "Moscow":                       NSTimeZone(name:"Europe/Moscow"),
        "New Caledonia":                NSTimeZone(name:"Pacific/Noumea"),
        "New Delhi":                    NSTimeZone(name:"Asia/Kolkata"),
        "Newfoundland":                 NSTimeZone(name:"America/St_Johns"),
        "Nuku'alofa":                   NSTimeZone(name:"Pacific/Tongatapu"),
        "Paris":                        NSTimeZone(name:"Europe/Paris"),
        "Rangoon":                      NSTimeZone(name:"Asia/Rangoon"),
        "Samoa":                        NSTimeZone(name:"Pacific/Apia"),
        "Sydney":                       NSTimeZone(name:"Australia/Sydney"),
        "Tehran":                       NSTimeZone(name:"Asia/Tehran"),
        "Tokyo":                        NSTimeZone(name:"Asia/Tokyo")
    ];

}

extension NSTimeZone {
    
    /**
     Return the Paperless Post label for the current timezone.  (Same values as PPGeography)
     
     - returns: the label, or title to be displayed in the date picker
     */
    func getLabel() throws -> String {
        
        return try getLabelWithZones(TimeZoneConstants.managedTimeZones)
    }
    
    /**
     Return the Paperless Post label for the current timezone.  (Same values as PPGeography)
     
     - parameter zones: Zones
     
     - throws: Error
     
     - returns: the label, or title to be displayed in the date picker
     */
    func getLabelWithZones(zones:[String:NSTimeZone?]) throws -> String {
        
        for (timezoneLabel, timezone) in zones {
            if let timezone = timezone {
                if timezone.name == self.name {
                    return timezoneLabel
                }
            } else {
                throw TimeZonePickerErrors.InvalidTimeZoneName(message: "A NSTimeZone instance cannot be instantiated due to an incorrect name param.  Check managedTimeZones for values similar to \(self.name)")
            }
        }
        throw TimeZonePickerErrors.NotFound(message: "Label not found for NSTimeZone.  Comparison key is: \(self.name)")
    }
    
    /**
     Retrieve a NSTimeZone instance from its label.
     
     Used to retrieve a NSTimeZone instance corresponding to the label value from a UIPickerView.
     
     - parameter label: A String that should match a key in the managedTimeZones Dictionary ( [String: NSTimeZone?] )
     
     - throws: See TimeZonePickerErrors for a list of possible errors.
     
     - returns: A NSTimeZone instance corresponding to the label parameter.
     */
    static func getTimezoneFromLabel( label: String ) throws -> NSTimeZone
    {
        for (timezoneName, timezone) in TimeZoneConstants.managedTimeZones {
            
            if timezoneName == label {
                return timezone!
            }
        }
        
        throw TimeZonePickerErrors.NotFound(message: "NSTimeZone not found! Searching with label: \(label)")
    }
}
