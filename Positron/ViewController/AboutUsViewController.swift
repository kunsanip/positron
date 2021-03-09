//
//  AboutUsViewController.swift
//  Positron
//
//  Created by Sanip Shrestha on 3/9/21.
//  Copyright © 2021 Sanip Shrestha. All rights reserved.
//

import UIKit

class AboutUsViewController: UIViewController {

    @IBOutlet weak var aboutusLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        var text = "Version " + (appVersion ?? "")
        text += "\n"
        text += "Monkey mind is an app designed to journal your negative thoughts in an audio format."
        text += "So that you can be aware of it to put an end to it."

        aboutusLabel.text = text
        
        
    }
}
