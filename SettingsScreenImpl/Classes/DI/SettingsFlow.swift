//
//  SettingsFlow.swift
//  Nimble
//
//  Created by Mor on 14/07/2022.
//

import Foundation
import Combine
import Swinject

public enum SettingsDelegate {
    case logout
}

public class SettingsFlow {
    
    public init(container: Container) {
        DIContainer.shared.registerContainer(container: container)
    }
    
    public func launch(in navController: UINavigationController) {
        let vc = SettingsViewController.instantiate()
        navController.pushViewController(vc, animated: true)
    }
    
}
