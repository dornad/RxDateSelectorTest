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

/**
*  A "<->" operator that will allow us to create two-way bindings.
*/
infix operator <-> {
}

/**
 Implementation of the two-way binding operator between a ControlProperty<T>
 and a Variable<T>.
 
 - parameter property: The property from the UI element that we want to bind against.
 - parameter variable: An Observable source that we want to watch as well.
 
 - returns: A composite binding between the property and the Variable
 */
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

/**
 Implementation of the two-way binding operator between a ControlProperty<T>
 and an (optional) Variable<T?>.
 
 - parameter property: The property from the UI element that we want to bind against.
 - parameter variable: An Observable source that we want to watch as well, but that it may 
 not have a value.
 
 - returns: A composite binding between the property and the Variable
 */
func <-> <T>(property: ControlProperty<T>, variable: Variable<T?>) -> Disposable {
    let bindToUIDisposable =
        variable
            .filter({ $0 != nil })
            .map { return $0! }
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
    
    /**
     *  Constants for SnapKit.
     */
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
    
    /**
     Returns the table's header view.
     
     - returns: An UIView? instance.
     */
    func tableHeaderView() -> UIView? {
        
        // for some reason snapkit doesn't like working with the header and footer.
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
        
        // for some reason snapkit doesn't like working with the header and footer.
        let sv = UIView(frame: UIConstants.tableFooterFrame)
        tableFooterButton(withSuperview: sv)
        
        return sv
    }
    
    /**
     Returns the header (UIView?) for a specific table.
     
     - parameter sectionDesc: A model that describes how should the header be built
     
     - returns: An UIView? instance.
     */
    func headerInSection(sectionDesc:SectionDesc) -> UIView? {
        
        let header = UIView(frame: CGRectZero)
        sectionHeaderLabel(sectionDesc, withSuperview: header)
        sectionHeaderAccessory(sectionDesc, withSuperview: header)
        lineSeparator(withSuperview: header)
        addGestureRecognizerTo(sectionDesc, toView: header)
        
        return header
    }
    
    /**
     Perform setup of a UITableViewCell that was (recently) dequed for a specific NSIndexPath
     
     More specifically, this method will create the picker(s), according to data inside the 'sectionDesc' param
     
     - parameter cell:    the cell we are setting up.
     - parameter sectionDesc: A model that describes how to configure the cell.
     */
    func setupCell(cell:UITableViewCell, sectionDesc:SectionDesc) {
        
        setupStartDatePicker(cell, sectionDesc: sectionDesc)
        setupEndDatePicker(cell, sectionDesc: sectionDesc)
        setupTimezonePicker(cell, sectionDesc: sectionDesc)
    }
    
}

// MARK: UIControl build functions (reusable)

extension RxViewController {
    
    /**
     Util function that adds a label to a UIView.  Used in the table header.
     
     - parameter sv: the superview to attach the label to
     */
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
                make.right.equalTo(accessory.superview!).offset(-20)
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
        
        let allDaySwitch = UISwitch()
        
        // Two way binding allows bidirectional changes: 
        // - a change on the view model triggers a change on the UI element
        // - a change on the UIElement triggers a change on the view model.
        allDaySwitch.rx_value <-> self.viewModel.allDay
        
        sv.addSubview(allDaySwitch)
        
        return allDaySwitch
    }
}

// MARK: Picker (Date and TimeZone) Configuration

extension RxViewController {
    
    /**
     Perform the configuration of the table row cell as a date picker for the start date.
     
     - parameter cell:    The UITableViewCell instance that will be configured
     - parameter sectionDesc: A model that describes how should the cell be configured
     */
    func setupStartDatePicker(cell: UITableViewCell, sectionDesc:SectionDesc) {
        
        guard sectionDesc.type == .StartDate else {
            // Exit when the row type is not the start date.
            return
        }
        
        cell.datePicker.removeFromSuperview()
        cell.timeZonePicker.removeFromSuperview()
        cell.contentView.addSubview(cell.datePicker)
        
        // Two way binding allows bidirectional changes:
        // - a change on the view model triggers a change on the UI element
        // - a change on the UIElement triggers a change on the view model.
        cell.datePicker.rx_date <-> self.viewModel.startDate
        
        cell.datePicker.snp_makeConstraints { (make) -> Void in
            make.left
                .right
                .top
                .bottom.equalTo(cell.contentView)
        }
    }
    
    /**
     Perform the configuration of the table row cell as a date picker for the end date.
     
     - parameter cell:    The UITableViewCell instance that will be configured
     - parameter sectionDesc: A model that describes how should the cell be configured
     */
    func setupEndDatePicker(cell: UITableViewCell, sectionDesc:SectionDesc) {
        
        guard sectionDesc.type == .EndDate else {
            // Exit when the row type is not the end date.
            return
        }
        
        cell.datePicker.removeFromSuperview()
        cell.timeZonePicker.removeFromSuperview()
        cell.contentView.addSubview(cell.datePicker)
        
        // Two way binding allows bidirectional changes:
        // - a change on the view model triggers a change on the UI element
        // - a change on the UIElement triggers a change on the view model.
        cell.datePicker.rx_date <-> self.viewModel.endDate
        
        cell.datePicker.snp_makeConstraints { (make) -> Void in
            make.left
                .right
                .top
                .bottom.equalTo(cell.contentView)
        }
    }
    
    /**
     Perform the configuration of the table row cell as a picker for the timezone
     
     - parameter cell:    The UITableViewCell instance that will be configured
     - parameter sectionDesc: A model that describes how should the cell be configured
     */
    func setupTimezonePicker(cell: UITableViewCell, sectionDesc:SectionDesc) {
        
        guard sectionDesc.type == .TimeZone else {
            return
        }
        
        cell.datePicker.removeFromSuperview()
        cell.timeZonePicker.removeFromSuperview()
        cell.contentView.addSubview(cell.timeZonePicker)
        
        // RxSwift has no reactive extension for UIPickerView

        // TODO: Create a Rx extension for UIPickerView
        
        cell.timeZonePicker.snp_makeConstraints { (make) -> Void in
            make.left
                .right
                .top
                .bottom.equalTo(cell.contentView)
        }
    }
}

// MARK: Interactivity

extension RxViewController {
    
    /**
     Adds a gesture recognizer to a view.
     
     - parameter sectionDesc: A model that describes the current section.
     - parameter view:    the view where we will attach the UIGestureRecognizer
     */
    func addGestureRecognizerTo(sectionDesc:SectionDesc, toView view:UIView) {
        
        // We are adding gesture recognizer on all section header's, except for the "All Day" section
        guard sectionDesc.type != .AllDay else {
            return
        }
        
        let singleTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("onTapInView:"))
        singleTapRecognizer.numberOfTouchesRequired = 1
        singleTapRecognizer.sectionType = sectionDesc.type
        singleTapRecognizer.numberOfTouchesRequired = 1
        view.addGestureRecognizer(singleTapRecognizer)
    }
    
    /**
     Callback action for the Tap Gesture Recognizer.
     
     - parameter sender: The Tap Gesture Recognizer.
     */
    @objc func onTapInView(sender:UITapGestureRecognizer) {
        
        if sender.state == .Ended {
            
            self.viewModel.selectedRowType.value = sender.sectionType
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

// MARK: UITableViewCell Additions

extension UITableViewCell  {
    
    private struct AssociatedKeys {
        static var DatePicker = "pp_DatePicker"
        static var TimeZonePicker = "pp_TimeZonePicker"
    }

    /// Use Associated Objects to add a date picker property to the UITableViewCell
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
    
    /// Use Associated Objects to add a time zone picker property to the UITableViewCell
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

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate implementations inside UITableViewCell.

// (this will probably be removed once we implement a Rx datasource)

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
        // TODO: Connect the picker view and the view model.
        let selectedName = NSTimeZone.knownTimeZoneNames()[row]
        print("you selected: \(selectedName)")
    }
}
