//
//  ViewController.swift
//  MarkingMenu
//
//  Created by Simon Gladman on 07/06/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    
    var markingMenu: FMMarkingMenu!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let markingMenuOrigin = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        
        markingMenu = FMMarkingMenu(viewController: self, view: view, origin: markingMenuOrigin)
    }
    
      
}

extension CGPoint
{
    func distance(otherPoint: CGPoint) -> Float
    {
        let xSquare = Float((self.x - otherPoint.x) * (self.x - otherPoint.x))
        let ySquare = Float((self.y - otherPoint.y) * (self.y - otherPoint.y))
        
        return sqrt(xSquare + ySquare)
    }
}

let π = CGFloat(M_PI)

public extension CGFloat
{
    public func degreesToRadians() -> CGFloat
    {
        return π * self / 180.0
    }
    
    public func radiansToDegrees() -> CGFloat
    {
        return self * 180.0 / π
}
}


