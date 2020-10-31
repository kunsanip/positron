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
    }
    public override func viewDidAppear(_ animated: Bool) {
        MacawChartView.playAnimation();
        
        GetData()
    }
    public func GetData()
    {
        AppDelegate.WebApi.GetAllMoments { (moments) in
            for moment in moments{
                print(moment.MomentName!)
            }
        }
    }
    
//    public func GetPeopleData() -> [String]
//    {
//        Alamofire.req .request("http://www.sanip.com.au/json/api/getPeople").responseJSON { (response) in
//            switch response.result {
//            case .success:
//                if((response.result) != nil) {
//                    let jsonData = response.data
//                    do{
//                        SVProgressHUD.showProgress(1, status: "Downloading")
//                        SVProgressHUD.setBackgroundColor(UIColor(red: 200, green: 235, blue: 244, alpha: 1))
//                        self.peopleData =  try JSONDecoder().decode([PeopleStruct].self, from: jsonData!)
//                        SVProgressHUD.dismiss()
//
//                    }catch {
//                        print("Error: \(error)")
//                    }
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
//        return self.peopleData
//
//    }
}
