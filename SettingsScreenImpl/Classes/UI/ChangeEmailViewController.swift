//
//  ChangeEmailViewController.swift
//  SettingsScreenImpl
//
//  Created by Mor on 14/07/2022.
//

import Foundation
import UIKit
import TedoooCombine
import TedoooStyling
import Combine

class ChangeEmailViewController: UIViewController {
    
    private var viewModel: ChangeEmailViewModel!
    
    static func instantiate(baseEmail: String, delegate: PassthroughSubject<String, Never>) -> UIViewController {
        let vc = GPHelper.instantiateViewController(type: ChangeEmailViewController.self)
        vc.viewModel = ChangeEmailViewModel(baseEmail, delegate: delegate)
        return vc
    }
    
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var txtEmail: UITextField!
    private var bag = CombineBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        Styling.styleJoyButton(view: btnSubmit)
        txtEmail.text = viewModel.email.value
        txtEmail.delegate = self
        
        subscribe()
    }
    
    private func subscribe() {
        txtEmail <~> viewModel.email => bag
        viewModel.generalError.sink { [weak self] err in
            guard let self = self else { return }
            let alert = UIAlertController(title: NSLocalizedString("Error updating email", comment: ""), message: err, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default))
            self.present(alert, animated: true)
        } => bag
        viewModel.delegate.sink { [weak self] result in
            self?.navigationController?.popViewController(animated: true)
        } receiveValue: { _ in
        } => bag
        
        viewModel.loading.sink { [weak self] loading in
            guard let self = self else { return }
            if loading {
                self.btnSubmit.setTitle(" ", for: .normal)
                self.btnSubmit.isEnabled = false
                self.spinner.startAnimating()
            } else {
                self.btnSubmit.isEnabled = true
                self.btnSubmit.setTitle(NSLocalizedString("Update email", comment: ""), for: .normal)
                self.spinner.stopAnimating()
            }
            
        } => bag

    }
    
    @IBAction func submit() {
        viewModel.submit()
    }
    
    @IBAction func backClicked() {
        navigationController?.popViewController(animated: true)
    }
    
}

extension ChangeEmailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
}
