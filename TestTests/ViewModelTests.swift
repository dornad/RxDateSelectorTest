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

func ==(lhs:SectionDesc, rhs:SectionDesc) -> Bool {
    
    return lhs.state == rhs.state && lhs.type == rhs.type
}

func ==(lhs:[SectionDesc], rhs:[SectionDesc]) -> Bool {
    
    guard lhs.count == rhs.count else {
        return false
    }
    
    return lhs[0] == rhs[0] &&
        lhs[1] == rhs[1] &&
        lhs[2] == rhs[2] &&
        lhs[3] == rhs[3]
}

// MARK: Selection Tests

class ViewModelTests: XCTestCase {
    
    func testStartDateComesPreselectedWhenNotPassingArguments() {

        let expected:[SectionDesc] = [
            (.StartDate,    .Selected),
            (.EndDate,      .Missing),
            (.TimeZone,     .Present),
            (.AllDay,       .Missing)
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
        
        XCTAssertTrue(latestValueFromRow! == expected, "These two are not equal: \(latestValueFromRow), expected: \(expected)")
    }
    
    func testEndDateCanBeSelected() {
        
        let expected:[SectionDesc] = [
            (.StartDate,    .Present),
            (.EndDate,      .Selected),
            (.TimeZone,     .Present),
            (.AllDay,       .Missing)
        ]
        
        let viewModel = RxViewModel()
        
        var latestValueFromRow: [SectionDesc]? = nil
        
        let d = viewModel.rows
            .asObservable()
            .subscribeNext { (rows) -> Void in
                latestValueFromRow = rows
        }
        
        viewModel.selectedRowType.value = .EndDate
        
        defer {
            d.dispose()
        }
        
        XCTAssertTrue(latestValueFromRow! == expected, "These two are not equal: \(latestValueFromRow), expected: \(expected)")
    }
    
    func testTimeZoneCanBeSelected() {
        
        let expected:[SectionDesc] = [
            (.StartDate,    .Present),
            (.EndDate,      .Missing),
            (.TimeZone,     .Selected),
            (.AllDay,       .Missing)
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
        
        XCTAssertTrue(latestValueFromRow! == expected, "These two are not equal: \(latestValueFromRow), expected: \(expected)")
    }
    
    func testAllDayCannotBeSelected() {
        
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
        
        XCTAssertTrue(latestValueFromRow![3].type == .AllDay)
        XCTAssertTrue(latestValueFromRow![3].state != SectionState.Selected)
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
        
        defer {
            d.dispose()
        }
        
        var count = 0
        for row in latestValueFromRow! {
            count += row.state == .Selected ? 1 : 0
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
        
        let date = NSDate()
        
        viewModel.selectedRowType.value = .StartDate
        viewModel.startDate.value = date
        
        let currentSectionDesc = latestValueFromRow![SectionType.StartDate.toInt()]
        XCTAssertEqual(currentSectionDesc.type, SectionType.StartDate )
        XCTAssertEqual(currentSectionDesc.state, SectionState.Selected )
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
        
        let date = NSDate()
        
        viewModel.selectedRowType.value = .EndDate
        viewModel.endDate.value = date
        
        let currentSectionDesc = latestValueFromRow![SectionType.EndDate.toInt()]
        XCTAssertEqual(currentSectionDesc.type, SectionType.EndDate )
        XCTAssertEqual(currentSectionDesc.state, SectionState.Selected )
        XCTAssertEqual(viewModel.endDate.value, date)
    }

    func testTimeZoneValueIsStored() {
        
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
        
        let timezone = NSTimeZone.localTimeZone()
        
        viewModel.selectedRowType.value = .TimeZone
        viewModel.timeZone.value = timezone
        
        let currentSectionDesc = latestValueFromRow![SectionType.TimeZone.toInt()]
        XCTAssertEqual(currentSectionDesc.type, SectionType.TimeZone )
        XCTAssertEqual(currentSectionDesc.state, SectionState.Selected )
        XCTAssertEqual(viewModel.timeZone.value, timezone)
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
        
        let currentSectionDesc = latestValueFromRow![SectionType.AllDay.toInt()]
        XCTAssertEqual(currentSectionDesc.type, SectionType.AllDay )
        XCTAssertEqual(currentSectionDesc.state, SectionState.Present )
        XCTAssertEqual(viewModel.allDay.value, isAllDayEvent)
    }
    
    func testStartAndEndDatesAreStoredSimultaneously() {
        
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
        
        viewModel.selectedRowType.value = .StartDate
        viewModel.startDate.value = startDate

        viewModel.selectedRowType.value = .EndDate
        viewModel.endDate.value = endDate

        let startDateSectionDesc = latestValueFromRow![0]
        XCTAssertEqual(startDateSectionDesc.type, SectionType.StartDate )
        XCTAssertEqual(startDateSectionDesc.state, SectionState.Present )
        XCTAssertEqual(viewModel.startDate.value, startDate)
        
        let endDateSectionDesc = latestValueFromRow![1]
        XCTAssertEqual(endDateSectionDesc.type, SectionType.EndDate )
        XCTAssertEqual(endDateSectionDesc.state, SectionState.Selected )
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
        
        // Randomly select a timezone
        let randTimezoneName = NSTimeZone.knownTimeZoneNames()[ 0 ]
        let timeZone = NSTimeZone(name: randTimezoneName)
        
        XCTAssertNotNil(timeZone, "Hypothesis: timeZone should had been initialized from its knownTimeZoneName")
        XCTAssertEqual(timeZone?.name, randTimezoneName, "Hypothesis: timeZone name should match")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
