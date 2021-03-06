//
//  MomentInfoViewController.swift
//  Positron
//
//  Created by Sanip Shrestha on 2/13/21.
//  Copyright © 2021 Sanip Shrestha. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation

public class MomentInfoViewController: UIViewController {
    
    @IBOutlet weak var momentDate: UILabel!
    @IBOutlet weak var momentName: UILabel!
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var notesText: UITextView!
    @IBOutlet weak var updateButton: UIButton!
    private var audioPlayer: AVAudioPlayer!
    
    public var InstanceVC = UIViewController()
    
    public var momentViewModel : MomentApiModel = MomentApiModel()
    init(momentApiModel : MomentApiModel) {
        momentViewModel = momentApiModel;
        
        super.init(nibName: "", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        updateButton.isEnabled = true
        // Do any additional setup after loading the view.
    }
    @IBAction func momentNameEdit(_ sender: Any) {
        
            let alert = UIAlertController(title: "", message: "Update moment name", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = self.momentName.text
            })
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (updateAction) in
                self.momentName.text = alert.textFields!.first!.text!
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: false)

    }
    
    public func setup(vm:MomentApiModel)
    {
        momentViewModel = vm
        momentDate.text = vm.MomentDate
        momentName.text = vm.MomentName
        notesText.text = vm.TranscribedNotes
        
        playButton.isEnabled = vm.AudioRecordingURL != ""
        if (!playButton.isEnabled)
        {
            playButton.removeFromSuperview()
        }
    }
    
    @IBAction func playClicked(_ sender: Any) {
        playAudio()
    }
    
    @IBAction func updatePressed(_ sender: Any) {
        momentViewModel.MomentName = momentName.text
        momentViewModel.TranscribedNotes = notesText.text
        AppDelegate.WebApi.UpdateMoment(moment: momentViewModel) { (result) in
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
            (self.InstanceVC as! JournalViewController).refreshData()
        }
    }
    
    @objc func playAudio() {
        
        guard let url = URL.init(string: momentViewModel.AudioRecordingURL ?? "") else { return }
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
}
