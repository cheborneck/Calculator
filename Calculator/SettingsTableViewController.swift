//
//  SettingsTableViewController.swift
//  Calculator
//
//  Created by Thomas Hare on 6/24/15.
//  Copyright (c) 2015 Thomas Hare. All rights reserved.
//

import UIKit

protocol SettingsTableViewControllerDelegate {
//    func myVCDidFinish(effect: Bool, dPrecision: Double, hPrecision: Double, click: Bool)
    func myVCDidFinish(settings: Settings)
}

class SettingsTableViewController: UITableViewController {
    
    var delegate: SettingsTableViewControllerDelegate?
    
    var settings = Settings()

    @IBOutlet weak var button3DEffect: UISwitch!
    
    @IBOutlet weak var buttonClick: UISwitch!
    
    @IBOutlet weak var displayPrecisionTextField: UITextField!
    
    @IBOutlet weak var displayPrecisionStepper: UIStepper!
    
    @IBOutlet weak var historyPrecisionTextField: UITextField!
    
    @IBOutlet weak var historyPrecisionStepper: UIStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        historyPrecisionStepper.minimumValue = 0
        historyPrecisionStepper.maximumValue = 10
        historyPrecisionStepper.value = settings.historyPrecision
        historyPrecisionTextField.text = String(format: "%g", settings.historyPrecision)
        
        displayPrecisionStepper.minimumValue = 0
        displayPrecisionStepper.maximumValue = 10
        displayPrecisionStepper.value = settings.displayPrecision
        displayPrecisionTextField.text = String(format: "%g", settings.displayPrecision)
        
        button3DEffect.on = settings.buttonEffect
        buttonClick.on = settings.keyAlert
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }

    @IBAction func StepperChanged(sender: UIStepper) {
        let thisStepper = sender as UIStepper
        switch thisStepper.tag {
        case 0: // history precision setting
            historyPrecisionTextField.text = String(format: "%g", thisStepper.value)
            settings.historyPrecision = thisStepper.value
        case 1: // main display precision setting
            displayPrecisionTextField.text = String(format: "%g", thisStepper.value)
            settings.displayPrecision = thisStepper.value
        default:
            break
        }
    }
    
    // MARK:  UIView related methods
    
    // make sure the navigation bar is turned on so we can get back
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = "Settings"
    }
    
    override func viewWillDisappear(animated: Bool) {
        // prepare and send the data back to the controller
        settings.buttonEffect = button3DEffect.on
        settings.displayPrecision = displayPrecisionStepper.value
        settings.historyPrecision = historyPrecisionStepper.value
        settings.keyAlert = buttonClick.on
        delegate?.myVCDidFinish(settings)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as? UIViewController
        if let nc = destination as? UINavigationController {
            destination = nc.visibleViewController
        }
        
        if let avc = destination as? AboutViewController {
            if let identifier = segue.identifier {
                switch identifier {
                case "show about":
                    avc.title = "About"
                default:
                    break
                }
            }
        }
    }

    // iOS 8 responding to UIVewController orientation
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        coordinator.animateAlongsideTransition({ (UIViewControllerTransitionCoordinatorContext) -> Void in
//            
//            let orient = UIApplication.sharedApplication().statusBarOrientation
//            
//            switch orient {
//            case .Portrait:
//                println("Portrait")
//                // Do something
//            default:
//                println("Anything But Portrait")
//                // Do something else
//            }
//            
//            }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
//                println("rotation completed")
//        })
//        
//        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
//    }
    
}