//
//  PasteboardLabel.swift
//  RPN Graph Calculator
//
//  Created by Thomas Hare on 7/4/15.
//  Copyright (c) 2015 Thomas Hare. All rights reserved.
//

import UIKit

class PasteboardLabel: UILabel {

    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    var _wasCut: Bool = false
    
    // this property enables the calling program to reset the user input mode
    var wasCut: Bool {
        get { return _wasCut }
        set { _wasCut = newValue }
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        var retValue = false
        if (action == "paste:") {
            // make sure the data on the pasteboard is compatible to paste
            return UIPasteboard.generalPasteboard().containsPasteboardTypes(UIPasteboardTypeListString as [AnyObject])
        } else if (action == "cut:" || action == "copy:") {
            // must have something to edit
            retValue = self.text != "0"
        } else {
            retValue = super.canPerformAction(action, withSender: sender)
        }
        return retValue
    }
    
    override func copy(sender: AnyObject?) {
        var generalPasteboard = UIPasteboard.generalPasteboard()
        generalPasteboard.string = self.text
        self.wasCut = false
    }
    
    override func paste(sender: AnyObject?) {
        var generalPasteboard = UIPasteboard.generalPasteboard()
        if var numTest = generalPasteboard.string!.toInt() {
            self.text = generalPasteboard.string
        }
        self.wasCut = false
    }
    
    override func cut(sender: AnyObject?) {
        var generalPasteboard = UIPasteboard.generalPasteboard()
        generalPasteboard.string = self.text
        self.text = "0"
        self.wasCut = true
    }
    
    // this happens after the longPressGestur requesting an edit
    override func becomeFirstResponder() -> Bool {
        // starts listening for UIMenuControllerDidHideMenuNotification & triggers resignFirstResponder if received
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resignFirstResponder", name: UIMenuControllerDidHideMenuNotification, object: nil)
        return super.becomeFirstResponder()
    }
    
    // resets the view after an edit menu item item has been clicked
    override func resignFirstResponder() -> Bool {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIMenuControllerDidHideMenuNotification, object: nil)
        // reset the view color
        UIView.animateWithDuration(0.5, animations: { self.alpha = 1; return })
        // relinquish user input
        return super.resignFirstResponder()
    }

}
