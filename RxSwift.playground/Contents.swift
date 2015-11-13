//: Playground - noun: a place where people can play

import UIKit

import SnapKit
import RxCocoa
import RxSwift
import XCPlayground

class ViewModel {
    
    var startDate: NSDate?
    var endDate: NSDate?
    var timeZone: NSTimeZone!
    var allDay: Bool
    var selectedRowType: Int = 0
    
    init(startDate:NSDate? = nil, endDate:NSDate? = nil, timeZone:NSTimeZone = NSTimeZone.localTimeZone(), allDay: Bool=false) {
        
        self.startDate = startDate
        self.endDate = endDate
        self.timeZone = timeZone
        self.allDay = allDay
    }
}

let val = "Hello"

let viewModel = ViewModel()

//let ctrl = ViewController(viewModel: viewModel, playgroundFrame:CGRectMake(0,0,320,480))

//XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//XCPlaygroundPage.currentPage.liveView = ctrl.view

// Uncomment to simulate the initial opening
//viewModel.selectedRowType = .StartDate

// Uncomment to simulate choosing a start date
//viewModel.startDate = firstDate

// Uncomment to simulate tapping on the next element
//viewModel.selectedRowType = .EndDate

// Uncomment to simulate choosing an end date
//viewModel.endDate = secondDate

//: [Next](@next)
