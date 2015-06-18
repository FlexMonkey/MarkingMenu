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
    
    let blur = FMMarkingMenuItem(label: "Blur", subItems:[FMMarkingMenuItem(label: "Gaussian"), FMMarkingMenuItem(label: "Box")])
    let styleize = FMMarkingMenuItem(label: "Stylize", subItems:[FMMarkingMenuItem(label: "Posterize"), FMMarkingMenuItem(label: "Pixellate")])
    let noFilter = FMMarkingMenuItem(label: "No Filter")
    
    let viewController: UIViewController
    let view: UIView
    let origin: CGPoint
    
    var tap: FMMarkingMenuPanGestureRecognizer!
    var previousTouchLocation = CGPointZero
    
    
    init(viewController: UIViewController, view: UIView, origin: CGPoint)
    {
        self.origin = origin
        
        let markingMenuItems = [blur, styleize, noFilter]
        markingMenuContentViewController = FMMarkingMenuContentViewController(markingMenuItems: markingMenuItems, origin: origin)
        
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
            self.markingMenuContentViewController.openMarkingMenu(locationInView)
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
