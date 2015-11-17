//
//  SectionModelDataSource.swift
//  Test
//
//  Created by Daniel Rodriguez on 11/13/15.
//  Copyright © 2015 PaperlessPost. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift
import RxBlocking

 // MARK: Type Aliases for indices types

public typealias SectionIndex = Int
public typealias RowIndex = Int

 // MARK: Functions used in RxSwift that are not exposed by the framework.

private func rxAbstractMethod<T>() -> T {
    rxFatalError("Abstract method")
}

@noreturn func rxFatalError(lastMessage: String) {
    // The temptation to comment this line is great, but please don't, it's for your own good. The choice is yours.
    fatalError(lastMessage)
}

func bindingErrorToInterface(error: ErrorType) {
    let error = "Binding error to UI: \(error)"
    #if DEBUG
        rxFatalError(error)
    #else
        print(error)
    #endif
}

// MARK: Protocols

/**
*  A protocol describing a Section DataSource (Generic)
*/
public protocol SectionDataSource {

    typealias Section
    func sectionAtIndex(index: Int) -> Section?
}

// MARK: DataSource class hierarchy

/// Base class for a TableView reactive datasource.  Not to be used directly.
class _RxTableViewReactiveSectionModelArrayDataSource: NSObject, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return _numberOfSectionsInTableView(tableView)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _tableView(tableView, numberOfRowsInSection: section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return _tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    // Rx
    
    func _numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return rxAbstractMethod()
    }
    
    func _tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rxAbstractMethod()
    }
    
    func _tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return rxAbstractMethod()
    }
    
}

// A subclass that specializes _RxTableViewReactiveSectionModelArrayDataSource by adding bindings between the 
// UITableViewDataSource methods, the models from our Observable source, and our two factory closures.
//
// This class is not meant to be used directly.
class RxTableViewReactiveSectionModelArrayDataSource<Element> : _RxTableViewReactiveSectionModelArrayDataSource, SectionDataSource {
    
    // Our factory types
    
    typealias SectionRowCount = (Int, Element) -> Int
    typealias CellFactory = (UITableView, Int, Int, Element) -> UITableViewCell
    
    // The section models (from our Observable source)
    var sectionModels: [Element]? = nil
    
    func sectionAtIndex(index: Int) -> Element? {
        return sectionModels?[index]
    }
    
    let cellFactory: CellFactory
    let sectionRowCount: SectionRowCount
    
    init(cellFactory: CellFactory, sectionRowCount:SectionRowCount) {
        self.cellFactory = cellFactory
        self.sectionRowCount = sectionRowCount
    }
    
    // table view data source
    
    override func _numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionModels?.count ?? 0
    }
    
    override func _tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionModel = self.sectionAtIndex(section) else {
            return 0
        }
        return sectionRowCount(section, sectionModel)
    }
    
    override func _tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return cellFactory(tableView, indexPath.section, indexPath.row, sectionModels![indexPath.section])
    }
    
    // reactive setter.
    
    func tableView(tableView: UITableView, observedElements: [Element]) {
        self.sectionModels = observedElements
        tableView.reloadData()
    }
}

/// A wrapper that allows our datasource to adopt Swift's SequenceType.
class RxTableViewReactiveSectionModelArrayDataSourceSequenceWrapper<S: SequenceType> : RxTableViewReactiveSectionModelArrayDataSource<S.Generator.Element>
, RxTableViewDataSourceType {
    typealias Element = S
    
    override init(cellFactory: CellFactory, sectionRowCount:SectionRowCount) {
        super.init(cellFactory: cellFactory, sectionRowCount: sectionRowCount)
    }
    
    convenience init(sectionRowCount: SectionRowCount, cellFactory: CellFactory) {
        self.init(cellFactory: cellFactory, sectionRowCount: sectionRowCount)
    }
    
    /**
     Handles an incoming event from a Rx pipe.
     
     - parameter tableView:     the UITableView this data source is working with.
     - parameter observedEvent: The incoming event from the Rx pipeline.
     */
    func tableView(tableView: UITableView, observedEvent: Event<S>) {
        switch observedEvent {
        case .Next(let value):
            super.tableView(tableView, observedElements: Array(value))
        case .Error(let error):
            bindingErrorToInterface(error)
        case .Completed:
            break
        }
    }
}
