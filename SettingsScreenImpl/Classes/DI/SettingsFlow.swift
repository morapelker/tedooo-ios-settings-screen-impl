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
    
    public func launch(in navController: UINavigationController) -> AnyPublisher<SettingsDelegate, Never> {
        let subject = PassthroughSubject<SettingsDelegate, Never>()
        let vc = SettingsViewController.instantiate(subject)
        navController.pushViewController(vc, animated: true)
        return subject.eraseToAnyPublisher()
    }
    
}
