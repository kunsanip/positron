//
//  FirstViewController.swift
//  Positron
//
//  Created by Sanip Shrestha on 9/22/20.
//  Copyright © 2020 Sanip Shrestha. All rights reserved.
//

import UIKit
import Alamofire

public class SummaryViewController: UIViewController
{
    
    @IBOutlet weak var weeklySummaryView: MacawChartView!
    public override func viewDidLoad() {
        weeklySummaryView.contentMode = .scaleAspectFit
        MacawChartView.playAnimation();

    }
    public override func viewDidAppear(_ animated: Bool) {
    }
}
