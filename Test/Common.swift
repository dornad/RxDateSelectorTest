//
//  Common.swift
//  Test
//
//  Created by Daniel Rodriguez on 11/12/15.
//  Copyright © 2015 PaperlessPost. All rights reserved.
//

import UIKit

// MARK: Type Aliases

/// A SectionDesc (short for SectionDesc Descriptor) is a tuple between a SectionType and its state.
public typealias SectionDesc = (type:SectionType, state:SectionState)

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

// MARK: SectionState

/**
 
 An enumeration describing the possible states of a Section.
 
 - Present:  The data in the ViewModel holds a value.
 
 - Missing:  The data in the ViewModel is optional, and it currently doesn't hold a value
 
 - Selected: The data in the ViewModel holds a value, but is currently being edited.
 
 */
public enum SectionState {
    case Present, Missing, Selected;
}
