//
//  CannotDeleteAccountViewController.swift
//  SettingsScreenImpl
//
//  Created by Mor on 15/07/2022.
//

import Foundation
import UIKit

class CannotDeleteAccountViewController: UIViewController {
    
    static func instantiate() -> UIViewController {
        return GPHelper.instantiateViewController(type: CannotDeleteAccountViewController.self)
    }
    
    @IBOutlet weak var imgBullet: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgBullet.layer.cornerRadius = 4
    }
    
    @IBAction func backClicked() {
        navigationController?.popViewController(animated: true)
    }
    
}
