//
//  ViewController_UIExtensions.swift
//  Test
//
//  Created by Daniel Rodriguez on 11/12/15.
//  Copyright © 2015 PaperlessPost. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

// MARK: Two Way binding operator

// Two way binding operator between control property and variable, that's all it takes {
infix operator <-> {
}

func <-> <T>(property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
    let bindToUIDisposable = variable
        .bindTo(property)
    let bindToVariable = property
        .subscribe(onNext: { n in
            variable.value = n
            }, onCompleted:  {
                bindToUIDisposable.dispose()
        })
    
    return StableCompositeDisposable.create(bindToUIDisposable, bindToVariable)
}

func <-> <T>(property: ControlProperty<T?>, variable: Variable<T?>) -> Disposable {
    let bindToUIDisposable = variable
        .bindTo(property)
    let bindToVariable = property
        .subscribe(onNext: { n in
            variable.value = n
            }, onCompleted:  {
                bindToUIDisposable.dispose()
        })
    
    return StableCompositeDisposable.create(bindToUIDisposable, bindToVariable)
}


// MARK: Constants, Header, Footer and Cell Setup

extension RxViewController {
    
    internal struct UIConstants {
        
        // Table Constants
        static let tableHeaderHeight:CGFloat    = 50
        static let tableHeaderFrame:CGRect      = CGRectMake(0, 0, 180, UIConstants.tableHeaderHeight)
        static let tableFooterFrame:CGRect      = CGRectMake(0, 0, 180, 150)
        
        // Table Section Constants
        static let sectionHeaderHeight:CGFloat      = 40
        static let sectionHeaderLabelFrame:CGRect   = CGRect(x: 0, y: 0, width: 180, height: UIConstants.sectionHeaderHeight)
        
        // Table Row Constants
        static let rowHeight:CGFloat = 180
    }
    
    func tableHeaderView() -> UIView? {
        
        // for some reason snapkit doesn't like working with the header and footer.
        let sv = UIView(frame: UIConstants.tableHeaderFrame)
        tableHeaderLabel(withSuperview: sv)
        lineSeparator(withSuperview: sv)

        return sv
    }
    
    func tableFooterView() -> UIView? {
        
        // for some reason snapkit doesn't like working with the header and footer.
        let sv = UIView(frame: UIConstants.tableFooterFrame)
        tableFooterButton(withSuperview: sv)
        
        return sv
    }
    
    func headerInSection(rowDesc:RowDesc) -> UIView? {
        
        let header = UIView(frame: CGRectZero)
        sectionHeaderLabel(rowDesc, withSuperview: header)
        sectionHeaderAccessory(rowDesc, withSuperview: header)
        lineSeparator(withSuperview: header)
        addGestureRecognizerTo(rowDesc, toView: header)
        
        return header
    }
    
    func setupCell(cell:UITableViewCell, rowDesc:RowDesc) {
        
        setupStartDatePicker(cell, rowDesc: rowDesc)
        setupEndDatePicker(cell, rowDesc: rowDesc)
        setupTimezonePicker(cell, rowDesc: rowDesc)
    }
    
}

// MARK: UIControl functions (reusable)

extension RxViewController {
    
    func tableHeaderLabel(withSuperview sv:UIView) {
        
        let label: UILabel = UILabel(frame: CGRectZero)
        label.font = UIFont.helveticaNeueLightFontWithSize(20)
        label.textColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0)
        label.text = NSLocalizedString("(Rx) Event Date & Time", comment: "Title of Date/Time picker")
        sv.addSubview(label)
        
        label.snp_makeConstraints{ (make) -> Void in
            make.center.equalTo(label.superview!)
        }
    }
    
    func lineSeparator(withSuperview sv:UIView) {
        let separator = UIView()
        separator.backgroundColor = UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1)
        sv.addSubview(separator)
        
        separator.snp_makeConstraints{ (make) -> Void in
            make.left
                .right
                .bottom
                .equalTo(separator.superview!)
            make.height.equalTo(0.8)
        }
    }
    
    func tableFooterButton(withSuperview sv:UIView) {
        let button: UIButton = UIButton(type: .Custom)
        button.backgroundColor = UIColor.blackColor()
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont.helveticaNeueMediumFontWithSize(12)
        button.setTitle(NSLocalizedString("SAVE", comment: "Title of Save button in Date/Time picker"), forState: .Normal)
        
        sv.addSubview(button)
        
        button.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(150)
            make.height.equalTo(44)
            make.centerX.equalTo(sv)
            
            make.centerY.equalTo(sv)
            //make.top.equalTo(100)
        }
    }
    
    func sectionHeaderLabel(rowDesc:RowDesc , withSuperview sv:UIView) {
        
        let headerLabel: UILabel = UILabel(frame: UIConstants.sectionHeaderLabelFrame)
        headerLabel.font = UIFont.helveticaNeueMediumFontWithSize(12)
        headerLabel.text = rowDesc.type.toTitleString()
        sv.addSubview(headerLabel)
        
        headerLabel.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(sv).offset(10)
            make.centerY.equalTo(sv)
        }
    }
    
    func addGestureRecognizerTo(rowDesc:RowDesc, toView view:UIView) {
        
        guard rowDesc.type != .AllDay else {
            return
        }
        
        let singleTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("onTapInView:"))
        singleTapRecognizer.numberOfTouchesRequired = 1
        singleTapRecognizer.sectionType = rowDesc.type
        singleTapRecognizer.numberOfTouchesRequired = 1
        view.addGestureRecognizer(singleTapRecognizer)
    }
    
    @objc func onTapInView(sender:UITapGestureRecognizer) {

        if sender.state == .Ended {
            self.viewModel.selectedRowType.value = sender.sectionType
        }
    }
    
    func sectionHeaderAccessory(rowDesc:RowDesc, withSuperview sv:UIView) {
        
        var accessory = sectionHeaderLabelAccessory(rowDesc, withSuperview: sv)
        accessory = accessory ?? sectionHeaderSwitchAccessory(rowDesc, withSuperview: sv)
        
        if let accessory = accessory {
            accessory.snp_makeConstraints{ (make) -> Void in
                make.right.equalTo(accessory.superview!).offset(-20)
                make.centerY.equalTo(accessory.superview!)
            }
        }
    }
    
    func sectionHeaderLabelAccessory(rowDesc:RowDesc, withSuperview sv:UIView) -> UIView? {
        
        guard ((rowDesc.type.isDateType() || rowDesc.type == .TimeZone ) && rowDesc.state != .Missing) else {
            return nil
        }
        
        let label = UILabel(frame: UIConstants.sectionHeaderLabelFrame)
        label.textColor = UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1)
        label.font = UIFont.helveticaNeueLightFontWithSize(16)
        sv.addSubview(label)
        
        self.viewModel.getStringObservableForRowType(rowDesc.type)
            .bindTo(label.rx_text)
            .addDisposableTo(self.disposeBag)
        
        return label
    }
    
    func sectionHeaderSwitchAccessory(rowDesc: RowDesc, withSuperview sv:UIView) -> UIView? {
        guard rowDesc.type == .AllDay else {
            return nil
        }
        
        let allDaySwitch = UISwitch()
        
        allDaySwitch.rx_value <-> self.viewModel.allDay
        
        sv.addSubview(allDaySwitch)
        
        return allDaySwitch
    }
    
    func setupStartDatePicker(cell: UITableViewCell, rowDesc:RowDesc) {
        
        guard rowDesc.type == .StartDate else {
            return
        }
        
        cell.datePicker.removeFromSuperview()
        cell.contentView.addSubview(cell.datePicker)
        
//        cell.datePicker.rx_date <-> self.viewModel.startDate
        
        cell.datePicker.snp_makeConstraints { (make) -> Void in
            make.left
                .right
                .top
                .bottom.equalTo(cell.contentView)
        }
        
    }
    
    func setupEndDatePicker(cell: UITableViewCell, rowDesc:RowDesc) {
        
        guard rowDesc.type == .EndDate else {
            return
        }
        
        cell.datePicker.removeFromSuperview()
        cell.contentView.addSubview(cell.datePicker)
        
//        cell.datePicker.rx_date <-> self.viewModel.endDate
        
        cell.datePicker.snp_makeConstraints { (make) -> Void in
            make.left
                .right
                .top
                .bottom.equalTo(cell.contentView)
        }
        
    }
    
    
    func setupTimezonePicker(cell: UITableViewCell, rowDesc:RowDesc) {
        
        guard rowDesc.type == .TimeZone else {
            return
        }
        
        cell.timeZonePicker.removeFromSuperview()
        cell.contentView.addSubview(cell.timeZonePicker)
        cell.timeZonePicker.snp_makeConstraints { (make) -> Void in
            make.left
                .right
                .top
                .bottom.equalTo(cell.contentView)
        }
    }
}

// MARK: UIGestureRecognizer Additions

extension UIGestureRecognizer {
    private struct AssociatedKeys {
        static var SectionType = "pp_SectionType"
    }
    
    var sectionType:SectionType {
        get {
            let value = objc_getAssociatedObject(self, &AssociatedKeys.SectionType) as! Int
            return try! SectionType.fromInt(value)
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.SectionType, newValue.toInt(), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: UITableViewCell Additions

protocol RxDateAndTimeZonePicker {
    var datePicker:UIDatePicker { get set }
    var timeZonePicker:UIPickerView {get set}
}

extension UITableViewCell : RxDateAndTimeZonePicker {
    
    private struct AssociatedKeys {
        static var DatePicker = "pp_DatePicker"
        static var TimeZonePicker = "pp_TimeZonePicker"
    }
    
    var datePicker:UIDatePicker {
        get {
            var picker = objc_getAssociatedObject(self, &AssociatedKeys.DatePicker) as? UIDatePicker
            if picker == nil {
                picker = UIDatePicker()
                self.datePicker = picker!
            }
            return picker!
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.DatePicker, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var timeZonePicker:UIPickerView {
        get {
            var picker = objc_getAssociatedObject(self, &AssociatedKeys.TimeZonePicker) as? UIPickerView
            if picker == nil {
                picker = UIPickerView()
                picker?.delegate = self
                picker?.dataSource = self
                self.timeZonePicker = picker!
            }
            return picker!
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.TimeZonePicker, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UITableViewCell: UIPickerViewDataSource, UIPickerViewDelegate {
    
    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return NSTimeZone.knownTimeZoneNames().count
    }
    
    public func pickerView(pickerView: UIPickerView,titleForRow row: Int,forComponent component: Int) -> String? {
        // might be worth looking into: http://stackoverflow.com/questions/31338724/how-to-get-full-time-zone-name-ios
        return NSTimeZone.knownTimeZoneNames()[row]
    }
    
    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let selectedName = NSTimeZone.knownTimeZoneNames()[row]
        print("you selected: \(selectedName)")
    }
}
