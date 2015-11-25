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
    
    override func setup(sectionDesc: SectionDesc, viewModel: RxViewModel, disposeBag: DisposeBag) {
        self.picker.removeFromSuperview()
        
        self.contentView.addSubview(self.picker)
        
        self.picker.rx_date
            .subscribeNext { value in
                viewModel.endDate.value = value
            }
            .addDisposableTo(disposeBag)
        
        if let endDate = viewModel.endDate.value {
            self.picker.date = endDate
        }
        
        self.picker.snp_remakeConstraints(closure: { (make) -> Void in
            make.width.equalTo(self.contentView)
            make.height.equalTo(self.contentView)
        })
    }
}
