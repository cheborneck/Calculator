//
//  GlobalSplitViewController.swift
//  Calculator
//
//  Created by Thomas Hare on 6/17/15.
//  Copyright (c) 2015 Thomas Hare. All rights reserved.
//

import UIKit

class GlobalSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    // used to default the initial display to the master controller in the split view instead of defaulting to the detail controller
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
        return true
    }
    
}
