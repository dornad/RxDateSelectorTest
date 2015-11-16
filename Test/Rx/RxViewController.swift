//
//  ViewController.swift
//  Test
//
//  Created by Daniel Rodriguez on 11/10/15.
//  Copyright © 2015 PaperlessPost. All rights reserved.
//

import UIKit

import RxSwift

public class RxViewController : UIViewController {
    
    var tableView:UITableView!
    var playgroundFrame:CGRect?
    let disposeBag = DisposeBag()
    
    var dataSource: RxTableViewReactiveSectionModelArrayDataSourceSequenceWrapper<[RowDesc]>!
    
    var viewModel:RxViewModel = RxViewModel()
    
    public init(viewModel:RxViewModel, playgroundFrame:CGRect?) {
        super.init(nibName: nil, bundle: nil)
        self.playgroundFrame = playgroundFrame
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: View Controller LifeCycle

extension RxViewController {

    override public func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let fr = self.playgroundFrame {
            self.view.frame = fr
        }
        
        self.tableView = UITableView(frame: self.view!.frame, style: .Grouped)
        self.view?.addSubview(tableView)
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.tableHeaderView = tableHeaderView()
        self.tableView.tableFooterView = tableFooterView()
        
        setupRx()
    }
    
    func setupRx() {
        
        self.dataSource = RxTableViewReactiveSectionModelArrayDataSourceSequenceWrapper(cellFactory: { (tv, s, r, item) -> UITableViewCell in
            // setup a cell via Rx
            let indexPath = NSIndexPath(forItem: r, inSection: s)
            let cell = tv.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            self.setupCell(cell, rowDesc: item)
            return cell
        }) { (i:Int, item:RowDesc) -> Int in
            // Get the number of rows to be displayed
            return item.state == .Selected ? 1 : 0
        }
        
        self.viewModel.rows.asObservable()
            .bindTo(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
        
        tableView.rx_setDelegate(self)
            .addDisposableTo(disposeBag)
    }
}

extension RxViewController : UITableViewDelegate {
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UIConstants.sectionHeaderHeight
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let sectionDesc = self.dataSource.sectionAtIndex(section) else {
            return nil
        }
        
        return headerInSection(sectionDesc)
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return UIConstants.rowHeight
    }
    
}

// }







