//
//  ViewController.swift
//  DroppableTabBar
//
//  Created by hyukhur on 10/11/2017.
//  Copyright (c) 2017 hyukhur. All rights reserved.
//

import UIKit
import MobileCoreServices

extension Array where Element == Array<String> {

    func canHandle(_ session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }

    func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
        let placeName = self[indexPath.section][indexPath.row]

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

    func addItem(item: String, at indexPath: IndexPath) {
        var sectionArray = self[safe: indexPath.section] ?? [String]()
        sectionArray[indexPath.row] = item
    }

    mutating func swapAt(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section == destinationIndexPath.section {
            var sourceSection = self[safe: sourceIndexPath.section] ?? [String]()
            guard let sourceItem = sourceSection[safe: sourceIndexPath.row] else { return }
            sourceSection.insert(sourceItem, at: destinationIndexPath.row)
            sourceSection.remove(at: sourceIndexPath.row)
            self[sourceIndexPath.section] = sourceSection
            return
        }

        var sourceSection = self[safe: sourceIndexPath.section] ?? [String]()
        var destinationSection = self[safe: destinationIndexPath.section] ?? [String]()

        guard let sourceItem = sourceSection[safe: sourceIndexPath.row] else { return }

        destinationSection.insert(sourceItem, at: destinationIndexPath.row)
        sourceSection.remove(at: sourceIndexPath.row)

        self[sourceIndexPath.section] = sourceSection
        self[destinationIndexPath.section] = destinationSection
    }
}

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
