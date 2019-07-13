//
//  Scene.swift
//  StarterApp
//
//  Created by Shreyas Bangera on 15/06/19.
//  Copyright © 2019 Shreyas Bangera. All rights reserved.
//

import UIKit

extension UIViewController {
    
    enum Scene {
        case home, welcome, plant//, plantDetail(Plant)
    }
    
    static func controller(_ scene: Scene) -> ViewController {
        switch scene {
        case .home:
            return HomeController()
        case .welcome:
            return WelcomeController()
        case .plant:
            return MarvelCharacterController()
//        case let .plantDetail(plant):
//            return PlantDetailController(plant)
        }
    }
    
    enum Transition {
        case root, push, present, child, popToRootAndPresent, dismissAndPush, overlay
    }
    
    func navigate(to scene: Scene, transition: Transition, delegate: Delegate? = nil) {
        let ctlr = UIViewController.controller(scene).then {
            $0.scene = scene
            $0.delegate = delegate
        }
        switch transition {
        case .root:
            navigationController?.viewControllers = [ctlr]
        case .push:
            navigationController?.pushViewController(ctlr, animated: true)
        case .present:
            present(ctlr, animated: true)
        case .child:
            add(ctlr)
        case .popToRootAndPresent:
            navigationController?.popToRootViewController(animated: false) { [weak self] in
                self?.navigationController?.topViewController?.present(ctlr, animated: true)
            }
        case .dismissAndPush:
            dismiss(animated: true) { [weak self] in
                self?.navigationController?.pushViewController(ctlr, animated: true)
            }
        case .overlay:
            ctlr.modalPresentationStyle = .overCurrentContext
            present(ctlr, animated: true)
        }
    }
    
    func add(_ viewController: UIViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
    
    func remove() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
}
