//
//  JCFilterListViewController.swift
//  CoreImage-MetalLibrary
//
//  Created by Jake on 2018/12/24.
//  Copyright © 2018 Jake. All rights reserved.
//

import Cocoa

class JCFilterListViewController: NSViewController {
    
    private lazy var filterList: [String] = {
        return CIFilter.filterNames(inCategory: nil)
    }()
    
    private lazy var filterListView: NSScrollView = {
        let list = NSTableView(frame: .zero)
        list.delegate = self
        list.dataSource = self
        list.translatesAutoresizingMaskIntoConstraints = false
        
        let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "col0"))
        col.title = "Filters"
        col.width = 200
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
        view.addSubview(filterListView)
        NSLayoutConstraint.activate([
            filterListView.topAnchor.constraint(equalTo: view.topAnchor),
            filterListView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            filterListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
    }
    
    var didSelectFilter: ((_ filterName: String) -> ())?
    
}

extension JCFilterListViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
    }
    
    func tableView(_ tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
        if let index = proposedSelectionIndexes.first {
            let filterName = filterList[index]
            didSelectFilter?(filterName)
        }
        return proposedSelectionIndexes
    }
    
    
}

extension JCFilterListViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return filterList.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return filterList[row].replacingOccurrences(of: "CoreImage_MetalLibrary.", with: "")
    }
}


