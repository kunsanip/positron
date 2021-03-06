//
//  ProgressUtil.swift
//  Positron
//
//  Created by Sanip Shrestha on 11/5/20.
//  Copyright © 2020 Sanip Shrestha. All rights reserved.
//

import Foundation
import ProgressHUD

public class ProgressUtil
{
    public static func normal()
    {
        ProgressHUD.show("Loading your moments..")
        ProgressHUD.animationType = .multipleCirclePulse
        ProgressHUD.colorHUD = .black
        ProgressHUD.colorBackground = .lightGray
        ProgressHUD.colorAnimation = .systemBlue
        ProgressHUD.colorProgress = .systemBlue
        ProgressHUD.colorStatus = .label
        ProgressHUD.fontStatus = .boldSystemFont(ofSize: 12)
    }
    public static func logIn()
    {
        ProgressHUD.show("Logging in")
        ProgressHUD.animationType = .multipleCirclePulse
        ProgressHUD.colorHUD = .black
        ProgressHUD.colorBackground = .lightGray
        ProgressHUD.colorAnimation = .systemBlue
        ProgressHUD.colorProgress = .systemBlue
        ProgressHUD.colorStatus = .label
        ProgressHUD.fontStatus = .boldSystemFont(ofSize: 12)
    }
    
    public static func custom(text : String)
    {
            ProgressHUD.show(text)
            ProgressHUD.animationType = .multipleCirclePulse
            ProgressHUD.colorHUD = .black
            ProgressHUD.colorBackground = .lightGray
            ProgressHUD.colorAnimation = .systemBlue
            ProgressHUD.colorProgress = .systemBlue
            ProgressHUD.colorStatus = .label
            ProgressHUD.fontStatus = .boldSystemFont(ofSize: 12)
    }
    public static func barProgress()
    {
        ProgressHUD.show()
        ProgressHUD.animationType = .lineScaling
        ProgressHUD.colorHUD = .white
        ProgressHUD.colorBackground = .lightGray
        ProgressHUD.colorProgress = .white
    }
    
    public static func dismiss()
    {
        ProgressHUD.dismiss()
    }
    
}
