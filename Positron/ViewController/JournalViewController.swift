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

class JournalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var diarySegment: UISegmentedControl!
    @IBOutlet weak var diaryTable: UITableView!
    var refreshControl: UIRefreshControl!
    var sections = [MomentGroup]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        diaryTable.register(MomentTableViewCell.self, forCellReuseIdentifier: "diaryCell")
        initialiseView()
        refreshData()
    }
    override func viewDidAppear(_ animated: Bool) {
        refreshData();
    }
    
    public func initialiseView()
    {
        let font = UIFont.systemFont(ofSize: 10)
       
        diarySegment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: PositronColor.primary], for: .selected)
        diarySegment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: font], for: .normal)
        diarySegment.selectedSegmentTintColor = .white
        
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
    
    public func refreshData()
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

            let dict =  Dictionary(grouping: filteredMoments, by: {$0.getDate()?.toString()})
            self.sections = dict.sorted(by: { UtilDate.getDateFromString(dateString: $0.key!)! > UtilDate.getDateFromString(dateString: $1.key!)! }).map { (key, values) in
                return MomentGroup(MomentDate: key ?? "-", Moments: values)
            }
            
            self.diaryTable.reloadData()
            self.refreshControl.endRefreshing()
            ProgressUtil.dismiss()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        let section = self.sections[section]
        let date = section.MomentDate
        return date
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = self.sections[section]
        return section.Moments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell( withIdentifier: "diaryCell", for: indexPath) as! MomentTableViewCell
        
        let section = self.sections[indexPath.section]
        let moment = section.Moments[indexPath.row]

        cell.textLabel?.text = moment.MomentName
        cell.detailTextLabel?.text =  moment.getTime() //moments[indexPath.row].getTime()

        let fullString = NSMutableAttributedString(string: "")
        
        if moment.AudioRecordingURL != nil && moment.AudioRecordingURL != ""
        {
            let image1Attachment = NSTextAttachment()
            image1Attachment.image = UIImage(systemName: "livephoto.play")?
                .withTintColor(UIColor.white , renderingMode: .alwaysOriginal)
            let image1String = NSAttributedString(attachment: image1Attachment)
            fullString.append(image1String)
        }
        fullString.append(NSAttributedString(string: "  " + moment.getTime()))
        
        cell.detailTextLabel?.attributedText = fullString
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
        // Safe Present
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "momentInfo") as? MomentInfoViewController
        {
            vc.InstanceVC = self
            present(vc, animated: true, completion: nil)
            
            let section = self.sections[indexPath.section]
            let moment = section.Moments[indexPath.row]
            
            vc.setup(vm: moment)
        }
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var section = self.sections[indexPath.section]
            let moment = section.Moments[indexPath.row]
            
            section.Moments.remove(at: indexPath.row)
            tableView.reloadData()

            if let mt = moment.MomentID{
                AppDelegate.WebApi.DeleteMoment(momentID: Int(mt) ?? 0) { (result) in
                    self.refreshData();
                }
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}
