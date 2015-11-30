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

/// A Cell that displays a date picker for the end date of an event
public class EndDatePickerTableViewCell : StartDatePickerTableViewCell {
    
    /**
     Configure the cell.
     
     - parameter sectionDesc: Data or Descriptor of the section the cell is a part of.
     - parameter viewModel:   The ViewModel attached to the ViewController that owns the table view for this cell.
     - parameter disposeBag:  (Rx) memory management dispose bag.
     */
    override func setup(sectionDesc: SectionDesc, viewModel: EventDetailsDateSelectorViewModel, disposeBag: DisposeBag) {

        self.picker.removeFromSuperview()
        self.contentView.addSubview(self.picker)
        
        // Note: At some point this was implemented via two-way binding (i.e.:  self.picker.rx_date <-> viewModel.endDate.rx_variable)
        // It was causing issues, thus had to step back to a one-way binding plus normal value assignment
        
        if let endDate = viewModel.endDate.value {
            self.picker.date = endDate
        }
        
        self.picker.rx_date
            .subscribeNext { value in
                viewModel.endDate.value = value
            }
            .addDisposableTo(disposeBag)
        
        self.picker.snp_remakeConstraints(closure: { (make) -> Void in
            make.width.equalTo(self.contentView)
            make.height.equalTo(self.contentView)
        })
    }
}
