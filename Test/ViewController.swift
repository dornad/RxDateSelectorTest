//
//  ViewController.swift
//  Test
//
//  Created by Daniel Rodriguez on 11/10/15.
//  Copyright © 2015 PaperlessPost. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension UIFont {
    static func helveticaNeueLightFontWithSize(size:CGFloat) -> UIFont {
        return UIFont.systemFontOfSize(size)
    }
    
    static func helveticaNeueMediumFontWithSize(size:CGFloat) -> UIFont {
        return UIFont.systemFontOfSize(size)
    }
}

