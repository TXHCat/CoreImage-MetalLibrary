//
//  ViewController.swift
//  CoreImage-MetalLibrary
//
//  Created by Jake on 2018/12/14.
//  Copyright © 2018 Jake. All rights reserved.
//

import Cocoa
import CoreImage

class ViewController: NSViewController {
    
    private lazy var ciImageView: JCCIImageView = {
        let v = JCCIImageView()
        v.renderer = JCCIImageViewSuggestedRenderer()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var filterList: JCFilterListViewController = {
        let vc = JCFilterListViewController()
        addChild(vc)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.didSelectFilter = { [weak self] (name) in
            self?.currentFilter = CIFilter(name: name)
        }
        return vc
    }()
    
    private lazy var filterAttribute: JCFIlterConfigViewController = {
        let vc = JCFIlterConfigViewController()
        addChild(vc)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.needUpdateFilter = {[weak self] in
            self?.updateFilter()
        }
        return vc
    }()
    
    var currentFilter: CIFilter? {
        didSet {
            filterAttribute.currentFilter = currentFilter
            updateFilter()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        JCCICustomFilter.registFilter()
        
        view.addSubview(filterList.view)
        NSLayoutConstraint.activate([
            filterList.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterList.view.topAnchor.constraint(equalTo: view.topAnchor),
            filterList.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            filterList.view.widthAnchor.constraint(equalToConstant: 210),
            ])
        
        view.addSubview(filterAttribute.view)
        NSLayoutConstraint.activate([
            filterAttribute.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterAttribute.view.topAnchor.constraint(equalTo: view.topAnchor),
            filterAttribute.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            filterAttribute.view.widthAnchor.constraint(equalToConstant: 300),
            ])
        
        view.addSubview(ciImageView)
        NSLayoutConstraint.activate([
            ciImageView.topAnchor.constraint(equalTo: view.topAnchor),
            ciImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ciImageView.leadingAnchor.constraint(equalTo: filterList.view.trailingAnchor),
            ciImageView.trailingAnchor.constraint(equalTo: filterAttribute.view.leadingAnchor),
            ])
        
        ciImageView.image = background0
        ciImageView.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(click(_:))))
    }
    
    private let background0: CIImage = {
        let url = Bundle.main.url(forResource: "background0", withExtension: "png")!
        return CIImage(contentsOf: url)!
    }()
    
    private let background1: CIImage = {
        let url = Bundle.main.url(forResource: "background1", withExtension: "png")!
        return CIImage(contentsOf: url)!
    }()
    
    private let avatar: CIImage = {
        let url = Bundle.main.url(forResource: "luoxiaohei", withExtension: "png")!
        return CIImage(contentsOf: url)!
    }()
    
    func updateFilter() {
        if currentFilter?.attributes[kCIInputImageKey] != nil {
            if currentFilter?.attributes[kCIInputBackgroundImageKey] != nil {
                currentFilter?.setValue(background0, forKey: kCIInputBackgroundImageKey)
                currentFilter?.setValue(avatar, forKey: kCIInputImageKey)
            }
            else if currentFilter?.attributes[kCIInputTargetImageKey] != nil {
                currentFilter?.setValue(background0, forKey: kCIInputImageKey)
                currentFilter?.setValue(background1, forKey: kCIInputTargetImageKey)
            }
            else {
                currentFilter?.setValue(background0, forKey: kCIInputImageKey)
            }
        }
        if currentFilter?.name == JCCILensFlareGenerator.className() {
            currentFilter?.setValue(CIVector(cgRect: background0.extent), forKey: kCIInputExtentKey)
        }
        ciImageView.image = currentFilter?.outputImage?.cropped(to: background0.extent)
    }

    @IBAction func click(_ c: NSClickGestureRecognizer) {
        guard currentFilter?.attributes[kCIInputCenterKey] != nil else {
            return
        }
        let location = c.location(in: ciImageView)
        let radio = background0.extent.width / ciImageView.bounds.width
        let height = background0.extent.height / radio
        let y = (ciImageView.bounds.height - height) / 2
        let currentRect = CGRect(x: 0, y: y, width: ciImageView.bounds.width, height: height)
        currentFilter?.setValue(CIVector(x: location.x * radio, y: (location.y - currentRect.minY) * radio), forKey: kCIInputCenterKey)
        updateFilter()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
}

