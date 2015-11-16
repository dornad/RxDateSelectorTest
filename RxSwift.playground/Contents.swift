//: Playground - noun: a place where people can play

import UIKit


func distinctUntilChanged(lhs:NSDate?, rhs:NSDate?) -> Bool {
    
    guard let rhs = rhs else {
        return false
    }
    
    if let lhs = lhs {
        
        return abs( lhs.timeIntervalSinceDate(rhs) ) <= 60
    }
    
    return true
}

// these should be false

distinctUntilChanged(nil, rhs: nil)

// these should be true

distinctUntilChanged(nil, rhs: NSDate())
distinctUntilChanged(NSDate(), rhs: NSDate())
distinctUntilChanged(NSDate(), rhs: NSDate(timeIntervalSinceNow: 10))

// these should be false, again

distinctUntilChanged(NSDate(), rhs: NSDate(timeIntervalSinceNow: 100))
distinctUntilChanged(NSDate(), rhs: NSDate(timeIntervalSinceNow: 1000))
distinctUntilChanged(NSDate(), rhs: NSDate(timeIntervalSinceNow: 10000))
distinctUntilChanged(NSDate(), rhs: NSDate(timeIntervalSinceNow: 100000))
