
import UIKit

public protocol TestViewControllerPlaygroundExtensions {
    func setupCell(cell:UITableViewCell, rowDesc:RowDesc)
    func headerInSection(rowDesc:RowDesc) -> UIView?
    func tableHeaderView() -> UIView?
    func tableFooterView() -> UIView?
}

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
        self.view?.addSubview(tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.tableHeaderView = (self as? TestViewControllerPlaygroundExtensions)?.tableHeaderView()
        self.tableView.tableFooterView = (self as? TestViewControllerPlaygroundExtensions)?.tableFooterView()
        
    }
}

extension TestViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.rows.count
    }
  
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let st = viewModel.rows[section].state
        return st == .Selected ? 1 : 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let rowDesc = viewModel.rows[indexPath.section]
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        (self as? TestViewControllerPlaygroundExtensions)?.setupCell(cell, rowDesc: rowDesc)
        return cell
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let rowDesc = viewModel.rows[section]
        let view = (self as? TestViewControllerPlaygroundExtensions)?.headerInSection(rowDesc)
        return view
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 200
    }
}

extension UIFont {
    public static func helveticaNeueLightFontWithSize(size:CGFloat) -> UIFont {
        return UIFont.systemFontOfSize(size)
    }
    
    public static func helveticaNeueMediumFontWithSize(size:CGFloat) -> UIFont {
        return UIFont.systemFontOfSize(size)
    }
}

