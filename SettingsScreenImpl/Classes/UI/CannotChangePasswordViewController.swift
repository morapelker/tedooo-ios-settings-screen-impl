//
//  CannotChangePasswordScreen.swift
//  SettingsScreenImpl
//
//  Created by Mor on 16/07/2022.
//

import Foundation
import UIKit
import LoginProviderApi

class CannotChangePasswordViewController: UIViewController {

    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    private var thirdParty: ThirdParty = .tedooo
    
    static func instantiate(thirdParty: ThirdParty) -> UIViewController {
        let vc = GPHelper.instantiateViewController(type: CannotChangePasswordViewController.self)
        vc.thirdParty = thirdParty
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let name: String
        switch thirdParty {
        case .tedooo: return
        case .huawei:
            name = "Huawei"
        case .google:
            name = "Google"
        case .apple:
            name = "Apple"
        case .facebook:
            name = "Facebook"
        }
        lblTitle.text = String(format: NSLocalizedString("You are logged in via %@", comment: ""), name)
        lblDescription.text = String(format: NSLocalizedString("""
Our records indicate that you are logged in via %@  To change your password, visit your Facebook account and change your password there directly
""", comment: ""), name)
    }
    
    @IBAction func backClicked() {
        navigationController?.popViewController(animated: true)
    }
}
