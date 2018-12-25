//
//  JCCIOpacityFilter.swift
//  CoreImage-MetalLibrary
//
//  Created by Jake on 2018/12/14.
//  Copyright © 2018 Jake. All rights reserved.
//

import Cocoa
import CoreImage

class JCCIOpacityFilter: CIFilter {
    
    @objc dynamic var inputImage: CIImage?
    @objc dynamic var inputOpacity: CGFloat = 1.0
    
    override func setDefaults() {
        inputOpacity = 1.0
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeDisplayName : "Opacity",
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            
            "inputOpacity": [kCIAttributeIdentity: 1,
                            kCIAttributeClass: "NSNumber",
                            kCIAttributeDefault: 1.0,
                            kCIAttributeDisplayName: "Opacity",
                            kCIAttributeMin: 0,
                            kCIAttributeSliderMin: 0,
                            kCIAttributeSliderMax: 1.0,
                            kCIAttributeType: kCIAttributeTypeScalar],
        ]
    }
    
    private let metalKernel: CIColorKernel? = {
        do {
            guard let url = Bundle.main.url(forResource: "default", withExtension: "metallib"),
                let data = JCCICustomFilter.sharedInstance.metallibData else {
                    return nil
            }
            let kernel = try CIColorKernel(functionName: "commitOpacity", fromMetalLibraryData: data)
            return kernel
        }
        catch {
            return nil
        }
    }()
    
    override var outputImage: CIImage? {
        guard let kernel = metalKernel,
            let image = inputImage else {
            return inputImage
        }
        return kernel.apply(extent: image.extent, arguments: [image, inputOpacity])
    }
}
