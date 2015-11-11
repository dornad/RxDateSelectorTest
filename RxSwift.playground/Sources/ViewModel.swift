
import Foundation

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

public typealias DateSelectorRowDescriptor = (type:DateSelectorSectionType, state:DateSelectorValueState)

public class EventDetailsDateSelectorViewModel {
    
    public var startDate: NSDate?
    public var endDate: NSDate?
    public var timeZone: NSTimeZone
    public var allDay: Bool
    public var selectedRowType: DateSelectorSectionType?
    
    var rows:[DateSelectorRowDescriptor] {
        return [
            (.StartDate, self.startDate == nil ? .Missing : .Present),
            (.EndDate,   self.endDate == nil ? .Missing : .Present),
            (.TimeZone,  .Present),
            (.AllDay,    .Missing)
        ]
    }
    
    private let dateFormatter:NSDateFormatter = NSDateFormatter()
    
    required public init(startDate:NSDate? = nil, endDate:NSDate? = nil, timeZone:NSTimeZone = NSTimeZone.systemTimeZone(), allDay: Bool=false) {
        
        self.startDate = startDate
        self.endDate = endDate
        self.timeZone = timeZone
        self.allDay = allDay
        
        self.dateFormatter.dateFormat = "EEE, MMM d, yyyy h:mm a"
    }
}

protocol NonReactiveViewModel {
    func getObservableForSectionType(rowType: SectionType) -> String
}

extension EventDetailsDateSelectorViewModel: NonReactiveViewModel {
    
    public func getObservableForSectionType(rowType: SectionType) -> String {
        
        var finalValue:String = ""
        if rowType.isDateType() {
            if rowType == .StartDate {
                if let date = self.startDate {
                    finalValue = self.dateFormatter.stringFromDate(date)
                }
            } else {
                if let date = self.endDate {
                    finalValue = self.dateFormatter.stringFromDate(date)
                }
            }
        } else if rowType == .TimeZone {
            finalValue = timeZone.name
        }
        return finalValue
    }
    
}

public typealias ViewModel = EventDetailsDateSelectorViewModel
public typealias SectionType = DateSelectorSectionType
public typealias SectionState = DateSelectorValueState
public typealias RowDesc = DateSelectorRowDescriptor

