//
//  Common.swift
//  utility routines to assist drawing gradients
//
//  Created by Thomas Hare on 7/10/15.
//  Copyright (c) 2015 Thomas Hare. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit
import GLKit

/// Obj-C style NULL object
let NULLup: UnsafePointer<CGAffineTransform> = nil

/**
Draws a linear gradient on the specified graphics context at the coordinates and size using a given set of colors

:param: context A graphics context.
:param: rect A rectangle, specified in user space coordinates.
:param: startColor The color used for the start of the gradient.
:param: endColor The color used for the end of the gradient
*/
func drawLinearGradient(context: CGContextRef, rect: CGRect, startColor: CGColorRef, endColor: CGColorRef)
{
    // create a color space object and location reference
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let locations:[CGFloat] = [ 0.0, 1.0 ]
    
    // create an array of the colors used in the gradient
    let colors:[CGColorRef] = [ startColor, endColor ]

    // create the gradient object
    let gradient = CGGradientCreateWithColors(colorSpace, colors, locations)
    
    // set the direction of the gradient
    let startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect))
    let endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect))
    
    // save the current graphics state parameters
    CGContextSaveGState(context)
    // perform the graphics operations
    CGContextAddRect(context, rect)// add the rectangle to the context
    CGContextClip(context)// clip the rectangle
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, CGGradientDrawingOptions())// draw gradient
    // restore the last context parameters
    CGContextRestoreGState(context)
}

func draw1PxStroke(context: CGContextRef, startPoint: CGPoint, endPoint: CGPoint, color: CGColorRef)
{
    // save the state parameters
    CGContextSaveGState(context)
    // change some parameters
    CGContextSetLineCap(context, kCGLineCapSquare)
    CGContextSetStrokeColorWithColor(context, color)
    CGContextSetLineWidth(context, 1.0)
    // draw a line using the current context parameters
    CGContextMoveToPoint(context, startPoint.x + 0.5, startPoint.y + 0.5)
    CGContextAddLineToPoint(context, endPoint.x + 0.5, endPoint.y + 0.5)
    CGContextStrokePath(context)
    // restore the previous context parameters
    CGContextRestoreGState(context)
}

func rectFor1PxStroke(rect: CGRect) -> CGRect
{
    return CGRectMake(rect.origin.x + 0.5, rect.origin.y + 0.5, rect.size.width - 1, rect.size.height - 1)
}

/**
Draws a linear gradient gloss on top of the specified graphics context at the coordinates and size using a given set of colors. This routine redraws the original gradient first then places the white gloss gradient on top.

:param: context A graphics context.
:param: rect A rectangle, specified in user space coordinates.
:param: startColor The color used for the start of the gradient.
:param: endColor The color used for the end of the gradient
*/
func drawGlossAndGradient(context: CGContextRef, rect: CGRect, startColor: CGColorRef, endColor: CGColorRef)
{
    // draw the base color gradient (may be redundent)
    drawLinearGradient(context, rect, startColor, endColor)
    
    // create the gloss color objects
    let glossColor1 = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.35)
    let glossColor2 = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1)
    
    // define the top half of the object to be glossed
    let topHalf = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height/2)
   
    // draw the white gloss gradient over top
    drawLinearGradient(context, topHalf, glossColor1.CGColor, glossColor2.CGColor)
}

func createArcPathFromBottomOfRect(rect: CGRect, arcHeight: CGFloat) -> CGMutablePathRef
{
    let arcRect = CGRectMake(rect.origin.x, rect.origin.y + rect.size.height - arcHeight, rect.size.width, arcHeight)
    
    let arcRadius = (arcRect.size.height/2) + (pow(arcRect.size.width, 2) / (8*arcRect.size.height))
    let arcCenter = CGPointMake(arcRect.origin.x + arcRect.size.width/2, arcRect.origin.y + arcRadius)
    
    let angle = acos(arcRect.size.width / (2*arcRadius))
    let startAngle = CGFloat(GLKMathDegreesToRadians(180)) + angle
    let endAngle = CGFloat(GLKMathDegreesToRadians(360)) - angle
    
    let path = CGPathCreateMutable()
    CGPathAddArc(path, NULLup, arcCenter.x, arcCenter.y, arcRadius, startAngle, endAngle, false)
    CGPathAddLineToPoint(path, NULLup, CGRectGetMaxX(rect), CGRectGetMidY(rect))
    CGPathAddLineToPoint(path, NULLup, CGRectGetMinX(rect), CGRectGetMinY(rect))
    CGPathAddLineToPoint(path, NULLup, CGRectGetMinX(rect), CGRectGetMaxY(rect))

    return path
}

func createRoundedRectForRect(rect: CGRect, radius: CGFloat) -> CGMutablePathRef
{
    let path = CGPathCreateMutable()
    CGPathMoveToPoint(path, NULLup, CGRectGetMidX(rect), CGRectGetMinY(rect))
    CGPathAddArcToPoint(path, NULLup, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMaxY(rect), radius)
    CGPathAddArcToPoint(path, NULLup, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMaxY(rect), radius)
    CGPathAddArcToPoint(path, NULLup, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMinY(rect), radius)
    CGPathAddArcToPoint(path, NULLup, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMinY(rect), radius)
    CGPathCloseSubpath(path)
    
    return path
}