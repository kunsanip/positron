//
//  MomentTable.swift
//  Positron
//
//  Created by Sanip Shrestha on 10/17/20.
//  Copyright © 2020 Sanip Shrestha. All rights reserved.
//

import UIKit
import AVFoundation

public class DailyStatTableView: UITableView, UITableViewDataSource, UITableViewDelegate, AVAudioRecorderDelegate {

    private var vcInstance : DailyMomentViewController!
    
    init(instance : DailyMomentViewController) {
        vcInstance = instance
        
        super.init(frame: .zero, style: .insetGrouped)
        
        let tableviewcell = UITableViewCell()
        self.register(MomentTableViewCell.self, forCellReuseIdentifier: "dailyStatCell")
        self.delegate = self
        self.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.dequeueReusableCell( withIdentifier: "dailyStatCell", for: indexPath)
        
        cell.textLabel?.text = "Monkey Mind"
        cell.detailTextLabel?.text =  "8"
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        cell.detailTextLabel?.textColor = .white;
        
        cell.textLabel?.font = UIFont(name: "Helvetica", size: 14)
        cell.detailTextLabel?.font = UIFont(name: "Helvetica", size: 12)
        
        cell.backgroundColor  = .clear
        cell.textLabel?.textColor = .white
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
}
