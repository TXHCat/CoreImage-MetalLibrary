//
//  JCCIKuwaharaFilter.swift
//  CoreImage-MetalLibrary
//
//  Created by Jake on 2018/12/23.
//  Copyright © 2018 Jake. All rights reserved.
//

import Cocoa

class JCCIKuwaharaFilter: CIFilter {
    @objc dynamic var inputImage: CIImage?
    @objc dynamic var inputRadius: CGFloat = 15
    
    override func setDefaults() {
        inputRadius = 15
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "Kuwahara Filter",
            
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            
            "inputRadius": [kCIAttributeIdentity: 0,
                            kCIAttributeClass: "NSNumber",
                            kCIAttributeDefault: 15,
                            kCIAttributeDisplayName: "Radius",
                            kCIAttributeMin: 0,
                            kCIAttributeSliderMin: 0,
                            kCIAttributeSliderMax: 30,
                            kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    private let metalKernel: CIKernel? = {
        do {
            guard let url = Bundle.main.url(forResource: "default", withExtension: "metallib"),
                let data = JCCICustomFilter.sharedInstance.metallibData else {
                    return nil
            }
            let kernel = try CIKernel(functionName: "kuwahara", fromMetalLibraryData: data)
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
        return kernel.apply(extent: image.extent, roiCallback: { (index, rect) -> CGRect in
            return rect
        }, arguments: [image, inputRadius])
    }
}
