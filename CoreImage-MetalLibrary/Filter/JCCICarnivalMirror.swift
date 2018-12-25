//
//  JCCICarnivalMirror.swift
//  CoreImage-MetalLibrary
//
//  Created by Jake on 2018/12/23.
//  Copyright © 2018 Jake. All rights reserved.
//

import Cocoa

class JCCICarnivalMirror: CIFilter {
    @objc dynamic var inputImage: CIImage?
    
    @objc dynamic var inputHorizontalWavelength: CGFloat = 10
    @objc dynamic var inputHorizontalAmount: CGFloat = 20
    
    @objc dynamic var inputVerticalWavelength: CGFloat = 10
    @objc dynamic var inputVerticalAmount: CGFloat = 20
    
    override func setDefaults(){
        inputHorizontalWavelength = 10
        inputHorizontalAmount = 20
        
        inputVerticalWavelength = 10
        inputVerticalAmount = 20
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "Carnival Mirror",
            
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            
            "inputHorizontalWavelength": [kCIAttributeIdentity: 0,
                                          kCIAttributeClass: "NSNumber",
                                          kCIAttributeDefault: 10,
                                          kCIAttributeDisplayName: "Horizontal Wavelength",
                                          kCIAttributeMin: 0,
                                          kCIAttributeSliderMin: 0,
                                          kCIAttributeSliderMax: 100,
                                          kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputHorizontalAmount": [kCIAttributeIdentity: 0,
                                      kCIAttributeClass: "NSNumber",
                                      kCIAttributeDefault: 20,
                                      kCIAttributeDisplayName: "Horizontal Amount",
                                      kCIAttributeMin: 0,
                                      kCIAttributeSliderMin: 0,
                                      kCIAttributeSliderMax: 100,
                                      kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputVerticalWavelength": [kCIAttributeIdentity: 0,
                                        kCIAttributeClass: "NSNumber",
                                        kCIAttributeDefault: 10,
                                        kCIAttributeDisplayName: "Vertical Wavelength",
                                        kCIAttributeMin: 0,
                                        kCIAttributeSliderMin: 0,
                                        kCIAttributeSliderMax: 100,
                                        kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputVerticalAmount": [kCIAttributeIdentity: 0,
                                    kCIAttributeClass: "NSNumber",
                                    kCIAttributeDefault: 20,
                                    kCIAttributeDisplayName: "Vertical Amount",
                                    kCIAttributeMin: 0,
                                    kCIAttributeSliderMin: 0,
                                    kCIAttributeSliderMax: 100,
                                    kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    private let metalKernel: CIWarpKernel? = {
        do {
            guard let url = Bundle.main.url(forResource: "default", withExtension: "metallib"),
                let data = JCCICustomFilter.sharedInstance.metallibData else {
                    return nil
            }
            let kernel = try CIWarpKernel(functionName: "carnivalMirror", fromMetalLibraryData: data)
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
                            roiCallback:
            { (index, extent) -> CGRect in
                return extent
            },
                            image: image,
                            arguments: [inputHorizontalWavelength,
                                        inputHorizontalAmount,
                                        inputVerticalWavelength,
                                        inputVerticalAmount])
    }
}
