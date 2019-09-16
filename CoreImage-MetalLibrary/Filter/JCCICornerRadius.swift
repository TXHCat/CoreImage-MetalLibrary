//
//  JCCornerClip.swift
//  CoreImage-MetalLibrary
//
//  Created by Jake Cai on 2019/7/5.
//  Copyright © 2019 Jake. All rights reserved.
//

import Cocoa

class JCCICornerRadius: CIFilter {
    @objc dynamic var inputImage: CIImage?
    @objc dynamic var inputPercent: CGFloat = 0
    
    override func setDefaults() {
        inputPercent = 0
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeDisplayName : "Corner Radius",
            
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            
            "inputPercent": [kCIAttributeIdentity: 0,
                             kCIAttributeClass: "NSNumber",
                             kCIAttributeDisplayName: "Percent",
                             kCIAttributeDefault: 0,
                             kCIAttributeSliderMax: 1.0,
                             kCIAttributeSliderMin: 0.0,
                             kCIAttributeType: kCIAttributeTypeScalar],
        ]
    }
    
    private let metalKernel: CIColorKernel? = {
        do {
            guard let data = JCCICustomFilter.sharedInstance.metallibData else {
                return nil
            }
            let kernel = try CIColorKernel(functionName: "cornerRadius",
                                           fromMetalLibraryData: data)
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
        return kernel.apply(extent: image.extent,
                            arguments: [image,
                                        CIVector(x: image.extent.size.width, y: image.extent.size.height),
                                        inputPercent])
    }
}
