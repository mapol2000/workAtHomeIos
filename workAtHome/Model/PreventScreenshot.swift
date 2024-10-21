//
//  PreventScreenshot.swift
//  workAtHome
//
//  Created by 김평구 on 10/16/24.
//

import UIKit
@preconcurrency import WebKit


    
    @available(iOS 13.0, *)
    func makeSecure(window: UIWindow) {
      DispatchQueue.main.async {
        let field = UITextField()
        field.isSecureTextEntry = true
        window.addSubview(field)
        
        window.layer.superlayer?.addSublayer(field.layer)
        field.layer.sublayers?.last?.addSublayer(window.layer)
      }
    }

