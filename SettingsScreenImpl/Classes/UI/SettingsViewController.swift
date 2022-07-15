//
//  SettingsViewController.swift
//  Nimble
//
//  Created by Mor on 14/07/2022.
//

import Foundation
import UIKit
import Combine
import Kingfisher
import LoginProviderApi
import TedoooCombine
import SettingsLegacyScreens

class SettingsViewController: UIViewController {
    
    enum BigSettingItem {
        case notificationSettings
        case accountSettings
        case blockedUsers
        case howToUse
        case inviteFriends
        case contactUs
        case changePassword
    }
    
    enum SmallSettingItem {
        case privacy
        case eula
        case signOut
    }
    
    enum SettingRow {
        case header
        case bigItem(_ settingItem: BigSettingItem)
        case smallItem(_ settingItem: SmallSettingItem)
        case spacer
    }
    
    @Inject private var loginProvider: LoginProvider
    @Inject private var legacyScreens: SettingsLegacyScreens
    
    private var subject: PassthroughSubject<SettingsDelegate, Never>?
    
    static func instantiate(_ delegate: PassthroughSubject<SettingsDelegate, Never>) -> UIViewController {
        let vc = GPHelper.instantiateViewController(type: SettingsViewController.self)
        vc.subject = delegate
        return vc
    }

    private var items: [SettingRow] = [
        .header,
        .bigItem(.notificationSettings),
        .bigItem(.accountSettings),
        .bigItem(.changePassword),
        .bigItem(.blockedUsers),
        .bigItem(.howToUse),
        .bigItem(.inviteFriends),
        .bigItem(.contactUs),
        .spacer,
        .smallItem(.privacy),
        .smallItem(.eula),
        .smallItem(.signOut)
    ]
    
    @IBAction func backClicked() {
        navigationController?.popViewController(animated: true)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch items[indexPath.row] {
        case .header:
            return 70
        case .smallItem:
            return 30
        case .spacer:
            return 30
        case .bigItem:
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let navController = navigationController else { return }
        switch items[indexPath.row] {
        case .bigItem(let item):
            switch item {
            case .notificationSettings:
                navController.pushViewController(NotificationSettingsViewController.instantiate(), animated: true)
            case .contactUs:
                legacyScreens.launchContactUs(in: navController)
            case .inviteFriends:
                legacyScreens.launchInvite(in: navController)
            case .howToUse:
                legacyScreens.launchHowToUse(in: navController)
            case .accountSettings:
                navController.pushViewController(AccountSettingsViewController.instantiate(subject: self.subject), animated: true)
            case .blockedUsers:
                legacyScreens.launchBlockedUsers(in: navController)
            case .changePassword:
                navController.pushViewController(ChangePasswordViewController.instantiate(), animated: true)
            }
        case .smallItem(let item):
            switch item {
            case .privacy:
                legacyScreens.launchPrivacyPolicy()
            case .eula:
                legacyScreens.launchEula()
            case .signOut:
                let alert = UIAlertController(title: NSLocalizedString("Sign out", comment: ""), message: NSLocalizedString("Are you sure you want to sign out?", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Sign out", comment: ""), style: .destructive, handler: { _ in
                    if let subject = self.subject {
                        subject.send(.logout)
                        subject.send(completion: .finished)
                    }
                    self.navigationController?.popViewController(animated: true)
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
                self.present(alert, animated: true)
            }
        case .header, .spacer: break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch items[indexPath.row] {
        case .spacer:
            return tableView.dequeueReusableCell(withIdentifier: "SpacerCell", for: indexPath)
        case .header:
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! SettingHeaderCell
            cell.selectionStyle = .none
            loginProvider.loggedInUserSubject.receive(on: DispatchQueue.main).sink { [weak cell] user in
                guard let cell = cell else { return }
                if let user = user {
                    if let url = user.avatar, let url = URL(string: url) {
                        cell.imgAvatar.kf.setImage(with: url)
                    } else {
                        cell.imgAvatar.image = UIImage(named: "profile_placeholder")
                    }
                    cell.lblName.text = user.name
                } else {
                    cell.lblName.text = ""
                    cell.imgAvatar.image = nil
                }
            } => cell.bag
            
            return cell
        case .bigItem(let settingItem):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingItemCell", for: indexPath) as! SettingItemCell
            cell.selectionStyle = .none
            switch settingItem {
            case .notificationSettings:
                cell.lblSettingText.text = NSLocalizedString("Notification settings", comment: "")
            case .accountSettings:
                cell.lblSettingText.text = NSLocalizedString("Account settings", comment: "")
            case .blockedUsers:
                cell.lblSettingText.text = NSLocalizedString("Blocked users", comment: "")
            case .howToUse:
                cell.lblSettingText.text = NSLocalizedString("How to use", comment: "")
            case .inviteFriends:
                cell.lblSettingText.text = NSLocalizedString("Invite friends", comment: "")
            case .contactUs:
                cell.lblSettingText.text = NSLocalizedString("Contact us", comment: "")
            case .changePassword:
                cell.lblSettingText.text = NSLocalizedString("Change Password", comment: "")
            }
          
            return cell
        case .smallItem(let settingItem):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SmallSettingsItemCell", for: indexPath) as! SettingItemCell
            cell.selectionStyle = .none
            switch settingItem {
            case .privacy:
                cell.lblSettingText.text = NSLocalizedString("Privacy policy", comment: "")
            case .eula:
                cell.lblSettingText.text = NSLocalizedString("End user license agreement", comment: "")
            case .signOut:
                cell.lblSettingText.text = NSLocalizedString("Sign out", comment: "")
            }
            return cell
        }
    }
    
    
}
