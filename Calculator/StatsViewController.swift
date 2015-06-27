//
//  StatsViewController.swift
//  Calculator
//
//  Created by Thomas Hare on 6/16/15.
//  Copyright (c) 2015 Thomas Hare. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController {

    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.text = text
        }
    }

    internal var text: String = "" {
        didSet {
            textView?.text = text
        }
    }
    
    override var preferredContentSize: CGSize {
        get {
            if textView != nil && presentingViewController != nil {
                return textView.sizeThatFits(presentingViewController!.view.bounds.size)
            }
            return super.preferredContentSize
        }
        set { super.preferredContentSize = newValue }
    }
    
}
