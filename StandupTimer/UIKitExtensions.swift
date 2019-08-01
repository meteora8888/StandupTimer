//
//  UIKitExtensions.swift
//  StandupTimer
//
//  Created by Andrej Jasso on 23/07/2019.
//  Copyright © 2019 Andrej Jasso. All rights reserved.
//

import UIKit

extension UIViewController {
    
    enum AlertButtonType {
        
        case ok
        case cancel
        
        var title: String {
            
            switch self {
            case .ok:
                return "ok"
            case .cancel:
                return "CANCEL"
            }
            
        }
        
        var style: UIAlertAction.Style {
            
            switch self {
            case .ok:
                return .default
            case .cancel:
                return .cancel
            }
        }
        
    }
    
    func presentAlert(title: String? = nil, message: String? = nil, preferedStyle: UIAlertController.Style = .alert, alertButtons: [(type: AlertButtonType, completion: ((UIAlertAction) -> Void)?)] = [(type: .ok, completion: nil)]) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: preferedStyle)
        
        alertButtons.enumerated().forEach({
            let action = UIAlertAction(title: alertButtons[$0.offset].type.title, style: alertButtons[$0.offset].type.style, handler: alertButtons[$0.offset].completion)
            alertViewController.addAction(action)
        })
        
        present(alertViewController, animated: true, completion: nil)
    }

}
