//
//  NotificationsViewModel.swift
//  SettingsScreenImpl
//
//  Created by Mor on 14/07/2022.
//

import Foundation
import Combine
import SettingsApi
import TedoooCombine

enum SwitchOnStatus {
    case onInitial
    case off
    case on
}

struct NotificationSettingItem {
    let name: String
    let on: CurrentValueSubject<SwitchOnStatus, Never> = CurrentValueSubject(.off)
}

class NotificationsViewModel {
    
    let loading = CurrentValueSubject<Bool, Never>(false)
    
    let items: [NotificationSettingItem] = [
        .init(name: NSLocalizedString("Post notifications", comment: ""))
    ]
    
    let mainLoading = CurrentValueSubject<Bool, Never>(true)
    private var bag = CombineBag()
    private let api: SettingsApi
    let errorChanging = PassthroughSubject<String, Never>()
    let errorAndDismiss = PassthroughSubject<String, Never>()
    
    init() {
        api = DIContainer.shared.resolve(SettingsApi.self)
        api.fetchNotificationSettings().sink { [weak self] result in
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
            self.items[0].on.value = settings.postNotifications ? .onInitial : .off
        } => bag
    }
    
    func changePostNotifications(to on: Bool) {
        items[0].on.value = on ? .on : .off
        loading.value = true
        api.updateSettingItem(item: .postNotifications, newValue: on).sink { [weak self] result in
            guard let self = self else { return }
            self.loading.value = false
            switch result {
            case .finished: break
            case .failure:
                self.items[0].on.value = on ? .off : .on
                self.errorChanging.send(NSLocalizedString("Could not change this setting, please try again later", comment: ""))
            }
        } receiveValue: { _ in
        } => bag
    }
    
}
