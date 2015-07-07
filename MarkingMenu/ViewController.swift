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
    
    let ciContextFast = CIContext(EAGLContext: EAGLContext(API: EAGLRenderingAPI.OpenGLES2), options: [kCIContextWorkingColorSpace: NSNull()])
    
    let currentFilterLabel = UILabel()
    var filterName: String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        createMarkingMenu()
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFit

        view.addSubview(imageView)
        view.addSubview(currentFilterLabel)
        
        applyFilter()
    }
    
    func FMMarkingMenuItemSelected(markingMenu: FMMarkingMenu, markingMenuItem: FMMarkingMenuItem)
    {
        let filters = (CIFilter.filterNamesInCategories(nil) ?? [AnyObject]()).filter({ $0 as! String ==  markingMenuItem.label})
        
        filterName = filters.count != 0 ? markingMenuItem.label : nil
        
        applyFilter()
        
        currentFilterLabel.text = markingMenuItem.label
        currentFilterLabel.frame = CGRect(x: 5, y: view.frame.height - currentFilterLabel.intrinsicContentSize().height - 5, width: currentFilterLabel.intrinsicContentSize().width, height: currentFilterLabel.intrinsicContentSize().height)
    }
    
    func FMMarkingMenuValueSliderChange(markingMenu: FMMarkingMenu, markingMenuItem: FMMarkingMenuItem, markingMenuItemIndex: Int, newValue: CGFloat)
    {
        markingMenuItems[markingMenuItemIndex].valueSliderValue = newValue
        
        // print("setting \(markingMenuItemIndex) to \(newValue)")
        
        applyFilter()
    }
    
    func applyFilter()
    {
        let colorControls = CIFilter(name: "CIColorControls")
        
        colorControls!.setValue(CIImage(image: photo), forKey: kCIInputImageKey)
        colorControls!.setValue(markingMenuItems[0].valueSliderValue, forKey: kCIInputBrightnessKey)
        colorControls!.setValue(markingMenuItems[1].valueSliderValue, forKey: kCIInputSaturationKey)
        colorControls!.setValue(markingMenuItems[2].valueSliderValue, forKey: kCIInputContrastKey)
 
        let filteredImageData: CIImage
        
        if let filterName = filterName
        {
            let ciFilter = CIFilter(name: filterName)
  
            ciFilter!.setValue(colorControls!.valueForKey(kCIOutputImageKey) as! CIImage!, forKey: kCIInputImageKey)
            
            filteredImageData = ciFilter!.valueForKey(kCIOutputImageKey) as! CIImage!
        }
        else
        {
            filteredImageData = colorControls!.valueForKey(kCIOutputImageKey) as! CIImage!
        }
        
        let filteredImage = UIImage(CIImage: filteredImageData)
        
        imageView.image = filteredImage
    }
    
    var markingMenuItems: [FMMarkingMenuItem]!
    
    func createMarkingMenu()
    {
        let blur = FMMarkingMenuItem(label: "Blur & Sharpen", subItems:[FMMarkingMenuItem(label: "CIGaussianBlur"), FMMarkingMenuItem(label: "CISharpenLuminance"), FMMarkingMenuItem(label: "CIUnsharpMask")])
        
        let noFilter = FMMarkingMenuItem(label: "No Filter")
        
        let distort = FMMarkingMenuItem(label: "Distort", subItems:[FMMarkingMenuItem(label: "CIPinchDistortion"), FMMarkingMenuItem(label: "CITwirlDistortion"), FMMarkingMenuItem(label: "CIVortexDistortion")])
        
        let colorEffect = FMMarkingMenuItem(label: "Color Effect", subItems:[FMMarkingMenuItem(label: "CIColorInvert"), FMMarkingMenuItem(label: "CIColorMonochrome"), FMMarkingMenuItem(label: "CIColorPosterize"), FMMarkingMenuItem(label: "CIFalseColor"), FMMarkingMenuItem(label: "CISepiaTone")])
        
        let photoEffect = FMMarkingMenuItem(label: "Photo Effect", subItems:[FMMarkingMenuItem(label: "CIPhotoEffectChrome"), FMMarkingMenuItem(label: "CIPhotoEffectFade"), FMMarkingMenuItem(label: "CIPhotoEffectInstant"), FMMarkingMenuItem(label: "CIPhotoEffectNoir"), FMMarkingMenuItem(label: "CIPhotoEffectTonal"), FMMarkingMenuItem(label: "CIPhotoEffectTransfer")])
        
        let halftone = FMMarkingMenuItem(label: "Halftone", subItems:[FMMarkingMenuItem(label: "CICircularScreen"), FMMarkingMenuItem(label: "CIDotScreen"), FMMarkingMenuItem(label: "CIHatchedScreen"), FMMarkingMenuItem(label: "CILineScreen")])
        
        let styleize = FMMarkingMenuItem(label: "Stylize", subItems:[FMMarkingMenuItem(label: "CIBloom"), FMMarkingMenuItem(label: "CIGloom"), FMMarkingMenuItem(label: "CIPixellate")])
        
    
        var brightness = FMMarkingMenuItem(label: "Brightness", subItems: [], isValueSlider: true)
        var saturation = FMMarkingMenuItem(label: "Saturation", subItems: [], isValueSlider: true)
        var contrast = FMMarkingMenuItem(label: "Contrast", subItems: [], isValueSlider: true)
        
        brightness.valueSliderValue = 0
        saturation.valueSliderValue = 0.75;
        contrast.valueSliderValue = 1
        
        markingMenuItems = [brightness, saturation, contrast, blur, colorEffect, distort, photoEffect, halftone, styleize, noFilter]
        
        markingMenu = FMMarkingMenu(viewController: self, view: view, markingMenuItems: markingMenuItems)
        
        markingMenu.markingMenuDelegate = self
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        imageView.frame = view.bounds.rectByInsetting(dx: 30, dy: 30)
    }
    
}




