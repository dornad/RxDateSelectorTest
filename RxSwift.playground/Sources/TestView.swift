
import UIKit

public class TestViewController : UIViewController {

    public var tableView:UITableView!
    public var viewModel:EventDetailsDateSelectorViewModel!
    
    public init(viewModel:EventDetailsDateSelectorViewModel?) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension TestViewController {
    
    override public func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.frame = CGRect(x: 0,y: 0,width: 320,height: 480)
        self.tableView = UITableView(frame: self.view!.frame, style: .Grouped)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view?.addSubview(tableView)
    }
}

extension TestViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.rows.count
    }
  
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let st = viewModel.rows[section]
        return st.type == .StartDate ? 1 : 0
        //        let st = viewModel.rows[section].state
        //        return st == .Selected ? 1 : 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let rowDesc = viewModel.rows[indexPath.section]
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        (self as? TestViewControllerFoo)?.setupCell(cell, rowDesc: rowDesc)
        return cell
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let rowDesc = viewModel.rows[section]
        return (self as? TestViewControllerFoo)?.headerInSection(rowDesc)
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 200
    }
}

public protocol TestViewControllerFoo {
    func headerInSection(rowDesc : RowDesc) -> UIView?
    func setupCell(cell:UITableViewCell, rowDesc:RowDesc)
}

extension UIFont {
    public static func helveticaNeueLightFontWithSize(size:CGFloat) -> UIFont {
        return UIFont.systemFontOfSize(size)
    }
    
    public static func helveticaNeueMediumFontWithSize(size:CGFloat) -> UIFont {
        return UIFont.systemFontOfSize(size)
    }
}

