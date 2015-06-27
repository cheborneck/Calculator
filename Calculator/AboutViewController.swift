//
//  AboutViewController.swift
//  Calculator
//
//  Created by Thomas Hare on 6/27/15.
//  Copyright (c) 2015 Thomas Hare. All rights reserved.
//

import UIKit

@IBDesignable
class AboutViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // blur the background image for effect
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        visualEffectView.frame = imageView.bounds
        imageView.addSubview(visualEffectView)
    }

}
