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
    
    public static func barProgress()
    {
        ProgressHUD.show()
        ProgressHUD.animationType = .lineScaling
        ProgressHUD.colorHUD = .purple
        ProgressHUD.colorBackground = .lightGray
        ProgressHUD.colorAnimation = .systemBlue
        ProgressHUD.colorProgress = .purple
    }
    
    public static func dismiss()
    {
        ProgressHUD.dismiss()
    }
    
}
