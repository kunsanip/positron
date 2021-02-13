//
//  DiaryViewController.swift
//  Positron
//
//  Created by Sanip Shrestha on 11/5/20.
//  Copyright © 2020 Sanip Shrestha. All rights reserved.
//

import UIKit

public enum DiaryEnum: Int {
    case today      = 0
    case weekly     = 1
    case monthly    = 2
    case all        = 3
}

class DiaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var diarySegment: UISegmentedControl!
    @IBOutlet weak var diaryTable: UITableView!
    var refreshControl: UIRefreshControl!
    var momentDiary = [MomentApiModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        diaryTable.register(MomentTableViewCell.self, forCellReuseIdentifier: "diaryCell")
        intialiseView()
        refreshData()
    }
    override func viewDidAppear(_ animated: Bool) {
        refreshData();
    }
    
    public func intialiseView()
    {
        let font = UIFont.systemFont(ofSize: 10)

        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: PositronColor.primary], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: font], for: .normal)
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: font])
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        
        diaryTable.addSubview(refreshControl) // not required when using UITableViewController
    }
    @IBAction func segmentValueChanged(_ sender: Any) {
       refreshData()
    }
    
    @objc func refresh(_ sender: AnyObject) {
      refreshData()
    }
    
    private func refreshData()
    {
        ProgressUtil.normal()
        AppDelegate.WebApi.GetAllMoments { (momentsViewModel) in
            
            var filteredMoments  = [MomentApiModel]()
            let formatter        = DateFormatter()
            formatter.locale     = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd"
          
            let dateString       = formatter.string(from: Date())

            switch self.diarySegment.selectedSegmentIndex
            {
            case DiaryEnum.today.rawValue:
                filteredMoments = momentsViewModel.filter({ (moment) -> Bool in
                    moment.getDateString() == dateString
                })
                break
            case DiaryEnum.weekly.rawValue:
                filteredMoments = momentsViewModel.filter({ (moment) -> Bool in
                    if let date = moment.getDate(){
                        return date >= Date().startOfWeek()
                    }
                    return false
                })
                break
            case DiaryEnum.monthly.rawValue:
                filteredMoments = momentsViewModel.filter({ (moment) -> Bool in
                    if let date = moment.getDate(){
                        return date >= Date().startOfMonth()
                    }
                    return false
                })
                break
            case DiaryEnum.all.rawValue:
                filteredMoments = momentsViewModel
                break
            default:
                break
            }
            
            self.momentDiary = filteredMoments.sorted(by: { $0.MomentDate! > $1.MomentDate! })
            self.diaryTable.reloadData()
            self.refreshControl.endRefreshing()
            ProgressUtil.dismiss()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        momentDiary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell( withIdentifier: "diaryCell", for: indexPath) as! MomentTableViewCell
        
        cell.textLabel?.text = momentDiary[indexPath.row].MomentName
        cell.detailTextLabel?.text =  momentDiary[indexPath.row].getTime() //moments[indexPath.row].getTime()

        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        cell.detailTextLabel?.textColor = .white;
        
        cell.textLabel?.font = UIFont(name: "Helvetica", size: 14)
        cell.detailTextLabel?.font = UIFont(name: "Helvetica", size: 12)
        
        cell.backgroundColor  = .clear
        cell.textLabel?.textColor = .white
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.present(MomentDetailsViewController(moment: momentDiary[indexPath.row]), animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
}
