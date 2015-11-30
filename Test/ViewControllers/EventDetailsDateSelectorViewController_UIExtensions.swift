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

// MARK: Constants, Header, Footer and Cell Setup

extension EventDetailsDateSelectorViewController {
    
    /**
     *  Constants for SnapKit.
     */
    internal struct UIConstants {
        
        // Cell Identifiers
        static let StartDateCellId  = "StartDateCellId"
        static let EndDateCellId    = "EndDateCellId"
        static let TimeZoneCellId   = "TimeZoneDateCellId"
        
        // Table Constants
        static let tableHeaderHeight:CGFloat    = 50
        static let tableHeaderFrame:CGRect      = CGRectMake(0, 0, 180, UIConstants.tableHeaderHeight)
        static let tableFooterFrame:CGRect      = CGRectMake(0, 0, 180, 150)
        
        // Table Section Constants
        static let sectionHeaderHeight:CGFloat      = 40
        static let sectionHeaderViewFrame:CGRect    = CGRect(x: 0, y: 0, width: 180, height: UIConstants.sectionHeaderHeight)
        static let sectionHeaderLabelFrame:CGRect   = UIConstants.sectionHeaderViewFrame
        
        // Table Row Constants
        static let rowHeightClosed:CGFloat      = 10
        static let rowHeightExpanded:CGFloat    = 214
    }
    
    /**
     Returns the table's header view.
     
     - returns: An UIView? instance.
     */
    func tableHeaderView() -> UIView? {
        
        let sv = UIView(frame: UIConstants.tableHeaderFrame)
        tableHeaderLabel(withSuperview: sv)
        lineSeparator(withSuperview: sv)

        return sv
    }
    
    /**
     Returns the table's footer view.
     
     - returns: An UIView? type
     */
    func tableFooterView() -> UIView? {
        
        let sv = UIView(frame: UIConstants.tableFooterFrame)
        tableFooterButton(withSuperview: sv)
        
        return sv
    }
    
    /**
     Returns the header (UIView?) for a specific table.
     
     - parameter sectionDesc: A model that describes how should the header be built
     
     - returns: An UIView? instance.
     */
    public func headerInSection(sectionDesc:SectionDesc) -> UIView? {
        
        let header = UIView(frame: UIConstants.sectionHeaderViewFrame)
        sectionHeaderLabel(sectionDesc, withSuperview: header)
        sectionHeaderAccessory(sectionDesc, withSuperview: header)
        lineSeparator(withSuperview: header)
        addGestureRecognizerTo(sectionDesc, toHeaderView: header)
        
        return header
    }
}

// MARK: UIControl build functions (reusable)

extension EventDetailsDateSelectorViewController {
    
    /**
     Util function that adds a label to a UIView.  Used in the table header.
     
     - parameter sv: the superview to attach the label to
     */
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
    
    /**
     Util function that adds a line separator to a UIView.  Used in table header, sections header views and table footers
     
     - parameter sv: the superview to attach the separator to
     */
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
    
    /**
     Util function that adds button to a UIView superview.  Used for the "save" button in the table footer view.
     
     - parameter sv: the superview to attach the label to
     */
    func tableFooterButton(withSuperview sv:UIView) {
        let button: UIButton = UIButton(type: .Custom)
        button.backgroundColor = UIColor.blackColor()
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont.helveticaNeueMediumFontWithSize(12)
        button.setTitle(NSLocalizedString("SAVE", comment: "Title of Save button in Date/Time picker"), forState: .Normal)
        
        button.rx_tap
            .subscribeNext { [weak self]() -> Void in
                
                print("Response: \(self?.viewModel.response)")
                self?.dismissViewControllerAnimated(true, completion: nil)
            }
            .addDisposableTo(self.disposeBag)
        
        sv.addSubview(button)
        
        button.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(150)
            make.height.equalTo(44)
            make.centerX.equalTo(sv)
            make.centerY.equalTo(sv)
        }
    }
    
    /**
     Util function that builds the section header view's label.
     
     - parameter sectionDesc: A model that describes how should the header be built
     - parameter sv:      The root UIView of the section header view.
     */
    func sectionHeaderLabel(sectionDesc:SectionDesc , withSuperview sv:UIView) {
        
        let headerLabel: UILabel = UILabel(frame: UIConstants.sectionHeaderLabelFrame)
        headerLabel.font = UIFont.helveticaNeueMediumFontWithSize(12)
        headerLabel.text = sectionDesc.type.toTitleString()
        sv.addSubview(headerLabel)
        
        headerLabel.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(sv).offset(10)
            make.centerY.equalTo(sv)
        }
    }
    
    /**
     Util function that builds the section header accessory.  
     
     The accessory is determined by the data in the sectionDesc param, and it can be either
     a label or a UISwitch.
     
     - parameter sectionDesc: A model that describes how should the accessory be built
     - parameter sv:      The root UIView of the section header view.
     */
    func sectionHeaderAccessory(sectionDesc:SectionDesc, withSuperview sv:UIView) {
        
        var accessory = sectionHeaderLabelAccessory(sectionDesc, withSuperview: sv)
        accessory = accessory ?? sectionHeaderSwitchAccessory(sectionDesc, withSuperview: sv)
        
        if let accessory = accessory {
            accessory.snp_makeConstraints{ (make) -> Void in
                make.right.equalTo(accessory.superview!)
                    .offset(-20)
                    .priorityLow()
                make.centerY.equalTo(accessory.superview!)
            }
        }
    }
    
    /**
     Util function that builds and configure a UILabel as a section header accessory.
     
     - parameter sectionDesc: A model that describes how should the accessory be built
     - parameter sv:      The root UIView of the section header view.
     */
    func sectionHeaderLabelAccessory(sectionDesc:SectionDesc, withSuperview sv:UIView) -> UIView? {
        
        guard ((sectionDesc.type.isDateType() || sectionDesc.type == .TimeZone ) && sectionDesc.state != .Missing) else {
            return nil
        }
        
        let label = UILabel(frame: UIConstants.sectionHeaderLabelFrame)
        label.textColor = UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1)
        label.font = UIFont.helveticaNeueLightFontWithSize(16)
        sv.addSubview(label)
        
        if sectionDesc.type == .EndDate && sectionDesc.selectionState == .Selected {
            
            let button = UIButton(type: UIButtonType.Custom)
            button.setImage(UIImage.init(named: "closeBtn"), forState: UIControlState.Normal)
            sv.addSubview(button)
            
            button.rx_tap
                .subscribeNext { [weak self] () -> Void in
                    self?.viewModel.endDate.value = nil
                    self?.viewModel.selectedRowType.value = .StartDate
                }
                .addDisposableTo(disposeBag)
            
            button.snp_makeConstraints { (make) -> Void in
                make.left.equalTo(label.snp_right).offset(5)
                make.right.equalTo(sv).offset(-10)
                make.centerY.equalTo(sv)
            }
        }
        
        // Bind the label's text to the ViewModel's respective data.
        self.viewModel.getStringObservableForRowType(sectionDesc.type)
            .bindTo(label.rx_text)
            .addDisposableTo(self.disposeBag)
        
        return label
    }
    
    /**
     Util function that builds and configure a UISwitch as a section header accessory.
     
     - parameter sectionDesc: A model that describes how should the accessory be built
     - parameter sv:      The root UIView of the section header view.
     */
    func sectionHeaderSwitchAccessory(sectionDesc: SectionDesc, withSuperview sv:UIView) -> UIView? {
        
        guard sectionDesc.type == .AllDay else {
            return nil
        }
        
        // note: UISwitch's rx_value causes a crash, thus we are using the vanilla (target-action) approach from UIKit.
        
        let allDaySwitch = UISwitch()
        allDaySwitch.on = self.viewModel.allDay.value
        allDaySwitch.addTarget(self, action: Selector("onAllDaySwitchChange:"), forControlEvents: UIControlEvents.ValueChanged)
        sv.addSubview(allDaySwitch)
        return allDaySwitch
    }
    
    /**
     Event responder for all day switch flip.
     
     - parameter sender: the UISwitch instance.
     */
    @objc func onAllDaySwitchChange(sender:UISwitch) {
        self.viewModel.allDay.value = sender.on
    }
}

// MARK: Interactivity

extension EventDetailsDateSelectorViewController {
    
    /**
     Adds a gesture recognizer to a header view.
     
     - parameter sectionDesc: A model that describes the current section.
     - parameter view:    the view where we will attach the UIGestureRecognizer
     */
    func addGestureRecognizerTo(sectionDesc:SectionDesc, toHeaderView view:UIView) {
        
        // We are adding gesture recognizer on all section header's, except for the "All Day" section
        guard sectionDesc.type != .AllDay else {
            return
        }
        
        // Note:  There is a Rx addition to make gesture recognizer's compatible with RxSwift.  Could not make it work though :(
        
        let singleTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("onTapInView:"))
        singleTapRecognizer.numberOfTouchesRequired = 1
        singleTapRecognizer.sectionType = sectionDesc.type
        view.addGestureRecognizer(singleTapRecognizer)
    }
    
    /**
     Callback action for the Tap Gesture Recognizer.
     
     - parameter sender: The Tap Gesture Recognizer.
     */
    @objc func onTapInView(sender:UITapGestureRecognizer) {
        
        if sender.state == .Ended {
            
            tableView.beginUpdates()
            
            let previousSelection = self.viewModel.selectedRowType.value?.toInt()
            let current = sender.sectionType.toInt()
            
            let indexSet:NSMutableIndexSet = NSMutableIndexSet(index: current)
            if let previousSelection = previousSelection {
                indexSet.addIndex(previousSelection)
            }
            
            self.viewModel.selectedRowType.value = sender.sectionType
            tableView.reloadSections(indexSet, withRowAnimation: UITableViewRowAnimation.None)
            
            tableView.endUpdates()
            
        }
    }
    
}

// MARK: UIGestureRecognizer Additions

extension UIGestureRecognizer {
    private struct AssociatedKeys {
        static var SectionType = "pp_SectionType"
    }
    
    /// Use Associated Objects to add a SectionType property to the UIGestureRecognizer
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
