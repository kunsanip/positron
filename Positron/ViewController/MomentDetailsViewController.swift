//
//  MomentDetailsViewController.swift
//  Positron
//
//  Created by Sanip Shrestha on 10/18/20.
//  Copyright © 2020 Sanip Shrestha. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
class MomentDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    private var momentDetail: MomentApiModel = MomentApiModel()
    private var audioPlayer: AVAudioPlayer!
    private var tableView: UITableView!
    private var rows : [String]!
    private var value : [String]!
    
    init(moment : MomentApiModel)
    {
        momentDetail = moment
        rows = ["Date", "Moment", "Recording", "Notes"]
        value = [momentDetail.getSmallDateString(), momentDetail.MomentName!, momentDetail.AudioRecordingURL!, momentDetail.TranscribedNotes ?? ""]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: CGRect(x: 0, y: 40, width: self.view.bounds.width, height: self.view.bounds.height), style: .insetGrouped)
        view.addSubview(tableView)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MomentTableViewCell.self, forCellReuseIdentifier: "momentCellNew")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell(style: UITableViewCell.CellStyle.value1,
                                   reuseIdentifier: "momentCellNew")
        
        if rows[indexPath.row] == "Notes"{
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle,
                                   reuseIdentifier: "momentCellNew")
            cell.detailTextLabel?.lineBreakMode = .byWordWrapping
            cell.detailTextLabel?.numberOfLines = 0
            
        }
        
        cell.accessoryType = UITableViewCell.AccessoryType.none
        cell.detailTextLabel?.textColor = .label
        
        cell.textLabel?.font = UIFont(name: "Helvetica", size: 14)
        cell.detailTextLabel?.font = UIFont(name: "Helvetica", size: 12)
        
        cell.backgroundColor  = .clear
        cell.textLabel?.textColor = .label
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        cell.textLabel?.text = rows[indexPath.row]
        cell.detailTextLabel?.text = value[indexPath.row]
        
        if rows[indexPath.row] == "Notes"{
            
            let tf = UITextField(frame: CGRect(x: 20, y: 0, width: 20, height: 20))
             tf.placeholder = rows[indexPath.row]
             tf.font = UIFont.systemFont(ofSize: 15)


             //cell.contentView.addSubview(tf)
            cell.detailTextLabel?.addSubview(tf)
        }
        
        if rows[indexPath.row] == "Recording"
        {
            if value[indexPath.row] == ""
            {
                cell.detailTextLabel?.text = "no recording"
                cell.detailTextLabel?.textColor = .darkGray
            }
            else{
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if rows[indexPath.row] == "Recording" && value[indexPath.row] != ""
        {
            playAudio()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if rows[indexPath.row] == "Notes"{
            return 120
        }
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if rows[indexPath.row] == "Notes"{
            return 120
        }
        return UITableView.automaticDimension
    }
    
    @objc func playAudio() {
        
        guard let url = URL.init(string: momentDetail.AudioRecordingURL ?? "") else { return }
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)

        ProgressUtil.normal()
        AF.download(
            url,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: nil,
            to: destination).downloadProgress(closure: { (progress) in

            }).response(completionHandler: { (DefaultDownloadResponse) in
                do
                {
                    var url : URL
                    if let desturl = DefaultDownloadResponse.error?.destinationURL{
                        url = desturl
                    }
                    else
                    {
                        url = try DefaultDownloadResponse.result.get()!
                    }
                    self.audioPlayer = try AVAudioPlayer(contentsOf:url)
                    self.audioPlayer.volume = 60
                    self.audioPlayer.play()
                }
                catch{
                    self.audioPlayer = nil
                    print(error.localizedDescription)
                    
                    print("Could not read..")
                }
                
                ProgressUtil.dismiss()
            })
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}
