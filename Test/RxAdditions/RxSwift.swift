//
//  RxSwiftAdditions.swift
//  Test
//
//  Created by Daniel Rodriguez on 11/12/15.
//  Copyright © 2015 PaperlessPost. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBlocking

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


// RxCocoa Extension

class _RxTableViewSectionedReactiveArrayDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return rxAbstractMethod()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rxAbstractMethod()
    }
    
    func _tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return rxAbstractMethod()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return _tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    //
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return rxAbstractMethod()
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return rxAbstractMethod()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return rxAbstractMethod()
    }
}

// Please take a look at `DelegateProxyType.swift`
class RxTableViewSectionedReactiveArrayDataSource<Element> : _RxTableViewSectionedReactiveArrayDataSource {
    
    typealias CellData = (rowHeight:CGFloat, row:UITableViewCell)
    typealias SectionData = (rowCount:Int, headerHeight:CGFloat, headerView:UIView?)
    
    typealias CellFactory = (UITableView, NSIndexPath, Element) -> CellData
    typealias SectionFactory = (UITableView, Int, Element) -> SectionData
    
    var itemModels: [Element]? = nil
    
    func modelAtIndex(index: Int) -> Element? {
        return itemModels?[index]
    }
    
    let sectionFactory: SectionFactory
    let cellFactory: CellFactory
    
    init(cellFactory: CellFactory, sectionFactory:SectionFactory) {
        self.cellFactory = cellFactory
        self.sectionFactory = sectionFactory
    }
    
    // table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return itemModels?.count ?? 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionData = sectionFactory(tableView, section, itemModels![section])
        return sectionData.rowCount
    }
    
    override func _tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellData = cellFactory(tableView, indexPath, itemModels![indexPath.row])
        return cellData.row
    }
    
    // table view delegate
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionData = sectionFactory(tableView, section, itemModels![section])
        return sectionData.headerHeight
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionData = sectionFactory(tableView, section, itemModels![section])
        return sectionData.headerView
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellData = cellFactory(tableView, indexPath, itemModels![indexPath.row])
        return cellData.rowHeight
    }
    
    // reactive
    
    func tableView(tableView: UITableView, observedElements: [Element]) {
        self.itemModels = observedElements
        tableView.reloadData()
    }
}

class RxTableViewSectionedReactiveArrayDataSourceSequenceWrapper
    <S: SequenceType> : RxTableViewSectionedReactiveArrayDataSource<S.Generator.Element>,
    RxTableViewDataSourceType {
    typealias Element = S
    
    override init(cellFactory: CellFactory, sectionFactory: SectionFactory) {
        super.init(cellFactory: cellFactory, sectionFactory: sectionFactory)
    }
    
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

extension UITableView {
    
    public func rx_itemsWithCellAndSectionFactory<S: SequenceType, O: ObservableType where O.E ==S>
        (source:O)
        (cellFactory: (UITableView, NSIndexPath, S.Generator.Element) -> (rowHeight:CGFloat,cell:UITableViewCell))
        (sectionFactory: (UITableView, Int, S.Generator.Element) -> (rowCount:Int, rowHeight:CGFloat, headerView:UIView?))
        -> Disposable {
            let dataSource = RxTableViewSectionedReactiveArrayDataSourceSequenceWrapper<S>(cellFactory: cellFactory, sectionFactory: sectionFactory)
            
            // Set the dataSource as the UITableViewDelegate as well.
            self.rx_setDelegate(dataSource)
            
            return self.rx_itemsWithDataSource(dataSource)(source: source)
    }
}