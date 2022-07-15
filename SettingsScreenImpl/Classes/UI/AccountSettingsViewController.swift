//
//  AccountSettingsViewController.swift
//  SettingsScreenImpl
//
//  Created by Mor on 14/07/2022.
//

import Foundation
import UIKit
import LoginProviderApi
import Kingfisher
import TedoooCombine
import TedoooImagePicker
import Combine
import SettingsLegacyScreens
import TedoooFullScreenHud

class AccountSettingsViewController: UIViewController {
    
    @IBOutlet weak var mainSpinner: UIActivityIndicatorView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var table: UITableView!
    
    private let viewModel = AccountSettingsViewModel()
    private let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    private lazy var barButton = UIBarButtonItem(customView: activityIndicator)
    private var bag = CombineBag()
    
    static func instantiate() -> UIViewController {
        return GPHelper.instantiateViewController(type: AccountSettingsViewController.self)
    }
    
    @Inject private var imagePicker: TedoooImagePicker
    @Inject private var loginProvider: LoginProvider
    @Inject private var legacySettings: SettingsLegacyScreens
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        hud.textLabel.text = NSLocalizedString("Closing account...", comment: "")
        subscribe()
    }
    
    @IBAction func backClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    private let hud = FullScreenHud()
    
    private func subscribe() {
        viewModel.didDeleteAccount.sink { [weak self] didDelete in
            guard let self = self else { return }
            if didDelete {
                let alert = UIAlertController(title: NSLocalizedString("Account closed", comment: ""), message: NSLocalizedString("Your account has been closed successfully", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .cancel, handler: { _ in
                    self.navigationController?.popToRootViewController(animated: true)
                }))
                self.present(alert, animated: true)
            } else {
                self.navigationController?.pushViewController(CannotDeleteAccountViewController.instantiate(), animated: true)
            }
        } => bag
        viewModel.loadingDelete.sink { [weak self] loading in
            guard let self = self else { return }
            if loading {
                self.hud.show()
            } else {
                self.hud.dismiss()
            }
            
        } => bag
        viewModel.mainLoading.sink { [weak self] mainSpinner in
            guard let self = self else { return }
            if mainSpinner {
                self.table.isHidden = true
                self.mainSpinner.startAnimating()
            } else {
                self.table.isHidden = false
                self.mainSpinner.stopAnimating()
            }
        } => bag
        viewModel.loading.sink { [weak self] loading in
            guard let self = self else { return }
            self.navItem.setRightBarButton(loading ? self.barButton : nil, animated: false)
        } => bag
        viewModel.errorAndDismiss.sink { [weak self] err in
            let alert = UIAlertController(title: NSLocalizedString("Could not fetch settings", comment: ""), message: err, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: { _ in
                self?.navigationController?.popViewController(animated: true)
            }))
            self?.present(alert, animated: true)
        } => bag
        viewModel.errorChanging.sink { [weak self] err in
            let alert = UIAlertController(title: NSLocalizedString("Could not update setting", comment: ""), message: err, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default))
            self?.present(alert, animated: true)
        } => bag
    }
    
}

extension AccountSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func uploadNewAvatar() {
        self.imagePicker.pickImages(from: self, single: true, withCamera: true, edit: true).sink { [weak self] image in
            if let first = image.first {
                self?.viewModel.uploadAvatar(image: first)
            }
        } => self.bag
    }
    
    @objc private func editAvatar() {
        if loginProvider.loggedInUserSubject.value?.avatar == nil {
            self.uploadNewAvatar()
            return
        }
        let sheet = UIAlertController(title: NSLocalizedString("Edit avatar", comment: ""), message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: NSLocalizedString("Upload new", comment: ""), style: .default, handler: { _ in
            self.uploadNewAvatar()
        }))
        sheet.addAction(UIAlertAction(title: NSLocalizedString("Remove avatar", comment: ""), style: .destructive, handler: { _ in
            self.viewModel.deleteAvatar()
        }))
        sheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        GPHelper.displayActionSheet(alert: sheet, presentor: self)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch viewModel.items[indexPath.row] {
        case .header:
            return 150
        case .spacer:
            return 30
        case .language, .email:
            return 60
        case .bool:
            return 50
        case .contact, .delete:
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    @objc private func mainSwitchValueChanged(sender: UISwitch) {
        self.switchChanged(tag: sender.tag, newValue: sender.isOn)
    }
    
    private func switchChanged(tag: Int, newValue: Bool) {
        switch tag {
        case 1:
            viewModel.updateSetting(.lastSeen, newValue: newValue)
        case 2:
            viewModel.updateSetting(.localTime, newValue: newValue)
        case 3:
            viewModel.updateSetting(.liveTranslations, newValue: newValue)
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1, 2, 3:
            if case AccountSettingsViewModel.AccountSettingItem.bool(let item) = viewModel.items[indexPath.row] {
                let currentValue = item.on.value
                switchChanged(tag: indexPath.row, newValue: currentValue == .off)
            }
        case 4:
            if let navController = navigationController {
                legacySettings.launchChangeLanguage(in: navController)
            }
        case 5:
            if case AccountSettingsViewModel.AccountSettingItem.email(let item) = viewModel.items[5] {
                let subject = PassthroughSubject<String, Never>()
                navigationController?.pushViewController(
                    ChangeEmailViewController.instantiate(baseEmail: item.value, delegate: subject),
                    animated: true)
                subject.sink { [weak self] email in
                    guard let self = self else { return }
                    self.viewModel.emailUpdated(to: email)
                } => bag
            }
        case 7:
            if let navController = navigationController {
                legacySettings.launchContactUs(in: navController)
            }
        case 8:
            let alert = UIAlertController(title: NSLocalizedString("Delete account", comment: ""), message: NSLocalizedString("Are you sure you want to delete your account?", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Delete account", comment: ""), style: .destructive, handler: { _ in
                let alert = UIAlertController(title: NSLocalizedString("Delete account", comment: ""), message: NSLocalizedString("Are you absolutely sure you want to close your account? This operation is irreversible", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Delete account", comment: ""), style: .destructive, handler: { _ in
                    self.viewModel.deleteAccount()
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
                self.present(alert, animated: true)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
            self.present(alert, animated: true)
        default:break
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.items[indexPath.row] {
        case .header:
            let cell = tableView.dequeueReusableCell(withIdentifier: "header", for: indexPath) as! AccountHeaderCell
            cell.imgAvatar.addGestureRecognizer(target: self, selector: #selector(editAvatar), shouldClear: true)
            cell.btnEdit.removeTarget(nil, action: nil, for: .touchUpInside)
            cell.btnEdit.addTarget(self, action: #selector(editAvatar), for: .touchUpInside)
            loginProvider.loggedInUserSubject.combineLatest(viewModel.loadingAvatar).sink { [weak cell] (user, loading) in
                guard let cell = cell else { return }
                if let loading = loading {
                    cell.imgAvatar.image = loading
                    cell.loaderAvatar.startAnimating()
                    cell.imgAvatar.alpha = 0.2
                } else {
                    cell.loaderAvatar.stopAnimating()
                    cell.imgAvatar.alpha = 1.0
                    if let avatar = user?.avatar, let url = URL(string: avatar) {
                        cell.imgAvatar.kf.setImage(with: url)
                    } else {
                        cell.imgAvatar.image = UIImage(named: "profile_placeholder")
                    }
                }
            } => cell.bag
            return cell
        case .bool(let item):
            let cell = tableView.dequeueReusableCell(withIdentifier: "bool", for: indexPath) as! SettingBooleanCell
            cell.label.text = item.name
            cell.mainSwitch.removeTarget(nil, action: nil, for: .valueChanged)
            cell.mainSwitch.tag = indexPath.row
            cell.mainSwitch.addTarget(self, action: #selector(mainSwitchValueChanged(sender:)), for: .valueChanged)
            item.on.sink { [weak cell] isOn in
                guard let cell = cell else { return }
                cell.mainSwitch.setOn(isOn != .off, animated: isOn != .onInitial)
            } => cell.bag
            return cell
        case .language(let item):
            let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath) as! SettingTextCell
            cell.lblTitle.text = NSLocalizedString("Language", comment: "")
            item.sink { [weak cell] language in
                guard let cell = cell else { return }
                cell.lblDescription.text = language
            } => cell.bag
            return cell
        case .email(let item):
            let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath) as! SettingTextCell
            cell.lblTitle.text = NSLocalizedString("Email", comment: "")
            item.sink { [weak cell] language in
                guard let cell = cell else { return }
                cell.lblDescription.text = language
            } => cell.bag
            return cell
        case .spacer:
            return tableView.dequeueReusableCell(withIdentifier: "SpacerCell", for: indexPath)
        case .contact:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SmallSettingsItemCell", for: indexPath) as! SettingItemCell
            cell.lblSettingText.text = NSLocalizedString("Contact us", comment: "")
            return cell
        case .delete:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SmallSettingsItemCell", for: indexPath) as! SettingItemCell
            cell.lblSettingText.text = NSLocalizedString("Delete account", comment: "")
            return cell
        }
    }
    
    
    
    
}
