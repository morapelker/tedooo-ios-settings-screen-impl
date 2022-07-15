//
//  ChangeEmailViewModel.swift
//  SettingsScreenImpl
//
//  Created by Mor on 14/07/2022.
//

import Foundation
import Combine
import SettingsApi
import TedoooCombine

class ChangeEmailViewModel {
    
    let email: CurrentValueSubject<String?, Never>
    let loading = CurrentValueSubject<Bool, Never>(false)
    
    @Inject private var api: SettingsApi
    
    let generalError = PassthroughSubject<String, Never>()
    let delegate: PassthroughSubject<String, Never>

    private var bag = CombineBag()
    
    init(_ baseEmail: String, delegate: PassthroughSubject<String, Never>) {
        email = CurrentValueSubject(baseEmail)
        self.delegate = delegate
    }
 
    func submit() {
        guard let email = email.value else { return }
        loading.value = true
        api.updateEmail(toEmail: email).sink { [weak self] result in
            guard let self = self else { return }
            self.loading.value = false
            switch result {
            case .finished:
                self.delegate.send(email)
                self.delegate.send(completion: .finished)
            case .failure:
                self.generalError.send(NSLocalizedString("Email address could not be updated, please try again later", comment: ""))
            }
        } receiveValue: { _ in
        } => bag

//        print("submit, new email", email.value)
    }
    
}
