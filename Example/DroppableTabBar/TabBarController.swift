//
//  ViewController.swift
//  DroppableTabBar
//
//  Created by hyukhur on 10/11/2017.
//  Copyright (c) 2017 hyukhur. All rights reserved.
//

import UIKit
import MobileCoreServices
import DroppableTabBar

extension Array where Element == Array<String> {

    func canHandle(_ session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }

    func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
        guard let placeName = self[safe: indexPath.section]?[safe: indexPath.row] else {
            return []
        }

        let data = placeName.data(using: .utf8)
        let itemProvider = NSItemProvider()

        itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePlainText as String, visibility: .all) { completion in
            completion(data, nil)
            return nil
        }

        return [
            UIDragItem(itemProvider: itemProvider)
        ]
    }

    mutating func addItem(item: String, at indexPath: IndexPath) {
        var sectionArray = self[safe: indexPath.section] ?? [String]()
        if indexPath.row > sectionArray.count {
            sectionArray.append(item)
        } else {
            sectionArray.insert(item, at: indexPath.row)
        }
        self[safe: indexPath.section] = sectionArray
    }

    mutating func swapAt(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section == destinationIndexPath.section {
            var sourceSection = self[safe: sourceIndexPath.section] ?? [String]()
            guard let sourceItem = sourceSection[safe: sourceIndexPath.row] else { return }
            sourceSection.insert(sourceItem, at: destinationIndexPath.row)
            sourceSection.remove(at: sourceIndexPath.row)
            self[safe: sourceIndexPath.section] = sourceSection
            return
        }

        var sourceSection = self[safe: sourceIndexPath.section] ?? [String]()
        var destinationSection = self[safe: destinationIndexPath.section] ?? [String]()

        guard let sourceItem = sourceSection[safe: sourceIndexPath.row] else { return }

        destinationSection.insert(sourceItem, at: destinationIndexPath.row)
        sourceSection.remove(at: sourceIndexPath.row)

        self[safe: sourceIndexPath.section] = sourceSection
        self[safe: destinationIndexPath.section] = destinationSection
    }
}

class TabBarController: DroppableTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
