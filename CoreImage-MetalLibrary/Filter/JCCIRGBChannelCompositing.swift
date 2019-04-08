//
//  JCCIRGBChannelCompositing.swift
//  CoreImage-MetalLibrary
//
//  Created by Jake on 2018/12/23.
//  Copyright © 2018 Jake. All rights reserved.
//

import Cocoa

fileprivate let tau = CGFloat(Double.pi * 2)

class JCCIRGBChannelCompositing: CIFilter {
    @objc dynamic var inputRedImage : CIImage?
    @objc dynamic var inputGreenImage : CIImage?
    @objc dynamic var inputBlueImage : CIImage?
    
    override func setDefaults() {
        inputRedImage = nil
        inputGreenImage = nil
        inputBlueImage = nil
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "RGB Compositing",
            "inputRedImage": [kCIAttributeIdentity: 0,
                              kCIAttributeClass: "CIImage",
                              kCIAttributeDisplayName: "Red Image",
                              kCIAttributeType: kCIAttributeTypeImage],
            
            "inputGreenImage": [kCIAttributeIdentity: 0,
                                kCIAttributeClass: "CIImage",
                                kCIAttributeDisplayName: "Green Image",
                                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputBlueImage": [kCIAttributeIdentity: 0,
                               kCIAttributeClass: "CIImage",
                               kCIAttributeDisplayName: "Blue Image",
                               kCIAttributeType: kCIAttributeTypeImage]
        ]
    }
    
    private let metalKernel: CIColorKernel? = {
        do {
            guard let data = JCCICustomFilter.sharedInstance.metallibData else {
                return nil
            }
            let kernel = try CIColorKernel(functionName: "rgbChannelCompositing", fromMetalLibraryData: data)
            return kernel
        }
        catch {
            return nil
        }
    }()
    
    override var outputImage: CIImage? {
        guard let kernel = metalKernel,
            let redImage = inputRedImage,
            let greenImage = inputGreenImage,
            let blueImage = inputBlueImage else {
            return nil
        }
        let extent = redImage.extent.union(greenImage.extent.union(blueImage.extent))
        return kernel.apply(extent: extent,
                            arguments: [redImage,
                                        greenImage,
                                        blueImage])
    }
}


class JCCIRGBChannelToneCurve: CIFilter{
    @objc dynamic var inputImage: CIImage?
    
    @objc dynamic var inputRedValues = CIVector(values: [0.0, 0.25, 0.5, 0.75, 1.0], count: 5)
    @objc dynamic var inputGreenValues = CIVector(values: [0.0, 0.25, 0.5, 0.75, 1.0], count: 5)
    @objc dynamic var inputBlueValues = CIVector(values: [0.0, 0.25, 0.5, 0.75, 1.0], count: 5)
    
    private let rgbChannelCompositing = JCCIRGBChannelCompositing()
    
    override func setDefaults(){
        inputRedValues = CIVector(values: [0.0, 0.25, 0.5, 0.75, 1.0], count: 5)
        inputGreenValues = CIVector(values: [0.0, 0.25, 0.5, 0.75, 1.0], count: 5)
        inputBlueValues = CIVector(values: [0.0, 0.25, 0.5, 0.75, 1.0], count: 5)
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "RGB Tone Curve",
            
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            
            "inputRedValues": [kCIAttributeIdentity: 0,
                               kCIAttributeClass: "CIVector",
                               kCIAttributeDefault: CIVector(values: [0.0, 0.25, 0.5, 0.75, 1.0], count: 5),
                               kCIAttributeDisplayName: "Red 'y' Values",
                               kCIAttributeDescription: "Red tone curve 'y' values at 'x' positions [0.0, 0.25, 0.5, 0.75, 1.0].",
                               kCIAttributeType: kCIAttributeTypeOffset],
            
            "inputGreenValues": [kCIAttributeIdentity: 0,
                                 kCIAttributeClass: "CIVector",
                                 kCIAttributeDefault: CIVector(values: [0.0, 0.25, 0.5, 0.75, 1.0], count: 5),
                                 kCIAttributeDisplayName: "Green 'y' Values",
                                 kCIAttributeDescription: "Green tone curve 'y' values at 'x' positions [0.0, 0.25, 0.5, 0.75, 1.0].",
                                 kCIAttributeType: kCIAttributeTypeOffset],
            
            "inputBlueValues": [kCIAttributeIdentity: 0,
                                kCIAttributeClass: "CIVector",
                                kCIAttributeDefault: CIVector(values: [0.0, 0.25, 0.5, 0.75, 1.0], count: 5),
                                kCIAttributeDisplayName: "Blue 'y' Values",
                                kCIAttributeDescription: "Blue tone curve 'y' values at 'x' positions [0.0, 0.25, 0.5, 0.75, 1.0].",
                                kCIAttributeType: kCIAttributeTypeOffset]
        ]
    }
    
    override var outputImage: CIImage? {
        guard let image = inputImage else {
            return inputImage
        }
        let red = image.applyingFilter("CIToneCurve",
                                       parameters: [
                                        "inputPoint0": CIVector(x: 0.0, y: inputRedValues.value(at: 0)),
                                        "inputPoint1": CIVector(x: 0.25, y: inputRedValues.value(at: 1)),
                                        "inputPoint2": CIVector(x: 0.5, y: inputRedValues.value(at: 2)),
                                        "inputPoint3": CIVector(x: 0.75, y: inputRedValues.value(at: 3)),
                                        "inputPoint4": CIVector(x: 1.0, y: inputRedValues.value(at: 4))
            ])
        
        let green = image.applyingFilter("CIToneCurve",
                                         parameters: [
                                            "inputPoint0": CIVector(x: 0.0, y: inputGreenValues.value(at: 0)),
                                            "inputPoint1": CIVector(x: 0.25, y: inputGreenValues.value(at: 1)),
                                            "inputPoint2": CIVector(x: 0.5, y: inputGreenValues.value(at: 2)),
                                            "inputPoint3": CIVector(x: 0.75, y: inputGreenValues.value(at: 3)),
                                            "inputPoint4": CIVector(x: 1.0, y: inputGreenValues.value(at: 4))
            ])
        
        let blue = image.applyingFilter("CIToneCurve",
                                        parameters: [
                                            "inputPoint0": CIVector(x: 0.0, y: inputBlueValues.value(at: 0)),
                                            "inputPoint1": CIVector(x: 0.25, y: inputBlueValues.value(at: 1)),
                                            "inputPoint2": CIVector(x: 0.5, y: inputBlueValues.value(at: 2)),
                                            "inputPoint3": CIVector(x: 0.75, y: inputBlueValues.value(at: 3)),
                                            "inputPoint4": CIVector(x: 1.0, y: inputBlueValues.value(at: 4))
            ])
        rgbChannelCompositing.inputRedImage = red
        rgbChannelCompositing.inputGreenImage = green
        rgbChannelCompositing.inputBlueImage = blue
        return rgbChannelCompositing.outputImage
    }
}

class JCCIChromaticAberration: CIFilter {
    @objc dynamic var inputImage: CIImage?
    
    @objc dynamic var inputAngle: CGFloat = 0
    @objc dynamic var inputRadius: CGFloat = 2
    
    private let rgbChannelCompositing = JCCIRGBChannelCompositing()
    
    override func setDefaults(){
        inputAngle = 0
        inputRadius = 2
    }
    
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "Chromatic Abberation",
            
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            
            "inputAngle": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "NSNumber",
                           kCIAttributeDefault: 0,
                           kCIAttributeDisplayName: "Angle",
                           kCIAttributeMin: 0,
                           kCIAttributeSliderMin: 0,
                           kCIAttributeSliderMax: tau,
                           kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputRadius": [kCIAttributeIdentity: 0,
                            kCIAttributeClass: "NSNumber",
                            kCIAttributeDefault: 2,
                            kCIAttributeDisplayName: "Radius",
                            kCIAttributeMin: 0,
                            kCIAttributeSliderMin: 0,
                            kCIAttributeSliderMax: 25,
                            kCIAttributeType: kCIAttributeTypeScalar],
        ]
    }
    
    override var outputImage: CIImage? {
        guard let image = inputImage else {
            return inputImage
        }
        
        let redAngle = inputAngle + tau
        let greenAngle = inputAngle + tau * 0.333
        let blueAngle = inputAngle + tau * 0.666
        
        let redTransform = CGAffineTransform(translationX: sin(redAngle) * inputRadius,
                                             y: cos(redAngle) * inputRadius)
        let greenTransform = CGAffineTransform(translationX: sin(greenAngle) * inputRadius,
                                               y: cos(greenAngle) * inputRadius)
        let blueTransform = CGAffineTransform(translationX: sin(blueAngle) * inputRadius,
                                              y: cos(blueAngle) * inputRadius)
        
        let red = image.transformed(by: redTransform).cropped(to: image.extent)
        
        let green = image.transformed(by: greenTransform).cropped(to: image.extent)
        
        let blue = image.transformed(by: blueTransform).cropped(to: image.extent)
        
        rgbChannelCompositing.inputRedImage = red
        rgbChannelCompositing.inputGreenImage = green
        rgbChannelCompositing.inputBlueImage = blue
        
        return rgbChannelCompositing.outputImage
    }
}
