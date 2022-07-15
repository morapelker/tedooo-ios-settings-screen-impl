//
//  ChangePasswordViewModel.swift
//  SettingsScreenImpl
//
//  Created by Mor on 14/07/2022.
//

import Foundation
import Combine
import SettingsApi
import TedoooCombine
import LoginProviderApi

class ChangePasswordViewModel {
    
    let currentPasswordError = CurrentValueSubject<String?, Never>(nil)
    let newPasswordError = CurrentValueSubject<String?, Never>(nil)
    let retypePasswordError = CurrentValueSubject<String?, Never>(nil)
    
    let currentPassword = CurrentValueSubject<String?, Never>(nil)
    let newPassword = CurrentValueSubject<String?, Never>(nil)
    let retypePassword = CurrentValueSubject<String?, Never>(nil)
    let loading = CurrentValueSubject<Bool, Never>(false)

    let passwordChanged = PassthroughSubject<Bool, Never>()
    let generalError = CurrentValueSubject<String?, Never>(nil)
    
    private var bag = CombineBag()
    
    @Inject private var api: SettingsApi
    @Inject private var loginProvider: LoginProvider
    
    
    init() {
        currentPassword.sink { [weak self] _ in
            self?.currentPasswordError.value = nil
        } => bag
        newPassword.sink { [weak self] _ in
            self?.newPasswordError.value = nil
        } => bag
        retypePassword.sink { [weak self] _ in
            self?.retypePasswordError.value = nil
        } => bag
    }
    
    
    
    func submit() {
        var stop = false
        
        let current = currentPassword.value ?? ""
        if current.isEmpty {
            currentPasswordError.value = NSLocalizedString("Required field", comment: "")
            stop = true
        } else {
            currentPasswordError.value = nil
        }
        let newPassword = self.newPassword.value ?? ""
        if newPassword.count < 5 {
            newPasswordError.value = NSLocalizedString("Password must be at least 5 characters long", comment: "")
            retypePasswordError.value = nil
            stop = true
        } else {
            newPasswordError.value = nil
            let retypePassword = self.retypePassword.value ?? ""
            if retypePassword != newPassword {
                retypePasswordError.value = NSLocalizedString("Passwords do not match", comment: "")
                stop = true
            } else {
                retypePasswordError.value = nil
            }
        }
        
        if stop {
            return
        }
        
        loading.value = true
        currentPasswordError.value = nil
        newPasswordError.value = nil
        retypePasswordError.value = nil
        api.updatePassword(oldPassword: current, newPassword: newPassword).sink { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .finished:
                self.loginProvider.login(with: newPassword)
                self.passwordChanged.send(true)
                self.newPassword.value = nil
                self.retypePassword.value = nil
                self.currentPassword.value = nil
            case .failure(let err):
                if err.code == 1 {
                    self.currentPasswordError.value = NSLocalizedString("Invalid password", comment: "")
                } else {
                    self.generalError.value = NSLocalizedString("Could not change your password, please try again later", comment: "")
                }
            }
        } receiveValue: { _ in
        } => bag

    }
    
}
