//
//  JCCIStarFieldGenerator.swift
//  CoreImage-MetalLibrary
//
//  Created by Jake Cai on 2019/4/19.
//  Copyright © 2019 Jake. All rights reserved.
//

import Cocoa

class JCCIStarFieldGenerator: CIFilter {
    @objc dynamic var inputExtent = CIVector(x: 0, y: 0, z: 640, w: 480)
    @objc dynamic var inputTime: CGFloat = 0.0
    @objc dynamic var inputCenter = CIVector(x: 100, y: 100)
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "Star Field",
            
            "inputTime": [kCIAttributeIdentity: 0,
                          kCIAttributeClass: "NSNumber",
                          kCIAttributeDefault: 0.0,
                          kCIAttributeDisplayName: "Time",
                          kCIAttributeMin: 0,
                          kCIAttributeSliderMin: -100,
                          kCIAttributeSliderMax: 100,
                          kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputExtent": [kCIAttributeIdentity: 0,
                            kCIAttributeClass: "CIVector",
                            kCIAttributeDefault: [0, 0, 640, 480],
                            kCIAttributeDisplayName: "Extent",
                            kCIAttributeType: kCIAttributeTypeRectangle],
            
            "inputCenter": [kCIAttributeIdentity: 0,
                              kCIAttributeClass: "CIVector",
                              kCIAttributeDisplayName: "Center",
                              kCIAttributeDefault: [100, 100],
                              kCIAttributeType: kCIAttributeTypePosition],
        ]
    }
    
    override func setDefaults() {
        inputExtent = CIVector(x: 0, y: 0, z: 640, w: 480)
        inputCenter = CIVector(x: 100, y: 100)
        inputTime = 0.0
    }
    
    private let metalKernel: CIColorKernel? = {
        do {
            guard let data = JCCICustomFilter.sharedInstance.metallibData else {
                return nil
            }
            let kernel = try CIColorKernel(functionName: "starField", fromMetalLibraryData: data)
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
        return kernel.apply(extent: inputExtent.cgRectValue,
                            arguments: [inputExtent,
                                        inputTime,
                                        inputCenter])
    }
}
