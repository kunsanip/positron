//
//  MomentTable.swift
//  Positron
//
//  Created by Sanip Shrestha on 10/17/20.
//  Copyright © 2020 Sanip Shrestha. All rights reserved.
//

import UIKit
import AVFoundation

public class MomentTableView: UITableView, UITableViewDataSource, UITableViewDelegate, AVAudioRecorderDelegate {
    
    public var moments: [MomentApiModel] = []
    public var recordingSession: AVAudioSession!
    public var audioRecorder: AVAudioRecorder!
    public var audioPlayer: AVAudioPlayer!

    private var vcInstance : DailyMomentViewController!
    
    init(instance : DailyMomentViewController) {
        vcInstance = instance
        
        super.init(frame: CGRect(x: 0,y: 0,width: 0,height: 0), style: .grouped)
        
        self.register(MomentTableViewCell.self, forCellReuseIdentifier: "momentCell")
        self.delegate = self
        self.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moments.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.dequeueReusableCell( withIdentifier: "momentCell", for: indexPath) as! MomentTableViewCell
        
        let moment = moments[indexPath.row]
        cell.textLabel?.text = moment.MomentName

        let fullString = NSMutableAttributedString(string: "")
        
        if moment.AudioRecordingURL != nil && moment.AudioRecordingURL != ""
        {
            let image1Attachment = NSTextAttachment()
            image1Attachment.image = UIImage(systemName: "livephoto.play")?
                .withTintColor(UIColor.white , renderingMode: .alwaysOriginal)
            let image1String = NSAttributedString(attachment: image1Attachment)
            fullString.append(image1String)
        }
        fullString.append(NSAttributedString(string: "  " + moments[indexPath.row].getTime()))
        
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
        
        vcInstance.navigationController?.pushViewController(MomentInfoViewController(momentApiModel: moments[indexPath.row]), animated: true)
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let moment = moments[indexPath.row]
            if let mt = moment.MomentID{
                AppDelegate.WebApi.DeleteMoment(momentID: Int(mt) ?? 0) { (result) in
                    self.vcInstance.refreshData();
                }
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}
