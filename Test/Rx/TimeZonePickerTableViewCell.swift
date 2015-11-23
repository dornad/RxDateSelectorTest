//
//  TimeZonePickerTableViewCell.swift
//  Test
//
//  Created by Daniel Rodriguez on 11/23/15.
//  Copyright © 2015 PaperlessPost. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SnapKit

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
    
    var everyTimeZonePlusSeparators: [String] {
        
        return TimeZoneConstants.usaTimeZonesKeys
            + ["-"]
            + TimeZoneConstants.ukTimeZonesKeys
            + ["-"]
            + TimeZoneConstants.otherTimeZoneKeys
    }
    
    internal func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    internal func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return everyTimeZonePlusSeparators.count
    }
    
    internal func pickerView(pickerView: UIPickerView,titleForRow row: Int,forComponent component: Int) -> String? {

        return everyTimeZonePlusSeparators[row]
    }
    
    internal func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        let selectedName: String = everyTimeZonePlusSeparators[row]
        
        guard selectedName != "-" else {
            return
        }
        
        if let viewModel = viewModel {
            
            let timezone : NSTimeZone? = TimeZoneConstants.managedTimeZones[selectedName]!
            if let timezone = timezone {
                viewModel.timeZone.value = timezone
            }
        }
    }
}