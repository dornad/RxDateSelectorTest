//
//  DatePickerTableViewCell.swift
//  Test
//
//  Created by Daniel Rodriguez on 11/20/15.
//  Copyright © 2015 PaperlessPost. All rights reserved.
//

import UIKit

import RxSwift

/// A Cell that displays a date picker for the end date of an event
public class EndDatePickerTableViewCell : StartDatePickerTableViewCell {
    
    override func bindValueToDatePicker(viewModel:EventDetailsDateSelectorViewModel, disposeBag:DisposeBag) {
        
        // Note: At some point this was implemented via two-way binding (i.e.:  self.picker.rx_date <-> viewModel.endDate.rx_variable)
        // It was causing issues, thus had to step back to a one-way binding plus normal value assignment
        
        if let endDate:NSDate = viewModel.endDate.value {
            self.picker.date = endDate
        }
        
        self.picker.rx_date
            .subscribeNext { value in
                viewModel.endDate.value = value
            }
            .addDisposableTo(disposeBag)
    }
}
