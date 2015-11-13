//
//  Common.swift
//  Test
//
//  Created by Daniel Rodriguez on 11/12/15.
//  Copyright © 2015 PaperlessPost. All rights reserved.
//

import UIKit

public typealias SectionType = DateSelectorSectionType
public typealias SectionState = DateSelectorValueState
public typealias DateSelectorRowDescriptor = (type:DateSelectorSectionType, state:DateSelectorValueState)
public typealias RowDesc = DateSelectorRowDescriptor

extension UIFont {
    public static func helveticaNeueLightFontWithSize(size:CGFloat) -> UIFont {
        return UIFont.systemFontOfSize(size)
    }
    
    public static func helveticaNeueMediumFontWithSize(size:CGFloat) -> UIFont {
        return UIFont.systemFontOfSize(size)
    }
}

public enum DateSelectorSectionTypeErrorType : ErrorType {
    case UnexpectedIntValue(String)
}

public enum DateSelectorSectionType {
    case StartDate, EndDate, TimeZone, AllDay
    
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

extension DateSelectorSectionType {
    
    public static func fromInt( value:Int ) throws -> DateSelectorSectionType {
        if value == 0 {
            return .StartDate
        } else if value == 1 {
            return .EndDate
        } else if value == 2 {
            return .TimeZone
        } else if value == 3 {
            return .AllDay
        } else {
            throw DateSelectorSectionTypeErrorType.UnexpectedIntValue("Values should be within the range [0..3]")
        }
    }
    
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
    
    public func isDateType() -> Bool {
        return self == .StartDate || self == .EndDate
    }
}

public enum DateSelectorValueState {
    case Present, Missing, Selected;
}
