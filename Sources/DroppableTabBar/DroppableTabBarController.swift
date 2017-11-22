//
//  DroppableTabBarController.swift
//  DroppableTabBar
//
//  Created by hyukhur on 11/10/2017.
//

import UIKit
import ObjectiveC

public protocol DroppableTabBarControllerDelegate: class, NSObjectProtocol {
    func droppableTabBarController(_ tabBarController: UITabBarController, shouldDrop item: UIBarButtonItem) -> Bool
    func droppableTabBarController(_ tabBarController: UITabBarController, didDrop item: UIBarButtonItem)

    var dropInteractionDelegate: UIDropInteractionDelegate? { get }
    func droppableTabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool
    func droppableTabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController)
}

public protocol DroppableTabBarControl: UIDropInteractionDelegate {
    weak var droppableDelegate: DroppableTabBarControllerDelegate? { get set }
    func dropInteractions() -> [UIDropInteraction]
    func setDropInteractions(dropInteractions: [UIDropInteraction])
    func addDropInteractions()
}

private var DroppableTabBarControl_DroppableDelegate_AssociatedKey: UInt8 = 0
private var DroppableTabBarControl_DropInteractions_AssociatedKey: UInt8 = 0

extension DroppableTabBarControl where Self: UITabBarController {
    public weak var droppableDelegate: DroppableTabBarControllerDelegate? {
        set {
            objc_setAssociatedObject(self, &DroppableTabBarControl_DroppableDelegate_AssociatedKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, &DroppableTabBarControl_DroppableDelegate_AssociatedKey) as? DroppableTabBarControllerDelegate
        }
    }

    public func dropInteractions() -> [UIDropInteraction] {
        guard let result = objc_getAssociatedObject(self, &DroppableTabBarControl_DropInteractions_AssociatedKey) as? [UIDropInteraction] else { return [] }
        return result
    }

    public func setDropInteractions(dropInteractions newValue: [UIDropInteraction]) {
        objc_setAssociatedObject(self, &DroppableTabBarControl_DropInteractions_AssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    public func addDropInteractions() {
        var interactions: [UIDropInteraction] = []
        tabBar.subviews.forEach {
            // TODO: Check a duplicated drop interaction
            let dropInteraction = UIDropInteraction(delegate: self)
            $0.addInteraction(dropInteraction)
            interactions.append(dropInteraction)
        }
        setDropInteractions(dropInteractions: interactions)
    }

    public func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        guard let delegate = droppableDelegate else { return false }
        guard let index = self.dropInteractions().index(of: interaction), index != selectedIndex, let item = toolbarItems?[index] else { return false }
        guard delegate.droppableTabBarController(self, shouldDrop: item) == false else {
            return true
        }
        guard let vc = viewControllers?[index] else { return false }
        guard delegate.droppableTabBarController(self, shouldSelect: vc) else { return false }
        self.selectedIndex = index
        droppableDelegate?.droppableTabBarController(self, didSelect: vc)
        return false
    }

    public func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnter session: UIDropSession) {
        guard let delegate = droppableDelegate?.dropInteractionDelegate else { return  }
        delegate.dropInteraction?(interaction, sessionDidEnter: session)
    }

    public func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        guard let delegate = droppableDelegate?.dropInteractionDelegate else { return UIDropProposal(operation: UIDropOperation.forbidden) }
        return delegate.dropInteraction?(interaction, sessionDidUpdate: session) ?? UIDropProposal(operation: UIDropOperation.forbidden)
    }

    public func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession) {
        guard let delegate = droppableDelegate?.dropInteractionDelegate else { return }
        delegate.dropInteraction?(interaction, sessionDidExit: session)
    }

    public func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        guard let delegate = droppableDelegate?.dropInteractionDelegate else { return }
        delegate.dropInteraction?(interaction, performDrop: session)
    }

    public func dropInteraction(_ interaction: UIDropInteraction, concludeDrop session: UIDropSession) {
        guard let delegate = droppableDelegate?.dropInteractionDelegate else { return }
        delegate.dropInteraction?(interaction, concludeDrop: session)
    }

    public func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnd session: UIDropSession) {
        guard let delegate = droppableDelegate?.dropInteractionDelegate else { return }
        delegate.dropInteraction?(interaction, sessionDidEnd: session)
    }

    public func dropInteraction(_ interaction: UIDropInteraction, previewForDropping item: UIDragItem, withDefault defaultPreview: UITargetedDragPreview) -> UITargetedDragPreview? {
        guard let delegate = droppableDelegate?.dropInteractionDelegate else { return nil }
        return delegate.dropInteraction?(interaction, previewForDropping: item, withDefault: defaultPreview)
    }
}

open class DroppableTabBarController: UITabBarController, DroppableTabBarControl {
    override open func viewDidLoad() {
        super.viewDidLoad()
        addDropInteractions()
    }
}

extension DroppableTabBarController: UIDropInteractionDelegate {
    public func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        guard let index = self.dropInteractions().index(of: interaction) else {
            return false
        }
        guard index != selectedIndex else {
            return false
        }
        if let item = toolbarItems?[index], let result = droppableDelegate?.droppableTabBarController(self, shouldDrop: item), result {
            return true
        }
        guard let vc = viewControllers?[index] else {
            return false
        }
        if let result = droppableDelegate?.droppableTabBarController(self, shouldSelect: vc), result {
            return false
        }
        selectedIndex = index
        droppableDelegate?.droppableTabBarController(self, didSelect: vc)
        return false
    }
}
