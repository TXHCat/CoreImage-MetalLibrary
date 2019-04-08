//
//  JCCIAdvancedMonochrome.swift
//  CoreImage-MetalLibrary
//
//  Created by Jake on 2018/12/23.
//  Copyright © 2018 Jake. All rights reserved.
//

import Cocoa

class JCCIAdvancedMonochrome: CIFilter {
    
    @objc dynamic var inputImage: CIImage?
    @objc dynamic var inputRedBalance: CGFloat = 1.0
    @objc dynamic var inputGreenBalance: CGFloat = 1.0
    @objc dynamic var inputBlueBalance: CGFloat = 1.0
    @objc dynamic var inputClamp: CGFloat = 0.0
    
    override func setDefaults() {
        inputRedBalance = 1.0
        inputGreenBalance = 1.0
        inputBlueBalance = 1.0
        inputClamp = 0.0
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "Advanced Monochrome",
            
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            
            "inputRedBalance": [kCIAttributeIdentity: 0,
                                kCIAttributeClass: "NSNumber",
                                kCIAttributeDefault: 1,
                                kCIAttributeDisplayName: "Red Balance",
                                kCIAttributeMin: 0,
                                kCIAttributeSliderMin: 0,
                                kCIAttributeSliderMax: 1,
                                kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputGreenBalance": [kCIAttributeIdentity: 0,
                                  kCIAttributeClass: "NSNumber",
                                  kCIAttributeDefault: 1,
                                  kCIAttributeDisplayName: "Green Balance",
                                  kCIAttributeMin: 0,
                                  kCIAttributeSliderMin: 0,
                                  kCIAttributeSliderMax: 1,
                                  kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputBlueBalance": [kCIAttributeIdentity: 0,
                                 kCIAttributeClass: "NSNumber",
                                 kCIAttributeDefault: 1,
                                 kCIAttributeDisplayName: "Blue Balance",
                                 kCIAttributeMin: 0,
                                 kCIAttributeSliderMin: 0,
                                 kCIAttributeSliderMax: 1,
                                 kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputClamp": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "NSNumber",
                           kCIAttributeDefault: 0,
                           kCIAttributeDisplayName: "Clamp",
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
            let kernel = try CIColorKernel(functionName: "advancedMonochrome", fromMetalLibraryData: data)
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
                                        inputRedBalance,
                                        inputGreenBalance,
                                        inputBlueBalance,
                                        inputClamp])
    }
}
