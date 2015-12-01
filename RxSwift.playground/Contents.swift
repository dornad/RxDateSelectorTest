//: Playground - noun: a place where people can play

import UIKit
import XCPlayground
import SnapKit

extension UIFont {
    
    public static func helveticaNeueLightFontWithSize(size:CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Light", size: size) ?? UIFont.systemFontOfSize(size)
    }
    
    public static func helveticaNeueMediumFontWithSize(size:CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Medium", size: size) ?? UIFont.systemFontOfSize(size)
    }
}


let picker = UISwitch()
picker.on = true
picker.onTintColor = UIColor(red:0.64, green:0.53, blue:0.25, alpha:1.0)

let button = UIButton(frame: CGRectMake(0,0,140,80))
button.backgroundColor = UIColor.blackColor()
button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
button.titleLabel?.font = UIFont.helveticaNeueLightFontWithSize(12)

// Using NSAttributedString to add a letter-spacing of 1.25 to the button label.
let title = NSLocalizedString("SAVE", comment: "Title of Save button in Date/Time picker")
let attributes = [NSFontAttributeName: UIFont.helveticaNeueMediumFontWithSize(12),
    NSForegroundColorAttributeName: UIColor.whiteColor(),
    NSKernAttributeName: CGFloat(1.25)]
let attributedString = NSAttributedString(string: title, attributes: attributes)
button.setAttributedTitle(attributedString, forState: .Normal)
//button.setTitle("Foo", forState: UIControlState.Normal)

//XCPlaygroundPage.currentPage.captureValue(button, withIdentifier: "Button")

class Cell : UITableViewCell {
    
    struct Constants {
        static let Identifier = "DatePicker"
    }
    
    var datePicker : UIDatePicker = UIDatePicker()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        
        self.datePicker.removeFromSuperview()
        self.datePicker.datePickerMode = .DateAndTime
        self.datePicker.date = NSDate()
        self.contentView.addSubview(self.datePicker)
        
        self.datePicker.snp_remakeConstraints(closure: { (make) -> Void in
            make.width.equalTo(self.contentView)
            make.height.equalTo(self.contentView)
        })

    }
}

class DataSource : NSObject, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Cell.Constants.Identifier) as? Cell
        
        if indexPath.row == 0 {
            cell?.textLabel?.text = "Foo"
//            cell?.configure()
        }
        return cell!
    }

}

let dataSrc = DataSource()
let tableView = UITableView(frame: CGRectMake(0,0,300,400), style: .Plain)
tableView.registerClass(Cell.self, forCellReuseIdentifier: Cell.Constants.Identifier)
tableView.dataSource = dataSrc

tableView.rowHeight = 214

tableView.sectionFooterHeight = 1

XCPlaygroundPage.currentPage.captureValue(tableView, withIdentifier: "Table")
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true






