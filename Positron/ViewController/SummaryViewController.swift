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
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollableStackView: UIStackView!
    @IBOutlet weak var weeklySummaryView: MacawChartView!
    @IBOutlet weak var viewBySegment: UISegmentedControl!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    public override func viewDidLoad() {
        weeklySummaryView.contentMode = .scaleAspectFit
        let font = UIFont.systemFont(ofSize: 10)
        
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: PositronColor.primary], for: .selected)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: font], for: .normal)
        segmentedControl.selectedSegmentTintColor = .white
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        refreshData()
    }
    
    @IBAction func segmentControlChanged(_ sender: Any) {
        refreshData()
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    func refreshData(){
        
        weeklySummaryView.refreshData(viewby: SummaryViewBy(rawValue: viewBySegment.selectedSegmentIndex)!)
    }
}

public enum SummaryViewBy: Int {
    case thisweek     = 0
    case lastweek     = 1
    case thismonth    = 2
}
