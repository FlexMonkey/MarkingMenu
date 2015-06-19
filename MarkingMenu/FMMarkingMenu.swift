//
//  FMMarkingMenu.swift
//  MarkingMenu
//
//  Created by Simon Gladman on 18/06/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import UIKit

class FMMarkingMenu: NSObject
{
    let markingMenuContentViewController: FMMarkingMenuContentViewController // = FMMarkingMenuContentViewController(markingMenuItems: [" Blur ", " Sharpen " , " Stylize ", " Color Effect ", " Color Adjustment "  , " Halftone Effect " , " Distortion Effect "])
    
    let blur = FMMarkingMenuItem(label: "Blur & Sharpen", subItems:[FMMarkingMenuItem(label: "Gaussian Blur"), FMMarkingMenuItem(label: "Sharpen Luminance"), FMMarkingMenuItem(label: "Unsharp Mask")])

    let noFilter = FMMarkingMenuItem(label: "No Filter")
    let colorAdjust = FMMarkingMenuItem(label: "Color Adjust", subItems:[FMMarkingMenuItem(label: "Exposure"), FMMarkingMenuItem(label: "Gamma"), FMMarkingMenuItem(label: "Hue"), FMMarkingMenuItem(label: "Temperature & Tint"), FMMarkingMenuItem(label: "Vibrance")])
    let colorEffect = FMMarkingMenuItem(label: "Color Effect", subItems:[FMMarkingMenuItem(label: "Invert"), FMMarkingMenuItem(label: "Monochrome"), FMMarkingMenuItem(label: "Posterize"), FMMarkingMenuItem(label: "False Color"), FMMarkingMenuItem(label: "Sepia")])
    let photoEffect = FMMarkingMenuItem(label: "Color Effect", subItems:[FMMarkingMenuItem(label: "Chrome"), FMMarkingMenuItem(label: "Fade"), FMMarkingMenuItem(label: "Instant"), FMMarkingMenuItem(label: "Noir"), FMMarkingMenuItem(label: "Tonal"), FMMarkingMenuItem(label: "Transfer")])
    let halftone = FMMarkingMenuItem(label: "Color Adjust", subItems:[FMMarkingMenuItem(label: "Circular Screen"), FMMarkingMenuItem(label: "Dot Screen"), FMMarkingMenuItem(label: "Hatched Screen"), FMMarkingMenuItem(label: "Line Screen")])
    let styleize = FMMarkingMenuItem(label: "Stylize", subItems:[FMMarkingMenuItem(label: "Bloom"), FMMarkingMenuItem(label: "Gloom"), FMMarkingMenuItem(label: "Pixellate")])
    
    let markingMenuItems:[FMMarkingMenuItem]
    
    let viewController: UIViewController
    let view: UIView
    let origin: CGPoint
    
    var tap: FMMarkingMenuPanGestureRecognizer!
    var previousTouchLocation = CGPointZero
    
    
    init(viewController: UIViewController, view: UIView, origin: CGPoint)
    {
        self.origin = origin
        
        markingMenuItems = [blur, colorAdjust, colorEffect, photoEffect, halftone, styleize, noFilter]
        markingMenuContentViewController = FMMarkingMenuContentViewController(origin: origin)
        
        self.viewController = viewController
        self.view = view
        self.view.userInteractionEnabled = true
        
        super.init();
        
        tap = FMMarkingMenuPanGestureRecognizer(target: self, action: "tapHandler:")
        view.addGestureRecognizer(tap)
    }
    
    func tapHandler(recognizer: FMMarkingMenuPanGestureRecognizer)
    {
        if recognizer.state == UIGestureRecognizerState.Began
        {
            open(recognizer.locationInView(view))
        }
        else if recognizer.state == UIGestureRecognizerState.Changed
        {
            markingMenuContentViewController.handleMovement(recognizer.locationInView(view))
        }
        else
        {
            markingMenuContentViewController.closeMarkingMenu()
            viewController.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    private func open(locationInView: CGPoint)
    {
        markingMenuContentViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        markingMenuContentViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        markingMenuContentViewController.view.frame = view.bounds
        
        viewController.presentViewController(markingMenuContentViewController, animated: false)
        {
            self.markingMenuContentViewController.origin = self.origin
            self.markingMenuContentViewController.openMarkingMenu(locationInView, markingMenuItems: self.markingMenuItems)
        }
    }
}

/// An extended UIPanGestureRecognizer that fires UIGestureRecognizerState.Began
/// with the first touch down, i.e. without requiring any movement.
class FMMarkingMenuPanGestureRecognizer: UIPanGestureRecognizer
{
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent!)
    {
        super.touchesBegan(touches, withEvent: event)
        
        state = UIGestureRecognizerState.Began
    }
}
