//
//  JCCIBleachBypass.swift
//  CoreImage-MetalLibrary
//
//  Created by Jake on 2018/12/23.
//  Copyright © 2018 Jake. All rights reserved.
//

import Cocoa

class JCCIBleachBypass: CIFilter {
    
    @objc dynamic var inputImage: CIImage?
    @objc dynamic var inputAmount: CGFloat = 1.0
    
    override func setDefaults() {
        inputAmount = 1.0
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "Bleach Bypass Filter",
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            
            "inputAmount": [kCIAttributeIdentity: 0,
                            kCIAttributeClass: "NSNumber",
                            kCIAttributeDefault: 1,
                            kCIAttributeDisplayName: "Amount",
                            kCIAttributeMin: 0,
                            kCIAttributeSliderMin: 0,
                            kCIAttributeSliderMax: 1,
                            kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    private let metalKernel: CIColorKernel? = {
        do {
            guard let data = JCCICustomFilter.sharedInstance.metallibData else {
                return nil
            }
            let kernel = try CIColorKernel(functionName: "bleachBypass", fromMetalLibraryData: data)
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
        return kernel.apply(extent: image.extent, arguments: [image, inputAmount])
    }
}
