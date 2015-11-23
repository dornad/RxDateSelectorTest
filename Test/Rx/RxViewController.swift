//
//  ViewController.swift
//  Test
//
//  Created by Daniel Rodriguez on 11/10/15.
//  Copyright © 2015 PaperlessPost. All rights reserved.
//

import UIKit

import RxSwift
import SnapKit

public class RxViewController : UIViewController {
    
    /// The tableview.
    var tableView:UITableView!
    
    /// The frame of the Playground you want to initialize.
    var playgroundFrame:CGRect?
    
    /// Rx bag of wonders...
    let disposeBag = DisposeBag()
    
    /// Reactive datasource, used in the table view delegate.
    var dataSource: RxTableViewReactiveSectionModelArrayDataSourceSequenceWrapper<[SectionDesc]>!
    
    /// Our ViewModel, initialized with its default values
    var viewModel:RxViewModel = RxViewModel()
    
    /// A Constraint for the table cell height when they are closed (~10 px)
    var rowHeightClosedConstraint: Constraint? = nil
    
    /// A Constraint for the table cell height when they are open ( equal to cell.contentView.superview.height)
    var rowHeightOpenConstraint: Constraint? = nil
    
    /**
     Initializer for Playground testing.
     
     - parameter viewModel:       A ViewModel you initialize in the playground
     - parameter playgroundFrame: The frame of the playground's active view.
     
     - returns: An instance of this
     */
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
        
        self.tableView.registerClass(EndDatePickerTableViewCell.self, forCellReuseIdentifier: "EndDatePickerCell")
        self.tableView.registerClass(StartDatePickerTableViewCell.self, forCellReuseIdentifier: "StartDatePickerCell")
        self.tableView.registerClass(PickerViewTableViewCell.self, forCellReuseIdentifier: "PickerViewCell")
        self.tableView.tableHeaderView = tableHeaderView()
        self.tableView.tableFooterView = tableFooterView()
        self.tableView.sectionFooterHeight = 1

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = UIConstants.rowHeightClosed
        
        setupRx()
    }
    
    /**
     Setup our reactive datasource, perform the reactive binding between the ViewModel and the dataSource, 
     plus binding between our tableview and its delegate (this class).
     */
    func setupRx() {
        
        /**
        *  A variant of Rx's reactive UITableView datasource that can handle our ViewModel's models (type SectionDesc).
        * 
        *  It has two closures:  A "cell factory" and a sectionRowCount closure.
        *
        *  @return A Reactive datasource.
        */
        self.dataSource = RxTableViewReactiveSectionModelArrayDataSourceSequenceWrapper(cellFactory: { (tv, s, r, item) -> UITableViewCell in
            // setup a cell via Rx
            let indexPath = NSIndexPath(forItem: r, inSection: s)
            
            let identifier:String
            if item.type.isDateType() {
                
                identifier = item.type == .StartDate ? "StartDatePickerCell" : "EndDatePickerCell"
            } else {
                identifier = "PickerViewCell"
            }
            
            let cell = tv.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! PickerCellType
            
            cell.setup( item, viewModel: self.viewModel, disposeBag: self.disposeBag )
            
            return (cell as? UITableViewCell)!
        }) { (i:Int, item:SectionDesc) -> Int in // sectionRowCount closure
            return item.selectionState == .Selected ? 1 : 0
        }
        
        // Connect the rows property to the datasource.
        self.viewModel.rows.asObservable()
            .bindTo(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
        
        // Installs the delegate (this class) as a forwarding delegate on rx_delegate.
        // (normal delegate mechanism with reactive delegate mechanism)
        tableView.rx_setDelegate(self)
            .addDisposableTo(disposeBag)
    }
}

// MARK: - UITableViewDelegate methods

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
}
