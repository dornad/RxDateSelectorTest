//
//  ViewController_UIExtensions.swift
//  Test
//
//  Created by Daniel Rodriguez on 11/12/15.
//  Copyright © 2015 PaperlessPost. All rights reserved.
//

import UIKit
import SnapKit

// MARK: Constants, Header, Footer and Cell Setup

extension ViewController {
    
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
        
        return header
    }
    
    func setupCell(cell:UITableViewCell, rowDesc:RowDesc) {
        
        setupStartDatePicker(cell, rowDesc: rowDesc)
        setupEndDatePicker(cell, rowDesc: rowDesc)
        setupTimezonePicker(cell, rowDesc: rowDesc)
    }
    
}

// MARK: UIControl functions (reusable)

extension ViewController {
    
    func tableHeaderLabel(withSuperview sv:UIView) {
        
        let label: UILabel = UILabel(frame: CGRectZero)
        label.font = UIFont.helveticaNeueLightFontWithSize(20)
        label.textColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0)
        label.text = NSLocalizedString("Event Date & Time", comment: "Title of Date/Time picker")
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
            self.viewModel.selectedRowType = sender.sectionType
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
        label.text = self.viewModel.getStringForRowType(rowDesc.type)
        sv.addSubview(label)
        
        return label
    }
    
    func sectionHeaderSwitchAccessory(rowDesc: RowDesc, withSuperview sv:UIView) -> UIView? {
        guard rowDesc.type == .AllDay else {
            return nil
        }
        
        let allDaySwitch = UISwitch()
        allDaySwitch.on = viewModel.allDay
        
        // this version doesn't save the dare
        
        sv.addSubview(allDaySwitch)
        
        return allDaySwitch
    }
    
    func setupStartDatePicker(cell: UITableViewCell, rowDesc:RowDesc) {
        
        guard rowDesc.type == .StartDate else {
            return
        }
        
        cell.datePicker.removeFromSuperview()
        cell.contentView.addSubview(cell.datePicker)
        cell.datePicker.addTarget(self, action: Selector("startDatePickerChanged"), forControlEvents: .ValueChanged)
        
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
        cell.datePicker.addTarget(self, action: Selector("endDatePickerChanged"), forControlEvents: .ValueChanged)
        
        cell.datePicker.snp_makeConstraints { (make) -> Void in
            make.left
                .right
                .top
                .bottom.equalTo(cell.contentView)
        }
        
    }
    
    @objc func startDatePickerChange(sender:UIDatePicker) {
        viewModel.startDate = sender.date        
    }
    @objc func endDatePickerChange(sender:UIDatePicker) {
        viewModel.endDate = sender.date
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
