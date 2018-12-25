//
//  JCCIImageRenderer.swift
//  JCCIImageView
//
//  Created by Jake on 2018/7/24.
//  Copyright © 2018 Jake. All rights reserved.
//

#if os(macOS)
import AppKit
public typealias View = NSView
public typealias ImageView = NSImageView
public typealias Color = NSColor
public typealias Image = NSImage
#else
import UIKit
public typealias View = UIView
public typealias ImageView = UIImageView
public typealias Color = UIColor
public typealias Image = UIImage
#endif

import MetalKit
import GLKit

public protocol JCCIImageRenderer {
    func renderImage(_ image:CIImage?)
    #if os(macOS)
    var view : NSView { get }
    #else
    var view : UIView { get }
    #endif
    var context : CIContext? { get set }
}

class JCCIImageMetalRenderer: NSObject, JCCIImageRenderer, MTKViewDelegate{
    private var _view : MTKView!
    var view: View{
        return _view
    }
    
    var context: CIContext?
    
    private var device : MTLDevice!
    private var commandQueue: MTLCommandQueue?
    private var image : CIImage?
    
    init(_ device:MTLDevice) {
        super.init()
        self.device = device
        _view = MTKView(frame: CGRect.zero, device: device)
        _view.clearColor = MTLClearColorMake(0, 0, 0, 0)
        
        #if os(iOS)
        _view.backgroundColor = Color.clear
        #endif
        
        _view.delegate = self
        _view.framebufferOnly = false
        _view.enableSetNeedsDisplay = true
        
        self.context = CIContext(mtlDevice: device,
                                 options: [.workingColorSpace : CGColorSpaceCreateDeviceRGB()])
        self.commandQueue = device.makeCommandQueue()
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = self.commandQueue?.makeCommandBuffer(),
            let currentDrawable = _view.currentDrawable,
            let ciimage = self.image else {
            return
        }
        let outputTexture = currentDrawable.texture
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        self.context?.render(ciimage, to: outputTexture, commandBuffer: commandBuffer, bounds: ciimage.extent, colorSpace: colorSpace)
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        #if os(macOS)
        view.needsDisplay = true
        #else
        view.setNeedsDisplay()
        #endif
    }
    
    func renderImage(_ image: CIImage?) {
        self.image = image
        #if os(macOS)
        view.needsDisplay = true
        #else
        view.setNeedsDisplay()
        #endif
    }
}

#if os(iOS)
class JCCIImageGLKRenderer: NSObject, JCCIImageRenderer, GLKViewDelegate {
    private var _view : GLKView!
    var view : UIView {
        return _view
    }
    
    var context: CIContext?
    
    private var image : CIImage?
    
    init(_ GLContext:EAGLContext) {
        super.init()
        self.context = CIContext(eaglContext: GLContext,
                                 options: [.workingColorSpace : CGColorSpaceCreateDeviceRGB()])
        _view = GLKView(frame: CGRect.zero, context: GLContext)
        _view.delegate = self
        _view.contentScaleFactor = UIScreen.main.scale
    }
    
    func glkView(_ view: GLKView, drawIn rect: CGRect) {
        guard let ciimage = self.image else {
            return
        }
        glClearColor(0, 0, 0, 0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        let size = rect.size.applying(CGAffineTransform(scaleX: self.view.contentScaleFactor,
                                                        y: self.view.contentScaleFactor))
        self.context?.draw(ciimage,
                           in: CGRect(x: 0,
                                      y: 0,
                                      width: size.width,
                                      height: size.height),
                           from: ciimage.extent)
    }
    
    func renderImage(_ image: CIImage?) {
        self.image = image
        self.view.setNeedsDisplay()
    }
}
#endif


class JCCIImageCoreGraphicsRenderer: NSObject, JCCIImageRenderer {
    private var _view : ImageView!
    var view : View {
        return _view
    }
    
    var context: CIContext?
    
    override init() {
        super.init()
        _view = ImageView(frame: CGRect.zero)
        self.context = CIContext(options: [.workingColorSpace : CGColorSpaceCreateDeviceRGB()])
    }
    
    func renderImage(_ image: CIImage?) {
        guard let ciimage = image,
            let outputImage = self.context?.createCGImage(ciimage, from: ciimage.extent) else {
            return
        }
        
        #if os(macOS)
        let result = Image(cgImage: outputImage, size: ciimage.extent.size)
        #else
        let result = Image(cgImage: outputImage)
        #endif
        _view.image = result
    }
}
