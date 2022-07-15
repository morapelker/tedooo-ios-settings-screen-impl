//
//  GPHelper.swift
//  Pods
//
//  Created by Mor on 14/07/2022.
//

import Foundation

class GPHelper {
    
    static func instantiateViewController<T: UIViewController>(type: T.Type) -> T {
        return UIStoryboard(name: "Main", bundle: Bundle(for: SettingsViewController.self)).instantiateViewController(withIdentifier: String(describing: type)) as! T
    }
    
    static func displayActionSheet(alert: UIAlertController, presentor: UIViewController) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = alert.popoverPresentationController {
                alert.modalPresentationStyle = .popover
                popoverController.sourceView = presentor.view //to set the source of your alert
                popoverController.sourceRect = CGRect(x: presentor.view.bounds.midX, y: presentor.view.bounds.midY, width: 0, height: 0) // you can set this as per your requirement.
                popoverController.permittedArrowDirections = [] //to hide the arrow of any particular direction
                presentor.present(alert, animated: true, completion: nil)
            }
        } else {
            presentor.present(alert, animated: true, completion: nil)
        }
    }
    
}
