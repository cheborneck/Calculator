//
//  GraphViewController.swift
//  Calculator
//
//  Created by Thomas Hare on 6/1/15.
//  Copyright (c) 2015 Thomas Hare. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource, UIPopoverPresentationControllerDelegate
{

    var brain: CalculatorBrain?
    var graphTitle: String? {
        didSet{
            self.title = graphTitle
        }
    }
    
    // the original memory value. gets changed when graphed.
    var lastValue: Double?
    
    @IBOutlet weak var statsButton: UIButton!
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            // project #3, hint #9
            graphView.dataSource = self
            
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "zoom:"))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "move:"))
            var tap = UITapGestureRecognizer(target: self, action: "center:")
            tap.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(tap)
            
            resetStatistics()

            if !resetOrigin {
                graphView.origin = origin
            }
            graphView.scale = scale

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // display the navigation bar for the graph view
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        statsButton.enabled = lastValue != nil
    }
    
    private struct Keys {
        static let Scale = "GraphViewController.Scale"
        static let Origin = "GraphViewController.Origin"
        static let SegueIdentifier = "show stats"
    }
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    private var resetOrigin: Bool {
        get {
            if let originArray = defaults.objectForKey(Keys.Origin) as? [CGFloat] {
                return false
            }
            return true
        }
    }
    
    var scale: CGFloat {
        get { return defaults.objectForKey(Keys.Scale) as? CGFloat ?? 50.0 }
        set { defaults.setObject(newValue, forKey: Keys.Scale) }
    }
    
    private var origin: CGPoint {
        get {
            var origin = CGPoint()
            if let originArray = defaults.objectForKey(Keys.Origin) as? [CGFloat] {
                origin.x = originArray.first!
                origin.y = originArray.last!
            }
            return origin
        }
        set {
            defaults.setObject([newValue.x, newValue.y], forKey: Keys.Origin)
        }
    }
    
    func zoom(gesture: UIPinchGestureRecognizer) {
        graphView.zoom(gesture)
        if gesture.state == .Ended {
            resetStatistics()
            scale = graphView.scale
            origin = graphView.origin
        }
    }
    
    func move(gesture: UIPanGestureRecognizer) {
        graphView.move(gesture)
        if gesture.state == .Ended {
            resetStatistics()
            origin = graphView.origin
        }
    }
    
    func center(gesture: UITapGestureRecognizer) {
        graphView.center(gesture)
        if gesture.state == .Ended {
            resetStatistics()
            origin = graphView.origin
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        // set the original value passed to the graph
        brain?.variableValues["m"] = lastValue
    }
    
    internal func y(x: CGFloat) -> CGFloat? {
        brain?.variableValues["m"] = Double(x)
        if let y = brain?.evaluate() {
            if let minValue = statistics["min"] {
                statistics["min"] = min(minValue, y)
            } else {
                statistics["min"] = y
            }
            if let maxValue = statistics["max"] {
                statistics["max"] = max(maxValue, y)
            } else {
                statistics["max"] = y
            }
            if let avgValue = statistics["avg"] {
                statistics["avg"] = avgValue + y
                if let avgNum = statistics["avgNum"] {
                    statistics["avgNum"] = avgNum + 1
                }
            } else {
                statistics["avg"] = y
                statistics["avgNum"] = 1
            }
            return CGFloat(y)
        }
        return nil
    }
    
    private var statistics = [String: Double]()
    
    private func resetStatistics() {
        statistics["min"] = nil
        statistics["max"] = nil
        statistics["avg"] = nil
    }
    
    private func finishStatistics() {
        if let num = statistics["avgNum"] {
            if let avgValue = statistics["avg"] {
                statistics["avg"] = avgValue / num
                statistics["avgNum"] = nil
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifer = segue.identifier {
            switch identifer {
            case Keys.SegueIdentifier:
                if let tvc = segue.destinationViewController as? StatsViewController {
                    if let ppc = tvc.popoverPresentationController {
                        ppc.delegate = self
                    }
                    finishStatistics()
                    var texts = [String]()
                    for (key, value) in statistics {
                        texts += ["\(key) = \(value)"]
                    }
                    tvc.text = texts.count > 0 ? "\n".join(texts) : "none"
                }
            default: break
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }

}
