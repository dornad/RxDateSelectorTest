//: Playground - noun: a place where people can play

import UIKit
import XCPlayground
import SnapKit


/**
 Util function that builds the section header accessory.
 
 The accessory is determined by the data in the sectionDesc param, and it can be either
 a label or a UISwitch.
 
 - parameter sectionDesc: A model that describes how should the accessory be built
 - parameter sv:      The root UIView of the section header view.
 */
func sectionHeaderAccessory(withSuperview sv:UIView, shouldAddClearButton addClearButton:Bool = true) {
    
    let accessory = sectionHeaderLabelAccessory(sv, shouldAddClearButton: addClearButton)
    
    if let accessory = accessory {
        
//        accessory.layer.borderColor = UIColor.greenColor().CGColor
//        accessory.layer.borderWidth = 2.0
        
        accessory.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(sv)
            make.right.equalTo(sv).offset(-20)
            make.centerY.equalTo(sv)
        }
    }
}

/**
 Util function that builds and configure a UILabel as a section header accessory.
 
 - parameter sectionDesc: A model that describes how should the accessory be built
 - parameter sv:      The root UIView of the section header view.
 */
func sectionHeaderLabelAccessory(sv:UIView, shouldAddClearButton addClearButton:Bool = true) -> UIView? {
    
    // Label
    let label = UILabel(frame: CGRectZero)
    label.textColor = UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1)
    label.text = "This is a test"
    label.textColor = UIColor.whiteColor()
    label.font = UIFont.systemFontOfSize(16)
    sv.addSubview(label)
    label.snp_makeConstraints(closure: { (make) -> Void in
        make.edges.equalTo(sv).inset(UIEdgeInsetsMake(20, 20, 20, 20))
    })
    
    label.layer.borderColor = UIColor.redColor().CGColor
    label.layer.borderWidth = 2.0
    
    if addClearButton {
        
        // New Parent
        let labelButtonParent = UIView(frame: CGRectZero)
        sv.addSubview(labelButtonParent)
        labelButtonParent.snp_makeConstraints(closure: { (make) -> Void in
            make.edges.equalTo(sv).inset(UIEdgeInsetsMake(1, 1, 1, 1))
        })
        
        // Reparent Label
        label.removeFromSuperview()
        labelButtonParent.addSubview(label)
        label.snp_remakeConstraints(closure: { (make) -> Void in
            make.top.equalTo(labelButtonParent).offset(10)
            make.bottom.equalTo(labelButtonParent).offset(-10)
            make.left.greaterThanOrEqualTo(labelButtonParent).offset(20)
            make.right.lessThanOrEqualTo(labelButtonParent).offset(-20)
        })
        
        // Add Button
        let button = UIButton(type: UIButtonType.ContactAdd)
        let angle: CGFloat = CGFloat( M_PI * (45.0) / 180.0 )
        button.transform = CGAffineTransformConcat(
            CGAffineTransformMakeScale(0.75, 0.75),
            CGAffineTransformMakeRotation(angle));
        button.tintColor = UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1)
        labelButtonParent.addSubview(button)
        button.snp_makeConstraints(closure: { (make) -> Void in
            make.centerY.equalTo(label)
            make.left.equalTo(label.snp_right).offset(5)
            make.right.equalTo(labelButtonParent)
        })
        
        return labelButtonParent
    }
    else {
        
        return label
    }
}

let view = UIView(frame: CGRect(x: 0,y: 0,width: 280,height: 60))
sectionHeaderAccessory(withSuperview: view, shouldAddClearButton: false)

XCPlaygroundPage.currentPage.liveView = view
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
