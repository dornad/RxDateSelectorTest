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

import Test

// MARK: Selection Tests

class ViewModelTests: XCTestCase {
    
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
        
        viewModel.selectedRowType.currentSelection = .EndDate
        
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
        
        viewModel.selectedRowType.currentSelection = .TimeZone
        
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
        
        viewModel.selectedRowType.currentSelection = .AllDay
        
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
        
        viewModel.selectedRowType.currentSelection = .StartDate
        viewModel.selectedRowType.currentSelection = .EndDate
        viewModel.selectedRowType.currentSelection = .TimeZone
        viewModel.selectedRowType.currentSelection = .AllDay
        
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

extension ViewModelTests {

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
        
        let date = NSDate(timeIntervalSinceNow: 1000000)
        
        viewModel.selectedRowType.currentSelection = .StartDate
        viewModel.startDate.value = date
        
        let currentSectionDesc = latestValueFromRow![SectionType.StartDate.toInt()]
        XCTAssertEqual(currentSectionDesc.type, SectionType.StartDate )
        XCTAssertEqual(currentSectionDesc.state, SectionState.Present )
        XCTAssertEqual(currentSectionDesc.selectionState, SectionSelection.Selected )
        XCTAssertEqual(viewModel.startDate.value, date)
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
        
        viewModel.selectedRowType.currentSelection = .EndDate
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
        
        viewModel.selectedRowType.currentSelection = .StartDate
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

        XCTAssertEqual(viewModel.startDate.value, startDate)
        XCTAssertNil(viewModel.endDate.value)
        
        // Set the end Date

        viewModel.selectedRowType.currentSelection = .EndDate
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
        
        XCTAssertEqual(viewModel.startDate.value, startDate)
        XCTAssertEqual(viewModel.endDate.value, endDate)
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
        
        viewModel.selectedRowType.currentSelection = .TimeZone
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
