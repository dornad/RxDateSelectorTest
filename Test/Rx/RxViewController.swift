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
    
    var viewModel:RxViewModel!
    
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
        
        self.viewModel = RxViewModel()
        
        self.tableView = UITableView(frame: self.view!.frame, style: .Grouped)
        self.view?.addSubview(tableView)
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.tableHeaderView = tableHeaderView()
        self.tableView.tableFooterView = tableFooterView()
        
        setupRx()
    }
    
    func setupRx() {
        
        self.viewModel.rows
            .drive(self.tableView.rx_itemsWithCellAndSectionFactory)(cellFactory: { (tv:UITableView, ip:NSIndexPath, desc:DateSelectorRowDescriptor)
                -> (rowHeight: CGFloat, cell: UITableViewCell) in
                //
                let cell = tv.dequeueReusableCellWithIdentifier("Cell", forIndexPath: ip)
                self.setupCell(cell, rowDesc: desc)
                return (UIConstants.rowHeight, cell)
                //
            })(sectionFactory: { (tv:UITableView, index:Int, desc:DateSelectorRowDescriptor)
                -> (rowCount: Int, rowHeight: CGFloat, headerView: UIView?) in
                //
                let headerView = self.headerInSection(desc)
                let numRowsInSection = desc.state == .Selected ? 1 : 0
                return (numRowsInSection, UIConstants.sectionHeaderHeight, headerView)
            })
            .addDisposableTo(disposeBag)
    }
}






