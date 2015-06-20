# FMMarkingMenu
## A Marking Menu Component for iOS

![/MarkingMenu/markingMenu.gif](/MarkingMenu/markingMenu.gif)

`FMMarkingMenu` is an implemtation of the marking menu UI pattern seen in applications such as [Autodesk's Maya](http://www.autodesk.co.uk/products/maya/overview) ported to iOS. Originally designed by [Gordon Kurtenbach](http://www.autodeskresearch.com/pdf/theses/kurtenbach-phd.pdf), marking menus allow users to navigate through and select from menu heirarchies using a single gesture which appears as a continous mark on the screen. 

In my version, the user simply has to tap anywhere on the screen and the marking menu appears in the centre. Dotted menu item arcs indicate crossing that item will open a further menu and solid, thicker menu item arcs indicate an executable menu item.

## Usage

Implementation is simple: create an instance of `MarkingMenu`:

```
var markingMenu: FMMarkingMenu!
```

...and, typically in `viewDidLoad()` give it a target view controller, view and set of menu items:

```
markingMenu = FMMarkingMenu(viewController: self, view: view, markingMenuItems: markingMenuItems)
```

To respond to menu selections, `FMMarkingMenu` requries a delegate that conforms to `FMMarkingMenuDelegate`. This protocol contains one method:

```
func FMMarkingMenuItemSelected(markingMenu: FMMarkingMenu, markingMenuItem: FMMarkingMenuItem)
```

## Creating Menus

`FMMarkingMenu` builds its menu from an array of `FMMarkingMenuItem` instances and each `FMMarkingMenuItem` can contain further `FMMarkingMenuItem` instances to build a heirarchy. In this example, a menu contains two top level items: _No Filter_ and _Blur & Sharpen_. The former has no sub items and will appear as a solid executable menu item, the latter has three sub items and will appear as a dotted menu item. When the user strokes across it they'll be presented with three further items, _CIGaussianBlur_, _CISharpenLuminance_ and _CIUnsharpMask_:

```
let blur = FMMarkingMenuItem(label: "Blur & Sharpen", subItems:[FMMarkingMenuItem(label: "CIGaussianBlur"), FMMarkingMenuItem(label: "CISharpenLuminance"), FMMarkingMenuItem(label: "CIUnsharpMask")])
        
let noFilter = FMMarkingMenuItem(label: "No Filter")
        
let markingMenuItems = [noFilter, blur]
        
markingMenu = FMMarkingMenu(viewController: self, view: view, markingMenuItems: markingMenuItems)
```

## Installation

`FMMarkingMenu` can be installed in any project by simply copying three files:

* [FMMarkingMenuContentViewController.swift](/MarkingMenu/FMMarkingMenuContentViewController.swift)
* [FMMarkingMenu.swift](/MarkingMenu/FMMarkingMenu.swift)
* [FMMarkingMenuSupportClasses.swift](/MarkingMenu/FMMarkingMenuSupportClasses.swift)
 
Because `FMMarkingMenu` uses a custom gesture recognizer, you'll also need to add the following to a bridging header:

```
#import <UIKit/UIGestureRecognizerSubclass.h>
```
