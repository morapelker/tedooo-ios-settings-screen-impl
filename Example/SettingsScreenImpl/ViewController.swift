//
//  ViewController.swift
//  SettingsScreenImpl
//
//  Created by morapelker on 07/14/2022.
//  Copyright (c) 2022 morapelker. All rights reserved.
//

import UIKit
import SettingsScreenImpl
import Swinject
import SettingsApi
import TedoooCombine
import Combine
import LoginProviderApi
import SettingsLegacyScreens
import TedoooImagePicker
import TedoooRestApi

class Implementor: LoginProvider, SettingsApi, SettingsLegacyScreens, TedoooImagePicker, AwsClient {
    func launchChangeLanguage(in navController: UINavigationController) -> AnyPublisher<Any?, Error> {
        print("launch change language")
        return Just(nil).delay(for: 0.5, scheduler: DispatchQueue.main).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
   
    func login(with newPassword: String) {
        print("login with new password", newPassword)
    }
    
    func launchEula() {
        print("launch eula")
    }
    
    func updateAvatar(avatar: String?) -> AnyPublisher<Any?, Error> {
        print("update avatar", avatar)
        return Just(nil).delay(for: 0.5, scheduler: DispatchQueue.main).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func updateEmail(toEmail: String) -> AnyPublisher<Any?, Error> {
        print("update email", toEmail)
        return Just(nil).delay(for: 0.5, scheduler: DispatchQueue.main).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    
    func uploadImage(request: UploadImageRequest) -> AnyPublisher<UploadImageResponse, Never> {
        return Just(
            UploadImageResponse(
                id: request.id, result:
                    UploadImageResult.success("https://i.pravatar.cc/100?a=\(UUID().uuidString)"))
        ).delay(for: 1.0, scheduler: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    func pickImages(from: UIViewController, single: Bool, withCamera: Bool, edit: Bool) -> AnyPublisher<[UIImage], Never> {
        return Just([UIImage(systemName: "xmark")!]).eraseToAnyPublisher()
    }
    
    func editImage(from: UIViewController, image: UIImage) -> AnyPublisher<UIImage, Never> {
        return Just(UIImage(systemName: "square")!).eraseToAnyPublisher()
    }
    
    func fetchAccountSettings() -> AnyPublisher<AccountSettings, Error> {
        return Just(AccountSettings(lastSeen: true, localTime: false, liveTranslations: true, language: "en", email: "morapelker@gmail.com")).delay(for: 0.5, scheduler: DispatchQueue.main).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func updateUser(loggedInUser: LoggedInUser) {
        loggedInUserSubject.value = loggedInUser
        print("updataeUser", loggedInUser)
    }
    
    
    func updateAccessToken(newToken: String) {
        if let current = loggedInUserSubject.value {
            loggedInUserSubject.value = LoggedInUser(id: current.id, name: current.name, avatar: current.avatar, token: newToken, thirdParty: .facebook)
        }
        print("update access token to ", newToken)
    }
    
    func updatePassword(oldPassword: String, newPassword: String) -> AnyPublisher<Any?, NSError> {
        print("update password", oldPassword, newPassword)
        return Fail(error: NSError(domain: "Invalid password", code: 1)).delay(for: 0.5, scheduler: DispatchQueue.main).eraseToAnyPublisher()
//        return Just(nil).delay(for: 1.0, scheduler: DispatchQueue.main).setFailureType(to: NSError.self).eraseToAnyPublisher()
    }
    
    func launchBlockedUsers(in navController: UINavigationController) {
        print("launch blocked users in", navController)
    }
    
    func launchHowToUse(in navController: UINavigationController) {
        print("launch how to use in", navController)
    }
    
    func launchInvite(in navController: UINavigationController) {
        print("launch invite friends in", navController)
    }
    
    func launchContactUs(in navController: UINavigationController) {
        print("launch contact us in", navController)
    }
    
    func launchPrivacyPolicy() {
        print("launch privacy policy in")
    }
    
    
    static let shared = Implementor()
    
    var subUntilSubject: CurrentValueSubject<Int64, Never> = CurrentValueSubject(0)
    var loggedInUserSubject: CurrentValueSubject<LoggedInUser?, Never> = CurrentValueSubject(LoggedInUser(id: "id", name: "morapelker", avatar: nil, token: "token", thirdParty: .tedooo))
    
    func deleteAccount() -> AnyPublisher<DeleteAccountResult?, Never> {
        return Just(DeleteAccountResult(didDelete: false)).delay(for: 0.5, scheduler: DispatchQueue.main).eraseToAnyPublisher()
//        return Just(DeleteAccountResult(didDelete: true)).delay(for: 1.0, scheduler: DispatchQueue.main).eraseToAnyPublisher()
//        return
    }
    
    func fetchNotificationSettings() -> AnyPublisher<NotificationSettings, Error> {
        return Just(NotificationSettings(postNotifications: false)).delay(for: 0.5, scheduler: DispatchQueue.main).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func updateSettingItem(item: SettingItem, newValue: Bool) -> AnyPublisher<Any?, Error> {
        print("update settings item", item, newValue)
//        return Fail(error: NSError(domain: "", code: 1)).delay(for: 1.0, scheduler: DispatchQueue.main).eraseToAnyPublisher()
        return Just(nil).delay(for: 0.5, scheduler: DispatchQueue.main).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    
    
}

class ViewController: UIViewController {

    private let container = Container()
    private var bag = CombineBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        container.register(LoginProvider.self) { _ in
            return Implementor.shared
        }.inObjectScope(.container)
        container.register(SettingsApi.self) { _ in
            return Implementor.shared
        }.inObjectScope(.container)
        container.register(SettingsLegacyScreens.self) { _ in
            return Implementor.shared
        }.inObjectScope(.container)
        container.register(TedoooImagePicker.self) { _ in
            return Implementor.shared
        }.inObjectScope(.container)
        container.register(AwsClient.self) { _ in
            return Implementor.shared
        }.inObjectScope(.container)
    }

    @IBAction func startFlow(_ sender: Any) {
        SettingsFlow(container: container).launch(in: navigationController!).sink { [weak self] delegate in
            print("execute logout")
        } => bag
    }
    
}

