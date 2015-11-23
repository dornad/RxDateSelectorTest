//
//  TestTests.swift
//  TestTests
//
//  Created by Daniel Rodriguez on 11/16/15.
//  Copyright © 2015 PaperlessPost. All rights reserved.
//

import XCTest

import RxSwift
import RxCocoa
import RxBlocking

@testable import Test

// MARK: Selection Tests

class ViewModelSelectionTests: XCTestCase {
    
    func testStartDateComesPreselectedWhenNotPassingArguments() {

        let expected:[SectionDesc] = [
            (.StartDate,  .Present, .Selected),
            (.EndDate,    .Missing, .NotSelected),
            (.TimeZone,   .Present, .NotSelected),
            (.AllDay,     .Present, .NotSelected)
        ]
        
        let viewModel = RxViewModel()
        
        var latestValueFromRow: [SectionDesc]? = nil
        
        let d = viewModel.rows
            .asObservable()
            .subscribeNext { (rows) -> Void in
                latestValueFromRow = rows
            }
        
        defer {
            d.dispose()
        }
                
        XCTAssertTrue(expected == latestValueFromRow!, "values do not match. actual: \(print(latestValueFromRow!)), expected:\(print(expected))")
    }
    func testEndDateCanBeSelected() {
        
        let expected:[SectionDesc] = [
            (.StartDate,  .Present, .NotSelected),
            (.EndDate,    .Missing, .Selected),
            (.TimeZone,   .Present, .NotSelected),
            (.AllDay,     .Present, .NotSelected)
        ]
        
        let viewModel = RxViewModel()
        
        var latestValueFromRow: [SectionDesc]? = nil
        
        let d = viewModel.rows
            .asObservable()
            .subscribeNext { (rows) -> Void in
                print("ENTER subscribeNext")
                latestValueFromRow = rows
                print("EXIT subscribeNext")
        }
        
        viewModel.selectedRowType.value = .EndDate
        
        defer {
            d.dispose()
        }
        
        XCTAssertTrue(expected == latestValueFromRow!, "values do not match. actual: \(print(latestValueFromRow!)), expected:\(print(expected))")
    }
    
    func testTimeZoneCanBeSelected() {
        
        let expected:[SectionDesc] = [
            (.StartDate,  .Present, .NotSelected),
            (.EndDate,    .Missing, .NotSelected),
            (.TimeZone,   .Present, .Selected),
            (.AllDay,     .Present, .NotSelected)
        ]
        
        let viewModel = RxViewModel()
        
        var latestValueFromRow: [SectionDesc]? = nil
        
        let d = viewModel.rows
            .asObservable()
            .subscribeNext { (rows) -> Void in
                latestValueFromRow = rows
        }
        
        viewModel.selectedRowType.value = .TimeZone
        
        defer {
            d.dispose()
        }
        
        XCTAssertTrue(expected == latestValueFromRow!, "values do not match. actual: \(print(latestValueFromRow!)), expected:\(print(expected))")
    }
    
    
    func testAllDayCannotBeSelected() {
        
        let expected:[SectionDesc] = [
            (.StartDate,  .Present, .Selected),
            (.EndDate,    .Missing, .NotSelected),
            (.TimeZone,   .Present, .NotSelected),
            (.AllDay,     .Present, .NotSelected)
        ]
        
        let viewModel = RxViewModel()
        var latestValueFromRow: [SectionDesc]? = nil
        let d = viewModel.rows
            .asObservable()
            .subscribeNext { (rows) -> Void in
                latestValueFromRow = rows
        }
        
        viewModel.selectedRowType.value = .AllDay
        
        defer {
            d.dispose()
        }
        
        XCTAssertTrue(expected == latestValueFromRow!, "values do not match. actual: \(print(latestValueFromRow!)), expected:\(print(expected))")
    }
    
    func testSelectionsAreExclusive() {
        
        let viewModel = RxViewModel()
        
        var latestValueFromRow: [SectionDesc]? = nil
        
        let d = viewModel.rows
            .asObservable()
            .subscribeNext { (rows) -> Void in
                latestValueFromRow = rows
        }
        
        viewModel.selectedRowType.value = .StartDate
        viewModel.selectedRowType.value = .EndDate
        viewModel.selectedRowType.value = .TimeZone
        viewModel.selectedRowType.value = .AllDay
        
        defer {
            d.dispose()
        }
        
        var count = 0
        for row in latestValueFromRow! {
            count += (row.selectionState == .Selected) ? 1 : 0
        }
        
        XCTAssertEqual(count, 1, "Only one element should appear as selected")
    }

}

// MARK: Value modification tests

class ViewModelValueStorageTests: XCTestCase {
    
    func testDatePreconditionPreventsDatesWithinOneMinute() {
        
        let result_1 = dateComparer(NSDate(), rhs: NSDate())
        
        XCTAssertFalse(result_1, "dates should have more than 1 minute between each")
        
        let firstDate = NSDate()
        let thirtySecondsLater = NSDate(timeInterval: 30, sinceDate: firstDate)
        let result_2 = dateComparer(firstDate, rhs: thirtySecondsLater)
        
        XCTAssertFalse(result_2, "dates should have more than 1 minute between each")
        
        let secondDate = NSDate()
        let thirtySecondsLater_Variant = NSDate(timeIntervalSinceNow: 30)
        let result_3 = dateComparer(secondDate, rhs: thirtySecondsLater_Variant)
        
        XCTAssertFalse(result_3, "dates should have more than 1 minute between each")
        
        let thirdDate = NSDate()
        let sixtySecondsLater = NSDate(timeInterval: 60, sinceDate: thirdDate)
        let result_4 = dateComparer(thirdDate, rhs: sixtySecondsLater)
        
        XCTAssertFalse(result_4, "dates should have more than 1 minute between each")
    }
    
    func testDatePreconditionAllowsDatesWithMoreThanOneMinute() {

        let firstDate = NSDate()
        let sixtyOneSecondsLater = NSDate(timeInterval: 61, sinceDate: firstDate)
        let result = dateComparer(firstDate, rhs: sixtyOneSecondsLater)
        
        XCTAssertTrue(result, "dates should have more than 1 minute between each")
    }

    func testInitialDateValueIsStored() {
        
        let viewModel = RxViewModel()
        
        var latestValueFromRow: [SectionDesc]? = nil
        let d = viewModel.rows
            .asObservable()
            .subscribeNext { (rows) -> Void in
                latestValueFromRow = rows
        }
        defer {
            d.dispose()
        }
        
        let newDate = NSDate(timeIntervalSinceNow: 120)  // two minutes later should work
        
        viewModel.selectedRowType.value = .StartDate
        viewModel.startDate.value = newDate
        
        let currentSectionDesc = latestValueFromRow![SectionType.StartDate.toInt()]
        XCTAssertEqual(currentSectionDesc.type, SectionType.StartDate )
        XCTAssertEqual(currentSectionDesc.state, SectionState.Present )
        XCTAssertEqual(currentSectionDesc.selectionState, SectionSelection.Selected )
        XCTAssertEqual(viewModel.startDate.value, newDate)
    }

    
    func testEndDateValueIsStored() {
        
        let viewModel = RxViewModel()
        
        var latestValueFromRow: [SectionDesc]? = nil
        
        let d = viewModel.rows
            .asObservable()
            .subscribeNext { (rows) -> Void in
                latestValueFromRow = rows
        }
        
        defer {
            d.dispose()
        }
        
        let date = NSDate(timeIntervalSinceNow: 1000000)
        
        viewModel.selectedRowType.value = .EndDate
        viewModel.endDate.value = date
        
        let endDate = latestValueFromRow![SectionType.EndDate.toInt()]
        XCTAssertEqual(endDate.type, SectionType.EndDate )
        XCTAssertEqual(endDate.state, SectionState.Present )
        XCTAssertEqual(endDate.selectionState, SectionSelection.Selected )
        XCTAssertEqual(viewModel.endDate.value, date)
    }
    
    func testAllDayValueIsStored() {
        
        let viewModel = RxViewModel()
        
        var latestValueFromRow: [SectionDesc]? = nil
        
        let d = viewModel.rows
            .asObservable()
            .subscribeNext { (rows) -> Void in
                latestValueFromRow = rows
        }
        
        defer {
            d.dispose()
        }
        
        let isAllDayEvent = true

        viewModel.allDay.value = isAllDayEvent
        
        let allDay = latestValueFromRow![SectionType.AllDay.toInt()]
        XCTAssertEqual(allDay.type, SectionType.AllDay )
        XCTAssertEqual(allDay.state, SectionState.Present )
        XCTAssertEqual(allDay.selectionState, SectionSelection.NotSelected )
        XCTAssertEqual(viewModel.allDay.value, isAllDayEvent)
    }
    
    func testTransitionBetweenDateEditionIsCorrect() {
        
        let viewModel = RxViewModel()
        var latestValueFromRow: [SectionDesc]? = nil
        let d = viewModel.rows
            .asObservable()
            .subscribeNext { (rows) -> Void in
                latestValueFromRow = rows
        }
        defer {
            d.dispose()
        }
        
        let startDate = NSDate()
        let endDate = NSDate(timeInterval: 10000, sinceDate: startDate)
        
        // Set the start Date
        
        viewModel.selectedRowType.value = .StartDate
        viewModel.startDate.value = startDate
        
        // Check values when setting start date
        
        let startDateSectionData = latestValueFromRow![SectionType.StartDate.toInt()]
        XCTAssertEqual(startDateSectionData.type, SectionType.StartDate )
        XCTAssertEqual(startDateSectionData.state, SectionState.Present )
        XCTAssertEqual(startDateSectionData.selectionState, SectionSelection.Selected )
        
        let endDateSectionData = latestValueFromRow![SectionType.EndDate.toInt()]
        XCTAssertEqual(endDateSectionData.type, SectionType.EndDate )
        XCTAssertEqual(endDateSectionData.state, SectionState.Missing )
        XCTAssertEqual(endDateSectionData.selectionState, SectionSelection.NotSelected )
        
        XCTAssertNotNil(viewModel.startDate.value)
        XCTAssertNil(viewModel.endDate.value)
        
        // Set the end Date

        viewModel.selectedRowType.value = .EndDate
        viewModel.endDate.value = endDate

        // Check values after setting end date
        
        let finalStartDateSectionData = latestValueFromRow![SectionType.StartDate.toInt()]
        XCTAssertEqual(finalStartDateSectionData.type, SectionType.StartDate )
        XCTAssertEqual(finalStartDateSectionData.state, SectionState.Present )
        XCTAssertEqual(finalStartDateSectionData.selectionState, SectionSelection.NotSelected )
        
        let finalEndDateSectionData = latestValueFromRow![SectionType.EndDate.toInt()]
        XCTAssertEqual(finalEndDateSectionData.type, SectionType.EndDate )
        XCTAssertEqual(finalEndDateSectionData.state, SectionState.Present )
        XCTAssertEqual(finalEndDateSectionData.selectionState, SectionSelection.Selected )
        
        XCTAssertNotNil(viewModel.startDate.value)
        XCTAssertNotNil(viewModel.endDate.value)
    }
    
    func testTimeZoneValueCanBeChanged() {
        
        let viewModel = RxViewModel()
        var latestValueFromRow: [SectionDesc]? = nil
        let d = viewModel.rows
            .asObservable()
            .subscribeNext { (rows) -> Void in
                latestValueFromRow = rows
        }
        defer {
            d.dispose()
        }
        
        // Pick a (random) timezone
        let randomIndex = Int(arc4random_uniform(UInt32(NSTimeZone.knownTimeZoneNames().count)))
        let randTimezoneName = NSTimeZone.knownTimeZoneNames()[ randomIndex ]
        let expectedTimezone = NSTimeZone(name: randTimezoneName)
        
        // Safety checks about the picked timezone
        XCTAssertNotNil(expectedTimezone, "TimeZone should had been initialized from its knownTimeZoneName")
        XCTAssertEqual(expectedTimezone?.name, randTimezoneName, "TimeZone names should match")
        
        viewModel.selectedRowType.value = .TimeZone
        viewModel.timeZone.value = expectedTimezone!
        
        // Check the data coming out from the Rx pipe
        let timezoneSectionDesc = latestValueFromRow![SectionType.TimeZone.toInt()]
        XCTAssertEqual(timezoneSectionDesc.type, SectionType.TimeZone )
        XCTAssertEqual(timezoneSectionDesc.state, SectionState.Present )
        XCTAssertEqual(timezoneSectionDesc.selectionState, SectionSelection.Selected )
        XCTAssertEqual(viewModel.timeZone.value, expectedTimezone)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
}

class ViewModelReactiveTests : XCTestCase {
    
    
    func testDataShouldNotChangeAllTheTime() {
        
        
        
    }
    
}

// MARK: - Equatable functions

func ==(lhs:SectionDesc, rhs:SectionDesc) -> Bool {
    
    return  lhs.state == rhs.state &&
        lhs.type == rhs.type &&
        lhs.selectionState == lhs.selectionState
}

func ==(lhs:[SectionDesc], rhs:[SectionDesc]) -> Bool {
    
    guard lhs.count == rhs.count else {
        return false
    }
    
    return  lhs[0] == rhs[0] &&
        lhs[1] == rhs[1] &&
        lhs[2] == rhs[2] &&
        lhs[3] == rhs[3]
}

// MARK: - Print / Debug

func print(type:SectionType) -> String {
    switch type {
    case .StartDate:
        return ".StartDate"
    case .EndDate:
        return ".EndDate"
    case .TimeZone:
        return ".TimeZone"
    case .AllDay:
        return ".AllDay"
    }
}

func print(state:SectionState) -> String {
    switch state {
    case .Dirty:
        return ".Dirty"
    case .Missing:
        return ".Missing"
    case .Present:
        return ".Present"
    }
}

func print(selection:SectionSelection) -> String {
    switch selection {
    case .Selected:
        return ".Selected"
    case .NotSelected:
        return ".NotSelected"
    }
}

func print(row:SectionDesc) -> String {
    
    return "\(print(row.type)) : [\(print(row.state)), \(print(row.selectionState))]"
}

func print(rows:[SectionDesc]) -> String {
    
    var dbg = "{"
    for row in rows {
        
        dbg += "\(print(row)), "
    }
    dbg+="}"
    
    return dbg
}
