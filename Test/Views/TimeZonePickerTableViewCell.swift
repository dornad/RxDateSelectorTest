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


/// A Cell that displays a UIPickerView for picking TimeZones.
class PickerViewTableViewCell : UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource, PickerCellType {
    
    var picker:UIPickerView = UIPickerView()
    var viewModel:EventDetailsDateSelectorViewModel?
    
    func bindValueToDatePicker(viewModel: EventDetailsDateSelectorViewModel, disposeBag: DisposeBag) {
        // NO-OP
    }
    
    /**
     Configure the Table View Cell
     
     - parameter sectionDesc: The Section data
     - parameter viewModel:   Current ViewModel
     - parameter disposeBag:  (Rx) memory management dispose bag.
     */
    func setup(sectionDesc: SectionDesc, viewModel:EventDetailsDateSelectorViewModel, disposeBag:DisposeBag) {
        
        self.viewModel = viewModel
        self.contentView.addSubview(self.picker)
        self.picker.delegate = self
        self.picker.dataSource = self
        
        // The next 4 lines do pre-selection of the timezone value from the viewModel.
        let selectedLabel = viewModel.timeZone.value.getLabel()
        if let index = viewModel.listOfTimezoneLabels(includeSeparators: true).indexOf(selectedLabel) {
            self.picker.selectRow(index, inComponent: 0, animated: false)
        }

        self.picker.snp_makeConstraints { (make) -> Void in
            make.left
                .right
                .top
                .bottom.equalTo(self.contentView)
        }
    }
    
    internal var labels:[String] {
        guard let viewModel = self.viewModel else {
            return []
        }
        return viewModel.listOfTimezoneLabels(includeSeparators: true)
    }
    
    internal func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    internal func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.labels.count
    }
    
    internal func pickerView(pickerView: UIPickerView,titleForRow row: Int,forComponent component: Int) -> String? {
        return self.labels[row]
    }
    
    internal func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        let selectedLabel = self.labels[row]
        
        guard let viewModel = self.viewModel where selectedLabel != "-" else {
            // early return when we tap on the separator
            return
        }
        
        let timezone:NSTimeZone? = TimeZoneUtils.NSTimeZoneFromLabel(selectedLabel)
        if let timezone = timezone {
            viewModel.timeZone.value = timezone
        }
    }
}
