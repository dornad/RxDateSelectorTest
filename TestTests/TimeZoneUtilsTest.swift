//
//  TimeZoneUtilsTest.swift
//  Test
//
//  Created by Daniel Rodriguez on 12/2/15.
//  Copyright © 2015 PaperlessPost. All rights reserved.
//

import XCTest
@testable import Test

class TimeZoneUtilsTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testTimezonesAreRetrievedByLabel() {

        for label in self.allTimezoneLabels() {
            let timezone:NSTimeZone? = TimeZoneUtils.NSTimeZoneFromLabel(label)
            XCTAssertNotNil(timezone)
        }
    }
    
    func testTimeZoneIsNilWhenLabelIsIncorrect() {
        
        guard var lastLabel = self.allTimezoneLabels().last else {
            XCTFail("Needs a label to start."); return
        }
        
        lastLabel += " "
        
        let timezone:NSTimeZone? = TimeZoneUtils.NSTimeZoneFromLabel(lastLabel)
        XCTAssertNil(timezone)
    }

    // Make sure that retrieving timezone from labels stay performant.
    func testPerformanceGetTimeZoneFromLabel() {
        
        guard let lastLabel = self.allTimezoneLabels().last else {
            XCTFail("Needs a label to start."); return
        }
        
        self.measureBlock {
            TimeZoneUtils.NSTimeZoneFromLabel(lastLabel)
        }
    }
    
    func testTimezonesHaveLabels() {
        
        for timezone in self.allTimezones() {
            guard let timezone = timezone else {
                XCTFail("Unexpected nil NSTimeZone instance."); return
            }
            let label:String? = TimeZoneUtils.TimeZoneLabelFromNSTimeZone(timezone)
            XCTAssertNotNil(label)
        }
    }
    
    func testLabelIsNilWithUnmanagedTimeZone() {
        
        guard let timezone = NSTimeZone(name: "America/Bogota") else {
            XCTFail("Needs a non-nil value"); return
        }
        
        let label = TimeZoneUtils.TimeZoneLabelFromNSTimeZone(timezone)
        XCTAssertNil(label)
    }
    
    func testTimeZoneExtensionHasLabelProperty() {
    
        let timezone = NSTimeZone.localTimeZone()
        XCTAssertNotNil(timezone.getLabel())
    }
    
    func testLabelPropertyIsEmptyWithTimezoneExtension() {
        
        guard let timezone = NSTimeZone(name: "America/Bogota") else {
            XCTFail("Needs a non-nil value"); return
        }
        
        let label = timezone.getLabel()
        XCTAssertEqual(label, "")
    }
    
    // Make sure that retrieving labels stay performant.
    func testPerformanceGetLabel() {
        
        guard let lastTimezone = self.allTimezones().last else {
            XCTFail("Needs a NSTimeZone instance to start."); return
        }
        
        guard let tz = lastTimezone else {
            XCTFail("Needs a non-nil value."); return
        }
        
        self.measureBlock {
            TimeZoneUtils.TimeZoneLabelFromNSTimeZone(tz)
        }
    }
    
    func allTimezoneLabels() -> [String] {
        var labels:[String] = []
        for value in TimeZoneConstants.AmericaTimeZones.allValues {
            labels.append(value.getTimeZoneLabel())
        }
        for value in TimeZoneConstants.UnitedKingdomTimeZones.allValues {
            labels.append(value.getTimeZoneLabel())
        }
        for value in TimeZoneConstants.OtherTimeZones.allValues {
            labels.append(value.getTimeZoneLabel())
        }
        return labels
    }
    
    func allTimezones() -> [NSTimeZone?] {
        var timezones:[NSTimeZone?] = []
        for value in TimeZoneConstants.AmericaTimeZones.allValues {
            timezones.append(value.getTimeZone())
        }
        for value in TimeZoneConstants.UnitedKingdomTimeZones.allValues {
            timezones.append(value.getTimeZone())
        }
        for value in TimeZoneConstants.OtherTimeZones.allValues {
            timezones.append(value.getTimeZone())
        }
        return timezones
    }

}
