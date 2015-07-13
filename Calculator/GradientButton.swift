//
//  CoolButton.swift
//  gradient
//
//  Created by Thomas Hare on 7/10/15.
//  Copyright (c) 2015 Thomas Hare. All rights reserved.
//

import UIKit

@IBDesignable
class GradientButton: UIButton {
    
    // MARK: - internal variables
    
    private var _hue:CGFloat = 0.5
    private var _saturation:CGFloat = 0.7
    private var _brightness:CGFloat = 0.8
    private var _alpha:CGFloat = 1
    private var _contextColor:UIColor = UIColor.clearColor()

    private var _highlightStartColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.4)
    private var _highlightStopColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1)
    private var _borderColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    private var _shadowColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5)
    
    private var _outerMargin:CGFloat = 5.0
    private var _innerMargin:CGFloat = 3.0
    private var _highlightMargin:CGFloat = 2.0
    
    private var _borderSize:CGFloat = 2.0
    
    private var _border:Bool = true
    private var _bevel:Bool = true
    
    // MARK: - main graphics routine
    
    override func drawRect(rect: CGRect)
    {
        opaque = false;
        backgroundColor = UIColor.clearColor()
        var actualBrightness = _brightness
        // decrease the brightness when highlighted
        if state == UIControlState.Highlighted {
            actualBrightness -= 0.10
        }
        
        // set the graphics context
        let context = UIGraphicsGetCurrentContext()
    
        // set default values for colors, sizes, and paths
        let outerTopColor = UIColor(hue: _hue, saturation: _saturation, brightness: 1.0*actualBrightness, alpha: 1.0).CGColor
        let outerBottomColor = UIColor(hue: _hue, saturation: _saturation, brightness: 0.80*actualBrightness, alpha: 1.0).CGColor
        let innerStroke = UIColor(hue: _hue, saturation: _saturation, brightness: 0.80*actualBrightness, alpha: 1.0).CGColor
        let innerTop = UIColor(hue: _hue, saturation: _saturation, brightness: 0.90*actualBrightness, alpha: 1.0).CGColor
        let innerBottom = UIColor(hue: _hue, saturation: _saturation, brightness: 0.70*actualBrightness, alpha: 1.0).CGColor
    
        let outerRect = CGRectInset(self.bounds, _outerMargin, _outerMargin)
        let outerPath = createRoundedRectForRect(outerRect, 6.0)
    
        let innerRect = CGRectInset(outerRect, _innerMargin, _innerMargin)
        let innerPath = createRoundedRectForRect(innerRect, 6.0)
    
        let highlightRect = CGRectInset(outerRect, _highlightMargin, _highlightMargin)
        let highlightPath = createRoundedRectForRect(highlightRect, 6.0)
    
        // draw un-highlighted base color and drop shadow
        if (state != UIControlState.Highlighted) {
            // save the current context parameters
            CGContextSaveGState(context)
            // set the fill color
            CGContextSetFillColorWithColor(context, outerTopColor)
            // draw the drop shadow
            CGContextSetShadowWithColor(context, CGSizeMake(2, 2), 3.0, _shadowColor.CGColor)
            // fill the object with color
            CGContextAddPath(context, outerPath)
            CGContextFillPath(context)
            // restore the graphics context
            CGContextRestoreGState(context)
        }

        // save the context state
        CGContextSaveGState(context)
        // set the path
        CGContextAddPath(context, outerPath)
        // clip the path
        CGContextClip(context)
        // draw the gloss gradiant
        drawGlossAndGradient(context, outerRect, outerTopColor, outerBottomColor)
        // restore the context parameters
        CGContextRestoreGState(context)

        if (_bevel) {
            // put a gloss gradiant where the inner bevel will be
            CGContextSaveGState(context)
            CGContextAddPath(context, innerPath)
            CGContextClip(context)
            drawGlossAndGradient(context, innerRect, innerTop, innerBottom)
            CGContextRestoreGState(context)
            
            // draw the outer bevel
            if (state != UIControlState.Highlighted) {
                CGContextSaveGState(context)
                CGContextSetLineWidth(context, 4.0)
                CGContextAddPath(context, outerPath)
                CGContextAddPath(context, highlightPath)
                CGContextEOClip(context)
                drawLinearGradient(context, outerRect, _highlightStartColor.CGColor, _highlightStopColor.CGColor)
                CGContextRestoreGState(context)
            }
        }

        // draw a border
        if (_border) {
            CGContextSaveGState(context)
            CGContextSetLineWidth(context, _borderSize)
            CGContextSetStrokeColorWithColor(context, _borderColor.CGColor)
            CGContextAddPath(context, outerPath)
            CGContextStrokePath(context)
            CGContextRestoreGState(context)
        }
        
        if (_bevel) {
            // draw highlight line for outer bevel
            CGContextSaveGState(context)
            CGContextSetLineWidth(context, 2.0)
            CGContextSetStrokeColorWithColor(context, innerStroke)
            CGContextAddPath(context, innerPath)
            CGContextClip(context)
            CGContextAddPath(context, innerPath)
            CGContextStrokePath(context)
            CGContextRestoreGState(context)
        }
    
    }
    
    // MARK: - @IBInspectable properties
    
    @IBInspectable
    var contextColor: UIColor {
        get { return _contextColor }
        set {
            _contextColor = newValue
            _contextColor.getHue(&_hue, saturation: &_saturation, brightness: &_brightness, alpha: &_alpha)
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var hue: CGFloat {
        get { return _hue }
        set {
            _hue = newValue
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var saturation : CGFloat {
        get { return _saturation }
        set {
            _brightness = newValue
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var brightness : CGFloat {
        get { return _brightness }
        set {
            _brightness = newValue
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var border: Bool {
        get { return _border }
        set {
            _border = newValue
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var borderSize : CGFloat {
        get { return _borderSize }
        set {
            _borderSize = newValue
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var borderColor : UIColor {
        get { return _borderColor }
        set {
            _borderColor = newValue
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var shadowColor : UIColor {
        get { return _shadowColor }
        set {
            _shadowColor = newValue
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var highlightStartColor : UIColor {
        get { return _highlightStartColor }
        set {
            _highlightStartColor = newValue
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var highlightStopColor : UIColor {
        get { return _highlightStopColor }
        set {
            _highlightStopColor = newValue
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var highlightMargin : CGFloat {
        get { return _highlightMargin }
        set {
            _highlightMargin = newValue
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var bevel: Bool {
        get { return _bevel }
        set {
            _bevel = newValue
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var outerMargin : CGFloat {
        get { return _outerMargin }
        set {
            _outerMargin = newValue
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var innerMargin : CGFloat {
        get { return _innerMargin }
        set {
            _innerMargin = newValue
            self.setNeedsDisplay()
        }
    }
    
    // MARK: - touch events
    
    func hesitateUpdate() { self.setNeedsDisplay() }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches , withEvent:event)
        if let touch = touches.first as? UITouch {
            self.setNeedsDisplay()
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesMoved(touches , withEvent:event)
        if let touch = touches.first as? UITouch {
            self.setNeedsDisplay()
        }
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        super.touchesCancelled(touches , withEvent:event)
        if let touch = touches.first as? UITouch {
            self.setNeedsDisplay()
            delay(0.1) { hesitateUpdate }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches , withEvent:event)
        if let touch = touches.first as? UITouch {
            self.setNeedsDisplay()
            delay(0.1) { hesitateUpdate }
        }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue(),
            closure)
    }
}
