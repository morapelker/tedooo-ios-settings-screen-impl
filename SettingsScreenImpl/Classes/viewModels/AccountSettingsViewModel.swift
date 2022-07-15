//
//  AccountSettingsViewModel.swift
//  SettingsScreenImpl
//
//  Created by Mor on 14/07/2022.
//

import Foundation
import Combine
import SettingsApi
import TedoooCombine
import TedoooRestApi
import LoginProviderApi

struct AccountBoolItem {
    let name: String
    let on: CurrentValueSubject<SwitchOnStatus, Never> = CurrentValueSubject(.off)
}

class AccountSettingsViewModel {
        
    enum AccountSettingItem {
        case header
        case bool(_ item: AccountBoolItem)
        case language(_ currentLanguage: CurrentValueSubject<String, Never>)
        case email(_ currentEmail: CurrentValueSubject<String, Never>)
        case spacer
        case contact
        case delete
    }
    
    let loading = CurrentValueSubject<Bool, Never>(false)
    let mainLoading = CurrentValueSubject<Bool, Never>(true)
    private var bag = CombineBag()
    private let api: SettingsApi
    @Inject private var awsClient: AwsClient
    @Inject private var loginProvider: LoginProvider
    
    let errorChanging = PassthroughSubject<String, Never>()
    let errorAndDismiss = PassthroughSubject<String, Never>()
    let loadingAvatar = CurrentValueSubject<UIImage?, Never>(nil)
    let loadingDelete = CurrentValueSubject<Bool, Never>(false)
    let didDeleteAccount = PassthroughSubject<Bool, Never>()
    
    let items: [AccountSettingItem] = [
        .header,
        .bool(.init(name: NSLocalizedString("Show my last seen", comment: ""))),
        .bool(.init(name: NSLocalizedString("Show my local time", comment: ""))),
        .bool(.init(name: NSLocalizedString("Live translation", comment: ""))),
        .language(CurrentValueSubject("")),
        .email(CurrentValueSubject("")),
        .spacer,
        .contact,
        .delete
    ]
    
    func deleteAccount() {
        loadingDelete.value = true
        api.deleteAccount().sink { [weak self] result in
            guard let self = self else { return }
            self.loadingDelete.value = false
            if let result = result {
                self.didDeleteAccount.send(result.didDelete)
            } else {
                self.errorChanging.send(NSLocalizedString("This account could not be deleted. Please contact support to close your account", comment: ""))
            }
        } => bag
    }
    
    func deleteAvatar() {
        guard let currentUser = loginProvider.loggedInUserSubject.value else { return }
        loadingAvatar.value = UIImage(named: "profile_placeholder")
        
        self.api.updateAvatar(avatar: nil).sink { [weak self] result in
            guard let self = self else { return }
            self.loadingAvatar.value = nil
            switch result {
            case .finished:
                self.loginProvider.updateUser(loggedInUser: LoggedInUser(id: currentUser.id, name: currentUser.name, fullName: currentUser.fullName, avatar: nil, token: currentUser.token))
            case .failure:
                self.errorChanging.send(NSLocalizedString("Could not update avatar, please try again later", comment: ""))
            }
        } receiveValue: { _ in
        } => self.bag
    }
    
    func emailUpdated(to email: String) {
        if case AccountSettingItem.email(let emailSubject) = self.items[5] {
            emailSubject.value = email
        }
    }
    
    func uploadAvatar(image: UIImage) {
        guard let currentUser = loginProvider.loggedInUserSubject.value else { return }
        loadingAvatar.value = image
        
        awsClient.uploadImage(request: UploadImageRequest(image: image, token: currentUser.token)).sink { [weak self] response in
            guard let self = self else { return }
            switch response.result {
            case .success(let url):
                self.api.updateAvatar(avatar: url).sink { [weak self] result in
                    guard let self = self else { return }
                    self.loadingAvatar.value = nil
                    switch result {
                    case .finished:
                        self.loginProvider.updateUser(loggedInUser: LoggedInUser(id: currentUser.id, name: currentUser.name, fullName: currentUser.fullName, avatar: url, token: currentUser.token))
                    case .failure:
                        self.errorChanging.send(NSLocalizedString("Could not update avatar, please try again later", comment: ""))
                    }
                } receiveValue: { _ in
                } => self.bag
            case .failure:
                self.loadingAvatar.value = nil
                self.errorChanging.send(NSLocalizedString("Could not update avatar, please try again later", comment: ""))
            case .progress: break
            }
        } => bag
    }
 
    func updateSetting(_ setting: SettingItem, newValue: Bool) {
        let index: Int
        switch setting {
        case .lastSeen:
            index = 1
        case .liveTranslations:
            index = 3
        case .localTime:
            index = 2
        default:
            return
        }
        if case AccountSettingItem.bool(let item) = items[index] {
            item.on.value = newValue ? .on : .off
        } else {
            return
        }
        loading.value = true
        api.updateSettingItem(item: setting, newValue: newValue).sink { [weak self] result in
            guard let self = self else { return }
            self.loading.value = false
            switch result {
            case .finished: break
            case .failure:
                if case AccountSettingItem.bool(let item) = self.items[index] {
                    item.on.value = newValue ? .off : .on
                } else {
                    return
                }
                self.errorChanging.send(NSLocalizedString("Could not change this setting, please try again later", comment: ""))
            }
        } receiveValue: { _ in
        } => bag
    }
    
    init() {
        api = DIContainer.shared.resolve(SettingsApi.self)
        api.fetchAccountSettings().sink { [weak self] result in
            guard let self = self else { return }
            self.mainLoading.value = false
            self.mainLoading.send(completion: .finished)
            switch result {
            case .failure:
                self.errorAndDismiss.send(NSLocalizedString("Please try again later", comment: ""))
            case .finished: break
            }
        } receiveValue: { [weak self] settings in
            guard let self = self else { return }
            if case AccountSettingItem.bool(let item) = self.items[1] {
                item.on.value = settings.lastSeen ? .onInitial : .off
            }
            if case AccountSettingItem.bool(let item) = self.items[2] {
                item.on.value = settings.localTime ? .onInitial : .off
            }
            if case AccountSettingItem.bool(let item) = self.items[3] {
                item.on.value = settings.liveTranslations ? .onInitial : .off
            }
            if case AccountSettingItem.language(let item) = self.items[4] {
                item.value = settings.language
            }
            if case AccountSettingItem.email(let item) = self.items[5] {
                item.value = settings.email
            }
        } => bag
    }
    
}