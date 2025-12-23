//
//  Router.swift
//  GeoRemind
//
//  Created by Osama Afaque on 20/12/2025.
//

import Foundation
import SwiftUI

 class AppCoordinator {
    let navigationController = UINavigationController()

    func start() {
        let rootView = DashboardView(appCoordinator: self)
        let dashboardVC = UIHostingController(rootView: rootView)
        navigationController.setViewControllers([dashboardVC], animated: false)
        navigationController.navigationBar.isHidden = true
    }

    func showMap(pageType: MapSearchViewType,reminder: Reminder? = nil) {
        let mapVC = UIHostingController(rootView: MapSearchView(appCoordinator: self, pageType: pageType, selectedReminder: reminder))
        navigationController.pushViewController(mapVC, animated: true)
    }
    
    func showActivityTracker() {
        let mapVC = UIHostingController(rootView: ActivityTrackerView())
        navigationController.pushViewController(mapVC, animated: true)
    }
    
    func showReminderDetail(reminder: Reminder) {
        let mapVC = UIHostingController(rootView: ReminderDetailView(reminder: reminder, appCoordinator: self))
        navigationController.pushViewController(mapVC, animated: true)
    }
    
    func popToVC() {
        navigationController.popViewController(animated: true)
    }
    
    
   static func showDeleteReminderAlert(onYes: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Are you sure you want to delete this reminder?",
            message: nil,
            preferredStyle: .alert
        )
        
        // YES button
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            onYes()
        }
        
        // NO button
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        // Present alert
        if let topVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?
            .rootViewController {
            
            topVC.present(alert, animated: true)
        }
    }
}

extension AppCoordinator: ReminderCoordinatorProtocol {
    func showMap(pageType: MapSearchViewType, reminder: Reminder) {
        let mapVC = UIHostingController(rootView: MapSearchView(appCoordinator: self, pageType: pageType, selectedReminder: reminder))
        navigationController.pushViewController(mapVC, animated: true)
    }
}
