//
//  ValueHolderTests.swift
//  Test
//
//  Created by Daniel Rodriguez on 11/20/15.
//  Copyright © 2015 PaperlessPost. All rights reserved.
//

import XCTest
import Test


class ValueHolderTests: XCTestCase {
    
    func testItInitializesCorrectly() {
        
        let holder = ValueHolder<String>("Hello")
        
        XCTAssertNotNil(holder.value)
        XCTAssertEqual(holder.value, "Hello")
    }
    
    func testItSendsUpdatesViaRxObservable() {
        
        var holder = ValueHolder<String>("Hello")
        
        var fromObservable: String? = nil
        let observable = holder.rxVariable
            .asObservable()
            .subscribeNext { value -> Void in
                fromObservable = value
            }
        defer {
            observable.dispose()
        }
        
        holder.value += " World"
 
        XCTAssertNotNil(fromObservable)
        XCTAssertEqual(fromObservable!, "Hello World")
    }
    
    func testOnlySendUpdatesWhenValueIsStored() {
        
        var holder = ValueHolder<String>("Hello")
        
        var fromObservable: String? = nil
        let observable = holder.rxVariable
            .asObservable()
            .subscribeNext { value -> Void in
                fromObservable = value
        }
        defer {
            observable.dispose()
        }
        
        let storedValue = holder.value
        
        XCTAssertEqual(storedValue, "Hello")
        XCTAssertNotNil(fromObservable)
        XCTAssertEqual(fromObservable!, storedValue)
    }
    
    func testPreconditionsShouldBeCalledWhenTheyExists() {
        
        var preconditionWasCalled:Bool = false
        
        let precondition: (Int, Int) -> Bool = { _,_ in
            preconditionWasCalled = true
            return true
        }
        
        var holder = ValueHolder<Int>(1, callbackForValueSetting:precondition)
        
        var fromObservable: Int? = nil
        let observable = holder.rxVariable
            .asObservable()
            .subscribeNext { value -> Void in
                fromObservable = value
        }
        defer {
            observable.dispose()
        }
        
        holder.value = 2
        
        XCTAssertTrue(preconditionWasCalled)
    }
    
    func testPreconditionPreventsNewValuesAndNewUpdates() {
        
        let initialValue = 10
        var preconditionPreventedNewValuesAndUpdates:Bool = false
        
        let precondition: (Int, Int) -> Bool = { before, after -> Bool in
            let returnValue = after > before
            preconditionPreventedNewValuesAndUpdates = !returnValue
            return returnValue
        }
        
        var holder = ValueHolder<Int>(initialValue, callbackForValueSetting:precondition)
        
        var fromObservable: Int? = nil
        let observable = holder.rxVariable
            .asObservable()
            .subscribeNext { value -> Void in
                fromObservable = value
        }
        defer {
            observable.dispose()
        }
        
        holder.value = 2
        
        XCTAssertTrue(preconditionPreventedNewValuesAndUpdates)
        XCTAssertEqual(fromObservable!, initialValue)
        XCTAssertEqual(holder.value, initialValue)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
