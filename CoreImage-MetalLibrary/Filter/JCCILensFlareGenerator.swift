//
//  JCCILensFlareGenerator.swift
//  CoreImage-MetalLibrary
//
//  Created by Jake on 2018/12/23.
//  Copyright © 2018 Jake. All rights reserved.
//

import Cocoa

class JCCILensFlareGenerator: CIFilter {
    @objc dynamic var inputExtent = CIVector(x: 0, y: 0, z: 300, w: 300)
    @objc dynamic var inputCenter = CIVector(x: 10, y: 10)
    @objc dynamic var inputTime: CGFloat = 1.0
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "Lens Flare",
            
            "inputTime": [kCIAttributeIdentity: 0,
                          kCIAttributeClass: "NSNumber",
                          kCIAttributeDefault: 1,
                          kCIAttributeDisplayName: "Time",
                          kCIAttributeMin: 0,
                          kCIAttributeSliderMin: -1,
                          kCIAttributeSliderMax: 1,
                          kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputExtent": [kCIAttributeIdentity: 0,
                            kCIAttributeClass: "CIVector",
                            kCIAttributeDefault: [0, 0, 300, 300],
                            kCIAttributeDisplayName: "Extent",
                            kCIAttributeType: kCIAttributeTypeRectangle],
            
            "inputCenter": [kCIAttributeIdentity: 0,
                            kCIAttributeClass: "CIVector",
                            kCIAttributeDisplayName: "Center",
                            kCIAttributeDefault: [10, 10],
                            kCIAttributeType: kCIAttributeTypePosition],
        ]
    }
    
    override func setDefaults() {
        inputExtent = CIVector(x: 0, y: 0, z: 300, w: 300)
        inputCenter = CIVector(x: 10, y: 10)
        inputTime = 1.0
    }
    
    private let metalKernel: CIColorKernel? = {
        do {
            guard let url = Bundle.main.url(forResource: "default", withExtension: "metallib"),
                let data = JCCICustomFilter.sharedInstance.metallibData else {
                    return nil
            }
            let kernel = try CIColorKernel(functionName: "lensFlare", fromMetalLibraryData: data)
            return kernel
        }
        catch {
            return nil
        }
    }()
    
    override var outputImage: CIImage? {
        guard let kernel = metalKernel else {
            return nil
        }
        return kernel.apply(extent: inputExtent.cgRectValue, arguments: [CIVector(x: inputExtent.z, y: inputExtent.w),
                                                                         inputCenter,
                                                                         inputTime])
    }
}
