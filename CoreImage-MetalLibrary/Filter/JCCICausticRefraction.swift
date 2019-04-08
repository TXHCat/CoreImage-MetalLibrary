//
//  JCCICausticRefraction.swift
//  CoreImage-MetalLibrary
//
//  Created by Jake on 2018/12/23.
//  Copyright © 2018 Jake. All rights reserved.
//

import Cocoa

class JCCICausticNoise: CIFilter{
    @objc dynamic var inputTime: CGFloat = 1
    @objc dynamic var inputTileSize: CGFloat = 640
    @objc dynamic var inputWidth: CGFloat = 640
    @objc dynamic var inputHeight: CGFloat = 640
    
    override func setDefaults() {
        inputTime = 1
        inputTileSize = 640
        inputWidth = 640
        inputHeight = 640
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "Caustic Noise",
            
            "inputTime": [kCIAttributeIdentity: 0,
                          kCIAttributeClass: "NSNumber",
                          kCIAttributeDefault: 1,
                          kCIAttributeDisplayName: "Time",
                          kCIAttributeMin: 0,
                          kCIAttributeSliderMin: 0,
                          kCIAttributeSliderMax: 1000,
                          kCIAttributeType: kCIAttributeTypeScalar],
            "inputTileSize": [kCIAttributeIdentity: 0,
                              kCIAttributeClass: "NSNumber",
                              kCIAttributeDefault: 640,
                              kCIAttributeDisplayName: "Tile Size",
                              kCIAttributeMin: 10,
                              kCIAttributeSliderMin: 10,
                              kCIAttributeSliderMax: 2048,
                              kCIAttributeType: kCIAttributeTypeScalar],
            "inputWidth": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "NSNumber",
                           kCIAttributeDefault: 640,
                           kCIAttributeDisplayName: "Width",
                           kCIAttributeMin: 0,
                           kCIAttributeSliderMin: 0,
                           kCIAttributeSliderMax: 1280,
                           kCIAttributeType: kCIAttributeTypeScalar],
            "inputHeight": [kCIAttributeIdentity: 0,
                            kCIAttributeClass: "NSNumber",
                            kCIAttributeDefault: 640,
                            kCIAttributeDisplayName: "Height",
                            kCIAttributeMin: 0,
                            kCIAttributeSliderMin: 0,
                            kCIAttributeSliderMax: 1280,
                            kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    private let metalKernel: CIColorKernel? = {
        do {
            guard let data = JCCICustomFilter.sharedInstance.metallibData else {
                return nil
            }
            let kernel = try CIColorKernel(functionName: "causticNoise", fromMetalLibraryData: data)
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
        let extent = CGRect(x: 0, y: 0, width: inputWidth, height: inputHeight)
        
        return kernel.apply(extent: extent, arguments: [inputTime, inputTileSize])
    }
}

class JCCICausticRefraction: CIFilter {
    @objc dynamic var inputImage: CIImage?
    @objc dynamic var inputRefractiveIndex: CGFloat = 4.0
    @objc dynamic var inputLensScale: CGFloat = 50
    @objc dynamic var inputLightingAmount: CGFloat = 5
    @objc dynamic var inputTime: CGFloat = 1
    @objc dynamic var inputTileSize: CGFloat = 640
    @objc dynamic var inputSoftening: CGFloat = 3
    
    override func setDefaults() {
        inputRefractiveIndex = 4.0
        inputLensScale = 50
        inputLightingAmount = 1.5
        inputTime = 1
        inputTileSize = 640
        inputSoftening = 3
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "Caustic Refraction",
            
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            
            "inputRefractiveIndex": [kCIAttributeIdentity: 0,
                                     kCIAttributeClass: "NSNumber",
                                     kCIAttributeDefault: 4.0,
                                     kCIAttributeDisplayName: "Refractive Index",
                                     kCIAttributeMin: -4.0,
                                     kCIAttributeSliderMin: -10.0,
                                     kCIAttributeSliderMax: 10,
                                     kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputLensScale": [kCIAttributeIdentity: 0,
                               kCIAttributeClass: "NSNumber",
                               kCIAttributeDefault: 50,
                               kCIAttributeDisplayName: "Lens Scale",
                               kCIAttributeMin: 1,
                               kCIAttributeSliderMin: 1,
                               kCIAttributeSliderMax: 100,
                               kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputLightingAmount": [kCIAttributeIdentity: 0,
                                    kCIAttributeClass: "NSNumber",
                                    kCIAttributeDefault: 1.5,
                                    kCIAttributeDisplayName: "Lighting Amount",
                                    kCIAttributeMin: 0,
                                    kCIAttributeSliderMin: 0,
                                    kCIAttributeSliderMax: 5,
                                    kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputTime": [kCIAttributeIdentity: 0,
                          kCIAttributeClass: "NSNumber",
                          kCIAttributeDefault: 1,
                          kCIAttributeDisplayName: "Time",
                          kCIAttributeMin: 0,
                          kCIAttributeSliderMin: 0,
                          kCIAttributeSliderMax: 1000,
                          kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputTileSize": [kCIAttributeIdentity: 0,
                              kCIAttributeClass: "NSNumber",
                              kCIAttributeDefault: 640,
                              kCIAttributeDisplayName: "Tile Size",
                              kCIAttributeMin: 10,
                              kCIAttributeSliderMin: 10,
                              kCIAttributeSliderMax: 2048,
                              kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputSoftening": [kCIAttributeIdentity: 0,
                               kCIAttributeClass: "NSNumber",
                               kCIAttributeDefault: 3,
                               kCIAttributeDisplayName: "Softening",
                               kCIAttributeMin: 0,
                               kCIAttributeSliderMin: 0,
                               kCIAttributeSliderMax: 20,
                               kCIAttributeType: kCIAttributeTypeScalar],
        ]
    }
    
    private let metalKernel: CIKernel? = {
        do {
            guard let data = JCCICustomFilter.sharedInstance.metallibData else {
                return nil
            }
            let kernel = try CIKernel(functionName: "causticRefraction", fromMetalLibraryData: data)
            return kernel
        }
        catch {
            return nil
        }
    }()
    
    private let causticNoise = JCCICausticNoise()
    
    override var outputImage: CIImage? {
        guard let image = inputImage,
            let kernel = metalKernel else {
            return inputImage
        }
        causticNoise.inputTileSize = inputTileSize
        causticNoise.inputTime = inputTime
        causticNoise.inputWidth = image.extent.width
        causticNoise.inputHeight = image.extent.height
        guard let refractionImage = causticNoise.outputImage?.applyingFilter("CIGaussianBlur",
                                                                             parameters: [kCIInputRadiusKey : inputSoftening]) else {
            return inputImage
        }
        
        return kernel.apply(extent: image.extent,
                            roiCallback:
            { (index, rect) -> CGRect in
                return rect
            },
                            arguments: [image,
                                        refractionImage,
                                        inputRefractiveIndex,
                                        inputLensScale,
                                        inputLightingAmount])
    }
}
