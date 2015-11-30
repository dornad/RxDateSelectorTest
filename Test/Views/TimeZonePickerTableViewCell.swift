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
class PickerViewTableViewCell : UITableViewCell, PickerCellType {
    
    var picker:UIPickerView
    var viewModel:EventDetailsDateSelectorViewModel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.picker = UIPickerView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.picker = UIPickerView()
        super.init(coder: aDecoder)
    }
    
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
        let selectedLabel = (try? viewModel.timeZone.value.getLabel()) ?? ""
        let index = everyTimeZonePlusSeparators.indexOf(selectedLabel)
        if let index = index {
            self.picker.selectRow(index, inComponent: 0, animated: false)
        }

        self.picker.snp_makeConstraints { (make) -> Void in
            make.left
                .right
                .top
                .bottom.equalTo(self.contentView)
        }
    }
}

// MARK: UIPickerViewDelegate and UIPickerViewDataSource methods

extension PickerViewTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    var separatorValue:String {
        return "-"
    }
    
    var everyTimeZonePlusSeparators: [String] {
        return TimeZoneConstants.usaTimeZonesKeys
            + [separatorValue]
            + TimeZoneConstants.ukTimeZonesKeys
            + [separatorValue]
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
        
        guard let viewModel = self.viewModel where selectedName != separatorValue else {
            // early return when don't have a view model, plus we must NOT be tapping on the separator
            return
        }
        
        let timezone : NSTimeZone? = TimeZoneConstants.managedTimeZones[selectedName]!
        if let timezone = timezone {
            viewModel.timeZone.value = timezone
        }
    }
}
