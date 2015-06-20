//
//  ViewController.swift
//  MarkingMenu
//
//  Created by Simon Gladman on 07/06/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FMMarkingMenuDelegate
{
    let photo = UIImage(named: "photo.jpg")!
    let imageView = UIImageView()
    var markingMenu: FMMarkingMenu!
    
    let ciContext = CIContext(options: nil)
    let ciContextFast = CIContext(EAGLContext: EAGLContext(API: EAGLRenderingAPI.OpenGLES2), options: [kCIContextWorkingColorSpace: NSNull()])
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        createMarkingMenu()
        
        imageView.frame = view.bounds
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.image = photo

        view.addSubview(imageView)
    }
    
    func FMMarkingMenuItemSelected(markingMenu: FMMarkingMenu, markingMenuItem: FMMarkingMenuItem)
    {
        let filters = (CIFilter.filterNamesInCategories(nil) ?? [AnyObject]()).filter({ $0 as! String ==  markingMenuItem.label})
        
        if filters.count != 0
        {
            imageView.image = applyFilter(photo, filterName: markingMenuItem.label)
        }
        else
        {
            imageView.image = photo
        }
    }
    
    func applyFilter(image: UIImage, filterName: String) -> UIImage
    {
        let ciFilter = CIFilter(name: filterName)
        
        ciFilter.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        
        let filteredImageData = ciFilter.valueForKey(kCIOutputImageKey) as! CIImage!
        let filteredImageRef = ciContext.createCGImage(filteredImageData, fromRect: filteredImageData.extent())
        
        var filteredImage = UIImage(CGImage: filteredImageRef)!
        
        return filteredImage
    }
    
    func createMarkingMenu()
    {
        let blur = FMMarkingMenuItem(label: "Blur & Sharpen", subItems:[FMMarkingMenuItem(label: "CIGaussianBlur"), FMMarkingMenuItem(label: "CISharpenLuminance"), FMMarkingMenuItem(label: "CIUnsharpMask")])
        
        let noFilter = FMMarkingMenuItem(label: "No Filter")
        
        let distort = FMMarkingMenuItem(label: "Distort", subItems:[FMMarkingMenuItem(label: "CIPinchDistortion"), FMMarkingMenuItem(label: "CITwirlDistortion"), FMMarkingMenuItem(label: "CIVortexDistortion")])
        
        let colorEffect = FMMarkingMenuItem(label: "Color Effect", subItems:[FMMarkingMenuItem(label: "CIColorInvert"), FMMarkingMenuItem(label: "CIColorMonochrome"), FMMarkingMenuItem(label: "CIColorPosterize"), FMMarkingMenuItem(label: "CIFalseColor"), FMMarkingMenuItem(label: "CISepiaTone")])
        
        let photoEffect = FMMarkingMenuItem(label: "Photo Effect", subItems:[FMMarkingMenuItem(label: "CIPhotoEffectChrome"), FMMarkingMenuItem(label: "CIPhotoEffectFade"), FMMarkingMenuItem(label: "CIPhotoEffectInstant"), FMMarkingMenuItem(label: "CIPhotoEffectNoir"), FMMarkingMenuItem(label: "CIPhotoEffectTonal"), FMMarkingMenuItem(label: "CIPhotoEffectTransfer")])
        
        let halftone = FMMarkingMenuItem(label: "Halftone", subItems:[FMMarkingMenuItem(label: "CICircularScreen"), FMMarkingMenuItem(label: "CIDotScreen"), FMMarkingMenuItem(label: "CIHatchedScreen"), FMMarkingMenuItem(label: "CILineScreen")])
        
        let styleize = FMMarkingMenuItem(label: "Stylize", subItems:[FMMarkingMenuItem(label: "CIBloom"), FMMarkingMenuItem(label: "CIGloom"), FMMarkingMenuItem(label: "CIPixellate")])
        
        let deepFilter = FMMarkingMenuItem(label: "Deep Menu", subItems: [blur, colorEffect, distort, photoEffect, halftone, styleize])
        
        let markingMenuItems = [blur, colorEffect, distort, photoEffect, halftone, styleize, noFilter, deepFilter]
        
        markingMenu = FMMarkingMenu(viewController: self, view: view, markingMenuItems: markingMenuItems)
        
        markingMenu.markingMenuDelegate = self
    }
    
}




