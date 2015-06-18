//
//  FMMarkingMenuSupportClasses.swift
//  MarkingMenu
//
//  Created by Simon Gladman on 18/06/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

struct FMMarkingMenuItem
{
    let label: String
    let subItems: [FMMarkingMenuItem]?
    
    init(label: String, subItems: [FMMarkingMenuItem]? = nil)
    {
        self.label = label
        self.subItems = subItems
    }
}
