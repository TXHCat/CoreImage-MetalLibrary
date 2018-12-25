//
//  JCFIlterConfigViewController.swift
//  CoreImage-MetalLibrary
//
//  Created by Jake on 2018/12/24.
//  Copyright © 2018 Jake. All rights reserved.
//

import Cocoa

struct JCFilterAttributes {
    
    struct Atrribute {
        let name: String
        let defaultValue: Double
        let minValue: Double
        let maxValue: Double
        let des: String
        var value: Double
    }
    
    var attributeGroup: [Atrribute]
    let name: String
    
    init(_ filter: CIFilter) {
        name = filter.attributes[kCIAttributeDisplayName] as? String ?? ""
        var group = [Atrribute]()
        for (key, obj) in filter.attributes {
            guard let obj = obj as? [String : Any] else {
                continue
            }
            let defaultValue = obj[kCIAttributeDefault] as? NSNumber ?? 0
            let minValue = obj[kCIAttributeSliderMin] as? NSNumber ?? (obj[kCIAttributeMin] as? NSNumber ?? 0)
            let maxValue = obj[kCIAttributeSliderMax] as? NSNumber ?? (obj[kCIAttributeMax] as? NSNumber ?? 0)
            let attr = Atrribute(name: key,
                                 defaultValue: defaultValue.doubleValue,
                                 minValue: minValue.doubleValue,
                                 maxValue: maxValue.doubleValue,
                                 des: obj.description,
                                 value: defaultValue.doubleValue)
            group.append(attr)
        }
        attributeGroup = group
    }
}

class JCFilterAttributeCell: NSView {
    private let slider = NSSlider()
    private let titleLabel = NSTextField()
    private let desLabel = NSTextField()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            ])

        addSubview(slider)
        slider.target = self
        slider.action = #selector(sliderAction)
        slider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            slider.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            slider.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 0),
            slider.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 0),
            ])


    }
    
    var attribute: JCFilterAttributes.Atrribute? {
        didSet {
            guard let attr = attribute else {
                return
            }
            titleLabel.placeholderString = attr.name
            if attr.maxValue == attr.minValue {
                slider.isHidden = true
            }
            else {
                slider.isHidden = false
                slider.maxValue = (attr.maxValue)
                slider.minValue = (attr.minValue)
                slider.doubleValue = (attr.defaultValue)
            }
        }
    }
    
    var sliderValueChange: ((_ value: Double,_ attribute: JCFilterAttributes.Atrribute?) -> ())?
    
    @IBAction func sliderAction(_ sender: NSSlider) {
        sliderValueChange?(sender.doubleValue, attribute)
    }
    
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class JCFIlterConfigViewController: NSViewController {
    
    var currentFilter: CIFilter? {
        didSet {
            guard let filter = currentFilter else {
                return
            }
            filterAttributes = JCFilterAttributes(filter)
            reload()
        }
    }
    
    var needUpdateFilter: (() -> ())?
    
    private var filterAttributes: JCFilterAttributes?
    
    private let titleLabel = NSTextField()
    
    private var tableView: NSTableView?
    private lazy var tableContainer: NSScrollView = {
        let list = NSTableView(frame: .zero)
        list.delegate = self
        list.dataSource = self
        list.translatesAutoresizingMaskIntoConstraints = false
        self.tableView = list
        
        let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "col0"))
        col.title = "Attributes"
        col.width = 280
        col.isEditable = false
        list.addTableColumn(col)
        
        let container = NSScrollView(frame: .zero)
        container.documentView = list
        container.hasHorizontalScroller = true
        container.translatesAutoresizingMaskIntoConstraints = false
        
        return container
    }()

    override func loadView() {
        view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableContainer)
        NSLayoutConstraint.activate([
            tableContainer.topAnchor.constraint(equalTo: view.topAnchor),
            tableContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
    }
    
    private func reload() {
        guard let attributes = filterAttributes else {
            return
        }
        titleLabel.placeholderString = attributes.name
        tableView?.reloadData()
    }
}

extension JCFIlterConfigViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let filterAttribute = filterAttributes else {
            return nil
        }
        let attribute = filterAttribute.attributeGroup[row]
        let cell = JCFilterAttributeCell(frame: .init(x: 0, y: 0, width: 300, height: 60))
        cell.attribute = attribute
        cell.sliderValueChange = { [weak self] (value, attr) in
            guard let attr = attr else {
                return
            }
            self?.currentFilter?.setValue(value, forKey: attr.name)
            self?.needUpdateFilter?()
        }
        return cell
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
        if let index = proposedSelectionIndexes.first, let attr = filterAttributes {
            dump(attr.attributeGroup[index])
        }
        return proposedSelectionIndexes
    }
}

extension JCFIlterConfigViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard let filterAttribute = filterAttributes else {
            return 0
        }
        return filterAttribute.attributeGroup.count
    }
}
