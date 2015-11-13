//
//  ViewController.swift
//  Test
//
//  Created by Daniel Rodriguez on 11/10/15.
//  Copyright © 2015 PaperlessPost. All rights reserved.
//

import UIKit

public class ViewController : UIViewController {
    
    var tableView:UITableView!
    var playgroundFrame:CGRect?
    
    var viewModel:ViewModel!
    
    public init(viewModel:ViewModel, playgroundFrame:CGRect?) {
        super.init(nibName: nil, bundle: nil)
        self.playgroundFrame = playgroundFrame
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: View Controller LifeCycle

extension ViewController {

    override public func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let fr = self.playgroundFrame {
            self.view.frame = fr
        }
        
        self.viewModel = ViewModel()
        
        self.tableView = UITableView(frame: self.view!.frame, style: .Grouped)
        self.view?.addSubview(tableView)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.tableHeaderView = tableHeaderView()
        self.tableView.tableFooterView = tableFooterView()
        
    }
}

extension ViewController : UITableViewDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.viewModel.rows.count
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rowDesc = self.viewModel.rows[section]
        return rowDesc.state == .Selected ? 1 : 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let rowDesc = self.viewModel.rows[indexPath.section]
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        self.setupCell(cell, rowDesc: rowDesc)
        
        return cell
    }
}

extension ViewController : UITableViewDelegate {
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UIConstants.sectionHeaderHeight
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionDesc = self.viewModel.rows[section]
        return headerInSection(sectionDesc)
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return UIConstants.rowHeight
    }

    
}






