//
//  ViewController.swift
//  Calculator
//
//  Created by Thomas Hare on 5/15/15.
//  Copyright (c) 2015 RaBit Software. All rights reserved.
//

import UIKit
import AVFoundation

class CalculatorViewController: UIViewController, SettingsTableViewControllerDelegate {
    
    @IBOutlet weak var display: PasteboardLabel!
    
    @IBOutlet weak var history: UILabel!
    
    @IBOutlet weak var decimalButton: UIButton!
    
    var userIsInTheMiddleOfTypingANumber: Bool = false
    
    let decimalSeparator = NSNumberFormatter().decimalSeparator!
    
    private var brain = CalculatorBrain()
    
    private var settings = Settings()
    
    let displayNumberFormatter = NSNumberFormatter(), historyNumberFormatter = NSNumberFormatter()
    
    let systemSoundID: SystemSoundID = 1104
    
    // generic method if you have to do something for every button
    @IBAction func buttonTouched(sender: UIButton) {
        // play a sound
        if settings.keyAlert { AudioServicesPlaySystemSound(systemSoundID) }
    }
    
    /*
    Used for copy/paste operations
    */
    @IBAction func longPressGestureRecognizer(sender: UILongPressGestureRecognizer)
    {
        if sender.state == UIGestureRecognizerState.Began {
            // make the display view the FirstResponder
            sender.view?.becomeFirstResponder()
            // get the global menu-controller instance
            var menuController = UIMenuController.sharedMenuController()
            // get the location of the touch
            let touchPoint = sender.locationInView(sender.view)
            // and offset it a bit
            let touchSize = CGSize(width: 100, height: 100)
            let selectionRect = CGRect(origin: CGPoint(x: touchPoint.x-100, y: touchPoint.y), size: touchSize)
            // set the target location to display the menu
            menuController.setTargetRect(selectionRect, inView: sender.view!.superview!)
            // display the menu
            menuController.setMenuVisible(true, animated: true)
            if menuController.menuVisible == true {
                // if there's a menu then dim the view
                UIView.animateWithDuration(0.5, animations: { self.display.alpha = 0.75; return })
            }
        }
    }
    
    // this is used just when a tap is placed on the label to dismiss the edit menu.
    @IBAction func tapGestureRecognizer(sender: UITapGestureRecognizer)
    {
        // lose the menu
        UIMenuController.sharedMenuController().setMenuVisible(false, animated: true)
        // reset the view color
        UIView.animateWithDuration(0.5, animations: { self.display.alpha = 1; return })
        // reset input status after edit (because a cut resets number to zero ending input)
        userIsInTheMiddleOfTypingANumber = display.wasCut
    }
    
    /**
    initialize on startup
    */
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // internationalize the decimal (.) button
        decimalButton.setTitle(decimalSeparator, forState: UIControlState.Normal)
        // set the numeric display format
        displayNumberFormatter.numberStyle = .DecimalStyle
        displayNumberFormatter.usesGroupingSeparator = false
        displayNumberFormatter.maximumFractionDigits = Int(settings.displayPrecision)
        // adjust font size to fit on the display
        display.adjustsFontSizeToFitWidth = true
        // load some user defaults
        brain.displayPrecision = Int(settings.historyPrecision)
        
        // set up the label for copy/paste
        display.userInteractionEnabled = true
    }
    
    override func viewWillLayoutSubviews() {
        // make sure the status bar is still visible (iOS 8 started shutting it off in landscape mode)
        UIApplication.sharedApplication().statusBarHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        // this is where the 3D effect is updated
        set3DLayout(settings.buttonEffect)
    }
    
    private func set3DLayout(effect: Bool) {
        // spice up the buttons a little bit
        for view in self.view.subviews as! [UIView] {
            if let btn = view as? UIButton {
                if btn.buttonType != UIButtonType.InfoLight { // don't bother with the settings button
                    if let layer = btn.layer as CALayer? {
                        btn.layer.borderColor = UIColor.blackColor().CGColor
                        btn.layer.borderWidth = 1
                        btn.layer.cornerRadius = 5
                        btn.layer.masksToBounds = false
                        if effect {
                            // turn on the 3D effect
                            btn.layer.shadowColor = UIColor.blackColor().CGColor
                            btn.layer.shadowOffset = CGSizeMake(2, 2)
                            btn.layer.shadowRadius = 5
                            btn.layer.shadowOpacity = 0.5
                            // this didn't work right
//                            btn.layer.shadowPath = UIBezierPath(roundedRect: btn.bounds, cornerRadius: btn.layer.cornerRadius).CGPath
                        } else {
                            // turn off the effect
                            btn.layer.shadowOffset = CGSizeMake(0, 0)
                            btn.layer.shadowRadius = 0
                            btn.layer.shadowOpacity = 0
                        }
                        // resterizing each button preserves it's visual state so it's less cpu intensive
                        btn.layer.shouldRasterize = true
                        btn.layer.rasterizationScale = UIScreen.mainScreen().scale
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // make sure the navigation bar is turned off in the master controller view
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    /**
    A number digit is being clicked
    */
    @IBAction func appendDigit(sender: UIButton)
    {
        if let digit = sender.currentTitle {
            if userIsInTheMiddleOfTypingANumber {
                // don't allow decimal point to be entered more than once
                if (digit == decimalSeparator) && (display.text!.rangeOfString(decimalSeparator) != nil) { return }
                // append the digit to an entry in progress
                display.text! += digit
            } else {
                // don't allow leading zero entry
                if (digit == "0") && (displayValue == 0) { return }
                // we're here at the beginning of a new number
                if (digit == decimalSeparator) {
                    // put a zero in front of a decimal point entry
                    display.text = "0" + decimalSeparator
                } else {
                    // initial digit entry
                    display.text = digit
                }
                userIsInTheMiddleOfTypingANumber = true
            }
        }
    }
    
    /**
    backspace removes the last entered digit
    */
    @IBAction func backSpace()
    {
        if userIsInTheMiddleOfTypingANumber {
            let displayText = display.text!
            if count(displayText) > 1 {
                display.text = dropLast(displayText)
                if display.text == "-" {
                    display.text = "0"
                    userIsInTheMiddleOfTypingANumber = false
                }
            } else {
                display.text = "0"
                userIsInTheMiddleOfTypingANumber = false
            }
        }
    }
    
    // save the entered value into the variable
    @IBAction func storeVariable(sender: UIButton)
    {
        // project #2, hint #10 done in 3 lines of code
        // save the displayed value to the variable (from the button title)
        if let value = displayValue {
            brain.variableValues["\(last(sender.currentTitle!)!)"] = value
            displayValue = brain.evaluate()
            userIsInTheMiddleOfTypingANumber = false
        } else { blinkDisplay() }
    }
    
    // Recall variable function - push the variable onto the stack
    @IBAction func pushVariable(sender: UIButton)
    {
        // project #2, hint #10 done in under 2 to 3 lines of code
        // get the saved variable and put it on the stack and display it if it exists
        displayValue = brain.pushOperand(String(first(sender.currentTitle!)!))
    }
    
    /**
    clear the last operation from the stack
    */
    @IBAction func clearEntry(sender: AnyObject)
    {
        displayValue = brain.popOperand()
    }
    
    /**
    clear everything out
    */
    @IBAction func clearAll()
    {
        // clear the calculators stack (brain)
        brain.clearOperationStack()
        // hitting clear all a second time clears the variables array
        if display.text! == "0" { brain.clearVariables() }
        // clear the display (cheap way of getting rid of any error message)
        displayValue = 0
        // reset input mode
        userIsInTheMiddleOfTypingANumber = false
    }
    
    /**
    A math function button was pressed
    */
    @IBAction func operate(sender: UIButton)
    {
        if let digit = sender.currentTitle {
            if userIsInTheMiddleOfTypingANumber {
                if (digit == "±") { // we're changing the number sign in the middle of entry
                    display.text = brain.changeSign(display.text!)
                    return
                }
                // an operator was typed while in the middle of entering a number so push the displayed value on the stack
                enter()
            }
            // display the result of the operation
            displayValue = brain.performOperation(digit)
        }
    }
    
    /**
    The enter button was pressed
    */
    @IBAction func enter()
    {
        // push the displayed value onto the stack
        displayValue = brain.pushOperand(displayValue!)
        userIsInTheMiddleOfTypingANumber = false
    }
    
    /**
    Gets or sets the value in the calculator display
    */
    var displayValue: Double? {
        get{
            // convert the string value in the UILabel and returns as a Double
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set{
            // set up the number formatter
            if (newValue != nil) {
                display.text = displayNumberFormatter.stringFromNumber(newValue!)
            } else {
                if let result = brain.evaluateAndReportErrors() as? String {
                    // display the error message
                    display.text = result
                    // provide a visual cue of the error
                    blinkDisplay()
                } else {
                    display.text = "0"
                }
            }
            userIsInTheMiddleOfTypingANumber = false
            history.text = brain.description != "" ? brain.description + " =" : " "
        }
    }
    
    /**
    Animate (blink) display area
    */
    func blinkDisplay()
    {
        UIView.animateWithDuration(0.1,
            animations: {
                self.display.alpha = 0.5
                self.history.alpha = 0.5
            }, completion: {(finished: Bool) -> Void in
                // Fade back
                UIView.animateWithDuration(0.1,
                    animations: {
                        self.display.alpha = 1.0
                        self.history.alpha = 1.0
                    }, completion: nil)
        })
    }
  
    /*
    get the data back from the settings screen
    */
    func myVCDidFinish(settings: Settings) {
        // reset some UI elements
        displayNumberFormatter.maximumFractionDigits = Int(settings.displayPrecision)
        brain.displayPrecision = Int(settings.historyPrecision)
        // reset the display
        displayValue = brain.evaluate()
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        set3DLayout(settings.buttonEffect)
    }
    
    /*
    Segue for the graph view controller
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as? UIViewController
        if let nc = destination as? UINavigationController {
            destination = nc.visibleViewController
        }
        
        if let gvc = destination as? GraphViewController {
            if let identifier = segue.identifier {
                // save the last value on the stack
                gvc.lastValue = brain.variableValues["x"]
                // pass the brain
                gvc.brain = self.brain
                switch identifier {
                    case "show graph":
                        // display the last expression description in the title
                        // project #3, hint #17
                        gvc.title = brain.description == "" ? "y=0" : "y=" + brain.description.componentsSeparatedByString(", ").last!
                    default:
                        break
                }
            }
        }
        // prepare the settings view controller
        if let svc = destination as? SettingsTableViewController {
            if let identifier = segue.identifier {
                // pass the data object
                svc.settings = self.settings
                svc.delegate = self
            }
        }
    }
    
}