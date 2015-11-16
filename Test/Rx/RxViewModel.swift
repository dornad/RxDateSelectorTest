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

public class RxViewModel {
    
    // Properties
    
    public var startDate:Variable<NSDate?>
    public var endDate:Variable<NSDate?>
    public var timeZone:Variable<NSTimeZone>
    public var allDay:Variable<Bool>
    public var selectedRowType:Variable<SectionType?>
    
    // Helpers and Transformers
    
    public let dateFormatter:NSDateFormatter = NSDateFormatter()
    
    // Init
    
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

extension RxViewModel {
    
    private var observableForStartDate: Observable<SectionState> {
        return self.testValue(self.startDate)
    }
    
    private var observableForEndDate: Observable<SectionState> {
        return self.testValue(self.endDate)
    }
    
    private func testValue(startVariable : Variable<NSDate?>) -> Observable<SectionState> {
        
        return startVariable
            .distinctUntilChanged({ (lhs, rhs) -> Bool in
                
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
    
    public var rows:Driver<[RowDesc]> {
        
        return combineLatest(self.observableForStartDate, self.observableForEndDate, self.timeZone, self.selectedRowType) {
                value, value2, _, _ -> [RowDesc] in
                
                return [
                    (.StartDate,    value),
                    (.EndDate,      value2),
                    (.TimeZone,     .Present),
                    (.AllDay,       .Missing)
                ]
            }
            .map({ rows -> [RowDesc] in
                
                if let selected:SectionType = self.selectedRowType.value where self.selectedRowType.value != SectionType.AllDay {
                    var rs = rows
                    rs[selected.toInt()] = (selected, SectionState.Selected)
                    return rs
                }
                return rows
            })
            .asDriver(onErrorJustReturn:[])
    }
    
    public func getStringObservableForRowType(type:DateSelectorSectionType) -> Observable<String> {

        if type.isDateType() {
            
            return (type == .StartDate ? self.startDate : self.endDate)
                .map({ date -> String in
                    
                    guard let date = date else {
                        return ""
                    }
                    return self.dateFormatter.stringFromDate(date)
                })
        }
            
        else if type == .TimeZone {
            return self.timeZone
                .map { return $0.name }
                .asObservable()
        }
        
        else {
            return Variable( "" ).asObservable()
        }
    }
    
}
