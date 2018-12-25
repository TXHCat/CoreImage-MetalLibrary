//
//  JCCIVHSTrackingLines.swift
//  CoreImage-MetalLibrary
//
//  Created by Jake on 2018/12/24.
//  Copyright © 2018 Jake. All rights reserved.
//

import Cocoa

class JCCIVHSTrackingLines: CIFilter {
    @objc dynamic var inputImage: CIImage?
    @objc dynamic var inputTime: CGFloat = 0
    @objc dynamic var inputSpacing: CGFloat = 50
    @objc dynamic var inputStripeHeight: CGFloat = 0.5
    @objc dynamic var inputBackgroundNoise: CGFloat = 0.05
    
    override func setDefaults(){
        inputTime = 0.0
        inputSpacing = 50
        inputStripeHeight = 0.5
        inputBackgroundNoise = 0.05
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "VHS Tracking Lines",
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            "inputTime": [kCIAttributeIdentity: 0,
                          kCIAttributeClass: "NSNumber",
                          kCIAttributeDefault: 8,
                          kCIAttributeDisplayName: "Time",
                          kCIAttributeMin: 0,
                          kCIAttributeSliderMin: 0,
                          kCIAttributeSliderMax: 2048,
                          kCIAttributeType: kCIAttributeTypeScalar],
            "inputSpacing": [kCIAttributeIdentity: 0,
                             kCIAttributeClass: "NSNumber",
                             kCIAttributeDefault: 50,
                             kCIAttributeDisplayName: "Spacing",
                             kCIAttributeMin: 20,
                             kCIAttributeSliderMin: 20,
                             kCIAttributeSliderMax: 200,
                             kCIAttributeType: kCIAttributeTypeScalar],
            "inputStripeHeight": [kCIAttributeIdentity: 0,
                                  kCIAttributeClass: "NSNumber",
                                  kCIAttributeDefault: 0.5,
                                  kCIAttributeDisplayName: "Stripe Height",
                                  kCIAttributeMin: 0,
                                  kCIAttributeSliderMin: 0,
                                  kCIAttributeSliderMax: 1,
                                  kCIAttributeType: kCIAttributeTypeScalar],
            "inputBackgroundNoise": [kCIAttributeIdentity: 0,
                                     kCIAttributeClass: "NSNumber",
                                     kCIAttributeDefault: 0.05,
                                     kCIAttributeDisplayName: "Background Noise",
                                     kCIAttributeMin: 0,
                                     kCIAttributeSliderMin: 0,
                                     kCIAttributeSliderMax: 0.25,
                                     kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    private let metalKernel: CIColorKernel? = {
        do {
            guard let url = Bundle.main.url(forResource: "default", withExtension: "metallib"),
                let data = JCCICustomFilter.sharedInstance.metallibData else {
                    return nil
            }
            let kernel = try CIColorKernel(functionName: "VHSTrackingLines", fromMetalLibraryData: data)
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
        
        guard let noise = CIFilter(name: "CIRandomGenerator")?.outputImage?
            .applyingFilter("CIAffineTransform",
                            parameters: [kCIInputTransformKey: CGAffineTransform(translationX: CGFloat(drand48() * 100), y: CGFloat(drand48() * 100))])
            .applyingFilter("CILanczosScaleTransform",
                            parameters: [kCIInputAspectRatioKey: 5])
            .cropped(to: image.extent) else {
                return inputImage
        }
        
        return kernel.apply(extent: image.extent,
                            arguments: [image, noise,
                                        inputTime,
                                        inputSpacing,
                                        inputStripeHeight,
                                        inputBackgroundNoise])
    }
}
