//
//  Item3TableViewController.swift
//  DroppableTabBar_Example
//
//  Created by hyukhur on 11/10/2017.
//  Copyright © 2017 hyukhur. All rights reserved.
//

import UIKit
import MobileCoreServices

class Item3TableViewController: UITableViewController {

    var items = [
        [
            "3_section1_item1",
            "3_section1_item2",
            "3_section1_item3",
            ],
        [
            "3_section2_item1",
            "3_section2_item2",
            "3_section2_item3",
            ],
        [
            "3_section3_item1",
            "3_section3_item2",
            "3_section3_item3",
            ],
        ]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.dragInteractionEnabled = true
        tableView?.dragDelegate = self
        tableView?.dropDelegate = self

        clearsSelectionOnViewWillAppear = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath)
        let title = items[indexPath.section][indexPath.row]
        cell.textLabel?.text = title
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        items.swapAt(at: sourceIndexPath, to: destinationIndexPath)
    }
}

extension Item3TableViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let title = items[indexPath.section][indexPath.row]

        let data = title.data(using: .utf8)
        let itemProvider = NSItemProvider()

        itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePlainText as String, visibility: .all) { completion in
            completion(data, nil)
            return nil
        }

        return [
            UIDragItem(itemProvider: itemProvider)
        ]
    }
}

extension Item3TableViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return items.canHandle(session)
    }

    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if tableView.hasActiveDrag {
            if session.items.count > 1 {
                return UITableViewDropProposal(operation: .cancel)
            } else {
                return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
        } else {
            return UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath

        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }

        coordinator.session.loadObjects(ofClass: NSString.self) { items in
            let stringItems = items as! [String]

            var indexPaths = [IndexPath]()
            for (index, item) in stringItems.enumerated() {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                self.items.addItem(item: item, at: indexPath)
                indexPaths.append(indexPath)
            }

            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}
