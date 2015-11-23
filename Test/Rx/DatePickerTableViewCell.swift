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

class PickerViewTableViewCell : UITableViewCell, PickerCellType {
    
    var picker:UIPickerView
    var viewModel:RxViewModel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.picker = UIPickerView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.picker = UIPickerView()
        super.init(coder: aDecoder)
    }
    
    func setup(sectionDesc: SectionDesc, viewModel:RxViewModel, disposeBag:DisposeBag) {
        
        self.viewModel = viewModel
        self.contentView.addSubview(self.picker)
        self.picker.delegate = self
        self.picker.dataSource = self
        
        self.picker.snp_makeConstraints { (make) -> Void in
            make.left
                .right
                .top
                .bottom.equalTo(self.contentView)
        }
    }
}

extension PickerViewTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    internal func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    internal func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return NSTimeZone.knownTimeZoneNames().count
    }
    
  internal func pickerView(pickerView: UIPickerView,titleForRow row: Int,forComponent component: Int) -> String? {
        // might be worth looking into: http://stackoverflow.com/questions/31338724/how-to-get-full-time-zone-name-ios
        return NSTimeZone.knownTimeZoneNames()[row]
    }
    
    internal func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedName = NSTimeZone.knownTimeZoneNames()[row]
        if let viewModel = viewModel {
            viewModel.timeZone.value = NSTimeZone(name: selectedName)!
        }
    }
}