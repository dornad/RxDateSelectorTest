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

    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
