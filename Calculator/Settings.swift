//
//  Settings.swift
//  Calculator
//
//  Created by Thomas Hare on 6/26/15.
//  Copyright (c) 2015 Thomas Hare. All rights reserved.
//

import Foundation

class Settings {
    
    private struct Keys {
        static let ButtonEffect = "CalculatorViewController.ButtonEffect"
        static let DPrecision = "CalculatorViewController.DPrecision"
        static let HPrecision = "CalculatorViewController.HPrecision"
        static let KeyAlert = "CalculatorViewController.KeyAlert"
    }
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    var buttonEffect: Bool {
        get {
            return defaults.objectForKey(Keys.ButtonEffect) as? Bool ?? false
        }
        set {
            defaults.setObject(newValue, forKey: Keys.ButtonEffect)
        }
    }
    var displayPrecision: Double {
        get {
            return defaults.objectForKey(Keys.DPrecision) as? Double ?? 8
        }
        set {
            defaults.setObject(newValue, forKey: Keys.DPrecision)
        }
    }
    var historyPrecision: Double {
        get {
            return defaults.objectForKey(Keys.HPrecision) as? Double ?? 2
        }
        set {
            defaults.setObject(newValue, forKey: Keys.HPrecision)
        }
    }
    
    var keyAlert: Bool {
        get {
            return defaults.objectForKey(Keys.KeyAlert) as? Bool ?? true
        }
        set { defaults.setObject(newValue, forKey: Keys.KeyAlert) }
    }
    
}