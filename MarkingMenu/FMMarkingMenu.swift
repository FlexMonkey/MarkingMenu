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
    let markingMenuContentViewController: FMMarkingMenuContentViewController
        
    let markingMenuItems:[FMMarkingMenuItem]
    
    let viewController: UIViewController
    let view: UIView
    
    var tap: FMMarkingMenuPanGestureRecognizer!
    var previousTouchLocation = CGPointZero
    
    init(viewController: UIViewController, view: UIView, markingMenuItems:[FMMarkingMenuItem])
    {
        self.markingMenuItems = markingMenuItems
     
        let markingMenuOrigin = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        markingMenuContentViewController = FMMarkingMenuContentViewController(origin: markingMenuOrigin)
        
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
            let markingMenuOrigin = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
            self.markingMenuContentViewController.origin = markingMenuOrigin
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
