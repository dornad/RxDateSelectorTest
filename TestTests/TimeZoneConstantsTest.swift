//
//  TimeZoneConstantsTest.swift
//  Test
//
//  Created by Daniel Rodriguez on 12/2/15.
//  Copyright © 2015 PaperlessPost. All rights reserved.
//

import XCTest

@testable import Test

class TimeZoneConstantsTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testTimeZonesInAmericaAreInitialized() {
        
        for value: TimeZoneConstants.AmericaTimeZones in TimeZoneConstants.AmericaTimeZones.allValues {
            let timezone:NSTimeZone? = value.getTimeZone()
            
            XCTAssertNotNil(timezone)
        }
    }
    
    func testTimeZonesInUnitedKingdomAreInitialized() {
        
        for value: TimeZoneConstants.UnitedKingdomTimeZones in TimeZoneConstants.UnitedKingdomTimeZones.allValues {
            let timezone:NSTimeZone? = value.getTimeZone()
            
            XCTAssertNotNil(timezone)
        }
    }
    
    func testOtherTimeZonesAreInitialized() {
        
        for value: TimeZoneConstants.OtherTimeZones in TimeZoneConstants.OtherTimeZones.allValues {
            let timezone:NSTimeZone? = value.getTimeZone()
            
            XCTAssertNotNil(timezone)
        }
    }
    
    func testTimeZonesInAmericaHaveLabels() {
        
        for value: TimeZoneConstants.AmericaTimeZones in TimeZoneConstants.AmericaTimeZones.allValues {
            let label:String = value.getTimeZoneLabel()
            
            XCTAssertNotNil(label)
        }
    }
    
    func testTimeZonesInUnitedKingdomHaveLabels() {
        
        for value: TimeZoneConstants.UnitedKingdomTimeZones in TimeZoneConstants.UnitedKingdomTimeZones.allValues {
            let label:String = value.getTimeZoneLabel()
            
            XCTAssertNotNil(label)
        }
    }
    
    func testOtherTimeZonesHaveLabels() {
        
        for value: TimeZoneConstants.OtherTimeZones in TimeZoneConstants.OtherTimeZones.allValues {
            let label:String = value.getTimeZoneLabel()
            
            XCTAssertNotNil(label)
        }
    }
    


    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
