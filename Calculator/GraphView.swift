//
//  GraphView.swift
//  Calculator
//
//  Created by Thomas Hare on 6/1/15.
//  Copyright (c) 2015 Thomas Hare. All rights reserved.
//

import UIKit
import Foundation

protocol GraphViewDataSource: class {
    func y(x: CGFloat) -> CGFloat?
}

@IBDesignable
class GraphView: UIView {
    
    weak var dataSource: GraphViewDataSource?
    
    @IBInspectable
    var scale: CGFloat = 50 { didSet { setNeedsDisplay() } }
    var origin: CGPoint {
        get {
            var origin = originRelativeToCenter
            if geometryReady {
                origin.x += center.x
                origin.y += center.y
            }
            return origin
        }
        set {
            var origin = newValue
            if geometryReady {
                origin.x -= center.x
                origin.y -= center.y
            }
            originRelativeToCenter = origin
        }
    }

    var lineWidth: CGFloat = 3.0 { didSet { setNeedsDisplay() } }
    var color: UIColor = UIColor.redColor() { didSet { setNeedsDisplay() } }
    
    private var originRelativeToCenter: CGPoint = CGPoint() { didSet { setNeedsDisplay() } }
    private var geometryReady = false
    
    override func drawRect(rect: CGRect) {
        
        if !geometryReady && originRelativeToCenter != CGPointZero {
            var originHelper = origin
            geometryReady = true
            origin = originHelper
        }

//        self.clearsContextBeforeDrawing = false
        
        AxesDrawer(contentScaleFactor: contentScaleFactor).drawAxesInRect(bounds, origin: origin, pointsPerUnit: scale)
        color.set()
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        var firstValue = true
        var point = CGPoint()
        
        // project #3, hint #10
        for var i = 0; i <= Int(bounds.size.width * contentScaleFactor); i++ {
            point.x = CGFloat(i) / contentScaleFactor
            if let y = dataSource?.y((point.x - origin.x) / scale) {
                    if !y.isNormal && !y.isZero {
                    firstValue = true
                    continue
                }
                point.y = origin.y - y * scale
                if firstValue {
                    path.moveToPoint(point)
                    firstValue = false
                } else {
                    path.addLineToPoint(point)
                }
            } else {
                firstValue = true
            }
        }
        path.stroke()
    }
    
    // MARK: Gestures
    
    internal func zoom(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            scale *= gesture.scale
            gesture.scale = 1.0
        }
    }
    
    internal func move(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            let translation = gesture.translationInView(self)
            origin.x += translation.x
            origin.y += translation.y
            gesture.setTranslation(CGPointZero, inView: self)
        default: break
        }
    }
    
    internal func center(gesture: UITapGestureRecognizer) {
        if gesture.state == .Ended {
            origin = gesture.locationInView(self)
        }
    }
}