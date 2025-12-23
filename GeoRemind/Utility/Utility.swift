//
//  Utility.swift
//  GeoRemind
//
//  Created by Osama Afaque on 21/12/2025.
//

import Foundation
import SwiftMessages
import UIKit


class Utility {
    
    // Singleton instance
    static let shared = Utility()
    
    // Private initializer to prevent instantiation
    private init() {}

    func showCustomMessage(title:String? = "" , message:String ,theme:Theme? = .success	) {
        
        DispatchQueue.main.async {
            let info = MessageView.viewFromNib(layout: .cardView)
            print(info.frame.width)
            info.configureTheme(theme!)
            info.button?.isHidden = true
            info.configureContent(title: title!, body: message)
            var infoConfig = SwiftMessages.defaultConfig
            infoConfig.presentationStyle = .top
            infoConfig.presentationContext = .window(windowLevel: UIWindow.Level.normal)
            infoConfig.duration = .seconds(seconds: 3.0)
            SwiftMessages.show(config: infoConfig, view: info)
        }
    }
    
    func getServerDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy hh:mm:a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let formattedDate = formatter.string(from: date)  // Note: string(from:)
        print(formattedDate)
        return formattedDate
    }

    
    
}
