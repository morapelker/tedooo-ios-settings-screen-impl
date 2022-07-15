//
//  ChangePasswordViewController.swift
//  SettingsScreenImpl
//
//  Created by Mor on 14/07/2022.
//

import Foundation
import UIKit
import TedoooStyling
import TedoooCombine
import Combine

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet weak var lblNewPasswordError: UILabel!
    @IBOutlet weak var lblRetypePasswordError: UILabel!
    @IBOutlet weak var lblCurrentPasswordError: UILabel!
    
    @IBOutlet weak var txtCurrentPassword: UITextField!
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtRetypePassword: UITextField!
    
    @IBOutlet weak var btnChange: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private let viewModel = ChangePasswordViewModel()
    
    private var bag = CombineBag()
    
    static func instantiate() -> UIViewController {
        return GPHelper.instantiateViewController(type: ChangePasswordViewController.self)
    }
    
    @IBAction func submit() {
        viewModel.submit()
    }
    
    @IBAction func backClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        Styling.styleJoyButton(view: btnChange)
        
        subscribe()
    }
    
    private func subscribe() {
        txtNewPassword <~> viewModel.newPassword => bag
        txtCurrentPassword <~> viewModel.currentPassword => bag
        txtRetypePassword <~> viewModel.retypePassword => bag
        
        viewModel.passwordChanged.sink { [weak self] _ in
            guard let self = self else { return }
            let alert = UIAlertController(title: NSLocalizedString("Change Password", comment: ""), message: NSLocalizedString("Password changed successfully", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default))
            self.present(alert, animated: true)
        } => bag
        
        viewModel.currentPasswordError.sink { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.lblCurrentPasswordError.text = error
                self.lblCurrentPasswordError.isHidden = false
            } else {
                self.lblCurrentPasswordError.isHidden = true
            }
        } => bag
        
        viewModel.newPasswordError.sink { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.lblNewPasswordError.text = error
                self.lblNewPasswordError.isHidden = false
            } else {
                self.lblNewPasswordError.isHidden = true
            }
        } => bag
        
        viewModel.retypePasswordError.sink { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.lblRetypePasswordError.text = error
                self.lblRetypePasswordError.isHidden = false
            } else {
                self.lblRetypePasswordError.isHidden = true
            }
        } => bag
        
        viewModel.loading.sink { [weak self] loading in
            guard let self = self else { return }
            if loading {
                self.btnChange.setTitle(" ", for: .normal)
                self.btnChange.isEnabled = false
                self.spinner.startAnimating()
            } else {
                self.btnChange.isEnabled = true
                self.btnChange.setTitle(NSLocalizedString("Change password", comment: ""), for: .normal)
                self.spinner.stopAnimating()
            }
            
        } => bag
    }
    
}
