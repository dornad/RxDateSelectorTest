//
//  DatePickerTableViewCell.swift
//  Test
//
//  Created by Daniel Rodriguez on 11/20/15.
//  Copyright © 2015 PaperlessPost. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SnapKit

/**
 *  A protocol used for Table View Cells that should display a picker.
 */
protocol PickerCellType {
    
    func setup(sectionDesc: SectionDesc, viewModel:EventDetailsDateSelectorViewModel, disposeBag: DisposeBag)
    
    func bindValueToDatePicker(viewModel:EventDetailsDateSelectorViewModel, disposeBag:DisposeBag)
}

/// A Cell that displays a date picker for the start date of an event
public class StartDatePickerTableViewCell : UITableViewCell, PickerCellType {
    
    /// A Date picker.
    var picker:UIDatePicker
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.picker = UIDatePicker()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.picker = UIDatePicker()
        super.init(coder: aDecoder)
    }

    func bindValueToDatePicker(viewModel:EventDetailsDateSelectorViewModel, disposeBag:DisposeBag) {
        
        // Note: At some point this was implemented via two-way binding (i.e.:  self.picker.rx_date <-> viewModel.startDate.rx_variable)
        // It was causing issues, thus had to step back to a one-way binding plus normal value assignment
        
        if let startDate:NSDate = viewModel.startDate.value {
            self.picker.date = startDate
        }
    
        self.picker.rx_date
            .subscribeNext { value in
                viewModel.startDate.value = value
            }
            .addDisposableTo(disposeBag)
    }

    /**
     Configure the Table View Cell
     
     - parameter sectionDesc: The Section data
     - parameter viewModel:   Current ViewModel
     - parameter disposeBag:  (Rx) memory management dispose bag.
     */
    internal func setup(sectionDesc: SectionDesc, viewModel:EventDetailsDateSelectorViewModel, disposeBag: DisposeBag) {
        
        self.picker.removeFromSuperview()
        self.picker.datePickerMode = viewModel.allDay.value ? UIDatePickerMode.Date : UIDatePickerMode.DateAndTime
        
        self.contentView.addSubview(self.picker)

        bindValueToDatePicker(viewModel, disposeBag: disposeBag)
        
        self.picker.snp_remakeConstraints(closure: { (make) -> Void in
            make.width.equalTo(self.contentView)
            make.height.equalTo(self.contentView)
        })
    }

}

