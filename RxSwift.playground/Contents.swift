//: Playground - noun: a place where people can play

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import XCPlayground

extension TestViewController : TestViewControllerPlaygroundExtensions {
    
    struct UIConstants {
        static let tableHeaderFrame:CGRect = CGRectMake(0, 0, 180, 50)
        static let tableFooterFrame:CGRect = CGRectMake(0, 0, 180, 150)
    }
    
    public func tableHeaderView() -> UIView? {
        
        // for some reason snapkit doesn't like working with the header and footer.
        let sv = UIView(frame: UIConstants.tableHeaderFrame)
        tableHeaderLabel(withSuperview: sv)
        lineSeparator(withSuperview: sv)
        return sv
    }
    
    public func tableFooterView() -> UIView? {
        
        // for some reason snapkit doesn't like working with the header and footer.
        let sv = UIView(frame: UIConstants.tableFooterFrame)
        tableFooterButton(withSuperview: sv)
        
        return sv
    }
    
    public func headerInSection(rowDesc:RowDesc) -> UIView? {
        
        let header = UIView(frame: CGRectZero)
        sectionHeaderLabel(rowDesc, withSuperview: header)
        sectionHeaderAccessory(rowDesc, withSuperview: header)
        lineSeparator(withSuperview: header)
        
        return header
    }
    
    public func setupCell(cell:UITableViewCell, rowDesc:RowDesc) {
        
        guard rowDesc.type.isDateType() || rowDesc.type == .TimeZone else {
            return
        }
        
        let picker = rowDesc.type.isDateType() ? cell.datePicker : cell.timeZonePicker
        picker.removeFromSuperview()
        cell.contentView.addSubview(picker)
        
        // TODO: RxSwift
        
        picker.snp_makeConstraints { (make) -> Void in
            make.left
                .right
                .top
                .bottom.equalTo(cell.contentView)
        }
    }
    
    @objc func datePicked(sender:AnyObject) {
        self.viewModel.startDate = (sender as? UIDatePicker)?.date
        self.tableView.reloadData()
    }
}

extension TestViewController {
    
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
        
        let headerLabel: UILabel = UILabel(frame: CGRectZero)
        headerLabel.font = UIFont.helveticaNeueMediumFontWithSize(12)
        headerLabel.text = rowDesc.type.toTitleString()
        sv.addSubview(headerLabel)
        
        headerLabel.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(headerLabel.superview!).offset(10)
            make.centerY.equalTo(headerLabel.superview!)
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
        
        let label = UILabel(frame: CGRectZero)
        label.textColor = UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1)
        label.font = UIFont.helveticaNeueLightFontWithSize(16)
        label.text = self.viewModel.getObservableForSectionType(rowDesc.type)
        sv.addSubview(label)
        
        // TODO: Add RxSwift bindings
        
        return label
    }
    
    func sectionHeaderSwitchAccessory(rowDesc: RowDesc, withSuperview sv:UIView) -> UIView? {
        guard rowDesc.type == .AllDay else {
            return nil
        }
        
        let allDaySwitch = UISwitch()
        allDaySwitch.on = self.viewModel.allDay
        sv.addSubview(allDaySwitch)
        
        return allDaySwitch
    }
    
    
}

// UITableViewCell

protocol DateAndTimeZonePicker {
    var datePicker:UIDatePicker { get set }
    var timeZonePicker:UIPickerView {get set}
}

extension UITableViewCell : DateAndTimeZonePicker {
    
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

// Test Code Starts here

let viewModel = ViewModel()
let ctrl = TestViewController(viewModel: viewModel)

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = ctrl.view

// Uncomment to simulate the initial opening
//viewModel.selectedRowType = .StartDate

// Uncomment to simulate choosing a start date
//viewModel.startDate = firstDate

// Uncomment to simulate tapping on the next element
//viewModel.selectedRowType = .EndDate

// Uncomment to simulate choosing an end date
//viewModel.endDate = secondDate

//: [Next](@next)
