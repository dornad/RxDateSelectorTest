//: Playground - noun: a place where people can play

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import XCPlayground

// Extensions for TestViewController

extension TestViewController : TestViewControllerFoo {
    
    public func headerInSection(rowDesc:RowDesc) -> UIView? {
        
        let header = UIView(frame: CGRectZero)
        sectionHeaderLabel(rowDesc, withSuperview: header)
        sectionHeaderAccessory(rowDesc, withSuperview: header)
        lineSeparator(withSuperview: header)
        
        return header
    }
    
    public func setupCell(cell: UITableViewCell, rowDesc: RowDesc) {
        
        cell.datePicker.removeFromSuperview()
        cell.contentView.addSubview(cell.datePicker)
        
        // TODO: RxSwift
        cell.datePicker.snp_makeConstraints { (make) -> Void in
            make.left
                .right
                .top
                .bottom.equalTo(cell.datePicker.superview!)
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

// TableViewCell

protocol DatePicker {
    var datePicker:UIDatePicker { get set }
}

extension UITableViewCell : DatePicker {
    
    private struct AssociatedKeys {
        static var DatePicker = "nsh_DatePicker"
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
}

// Test Code Starts here

let viewModel = ViewModel(startDate: NSDate())
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
