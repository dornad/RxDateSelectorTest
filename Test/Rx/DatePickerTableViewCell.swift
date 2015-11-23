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

protocol PickerCellType {
    func setup(sectionDesc: SectionDesc, viewModel:RxViewModel, disposeBag: DisposeBag)
}

class EndDatePickerTableViewCell : StartDatePickerTableViewCell {
    
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

class StartDatePickerTableViewCell : UITableViewCell, PickerCellType {
    
    var picker:UIDatePicker
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.picker = UIDatePicker()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.picker = UIDatePicker()
        super.init(coder: aDecoder)
    }
    
    internal func setup(sectionDesc: SectionDesc, viewModel:RxViewModel, disposeBag: DisposeBag) {
        
        self.picker.removeFromSuperview()
        
        self.contentView.addSubview(self.picker)
                
        self.picker.rx_date
            .subscribeNext { value in
                viewModel.startDate.value = value
            }
            .addDisposableTo(disposeBag)
        
        if let startDate = viewModel.startDate.value {
            self.picker.date = startDate
        }
        
        self.picker.snp_remakeConstraints(closure: { (make) -> Void in
            make.width.equalTo(self.contentView)
            make.height.equalTo(self.contentView)
        })
    }

}

