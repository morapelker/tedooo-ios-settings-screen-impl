//
//  NotificationSettingsViewController.swift
//  SettingsScreenImpl
//
//  Created by Mor on 14/07/2022.
//

import Foundation
import UIKit
import Combine
import TedoooCombine

class NotificationSettingsViewController: UIViewController {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var mainSpinner: UIActivityIndicatorView!
    @IBOutlet weak var navItem: UINavigationItem!
    let viewModel = NotificationsViewModel()
    private var bag = CombineBag()
    private let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    private lazy var barButton = UIBarButtonItem(customView: activityIndicator)

    static func instantiate() -> UIViewController {
        return GPHelper.instantiateViewController(type: NotificationSettingsViewController.self)
    }
    
    
    
    @IBAction func backClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        
        subscribe()
    }
    
    private func subscribe() {
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

extension NotificationSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentValue = viewModel.items[indexPath.row].on.value
        viewModel.changePostNotifications(to: currentValue == .off)
    }
    
    @objc private func mainSwitchValueChanged(sender: UISwitch) {
        let currentValue = viewModel.items[sender.tag].on.value
        viewModel.changePostNotifications(to: currentValue == .off)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! SettingBooleanCell
        let item = viewModel.items[indexPath.row]
        cell.label.text = item.name
        cell.mainSwitch.removeTarget(nil, action: nil, for: .valueChanged)
        cell.mainSwitch.tag = indexPath.row
        cell.mainSwitch.addTarget(self, action: #selector(mainSwitchValueChanged(sender:)), for: .valueChanged)
        item.on.sink { [weak cell] isOn in
            guard let cell = cell else { return }
            cell.mainSwitch.setOn(isOn != .off, animated: isOn != .onInitial)
        } => cell.bag
        
        return cell
    }
    
    
    
    
}
