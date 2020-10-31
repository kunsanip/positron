//
//  SecondViewController.swift
//  Positron
//
//  Created by Sanip Shrestha on 9/22/20.
//  Copyright © 2020 Sanip Shrestha. All rights reserved.
//

import UIKit
import AVFoundation

class DailyMomentViewController: UIViewController, AVAudioRecorderDelegate{
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    let shapeLayer = CAShapeLayer()
    let trackShapeLayer = CAShapeLayer()
    let momentTable = MomentTable()
    
    var imageView: UIImageView!
    
    var MomentList: [Moment] = []
    var numberOfRecord = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeAudioRecord()
        initializeCircleAnimation()
        initializeRecordButton()
        initializeMomentTable()
    }
    
    private func initializeAudioRecord()
    {
        recordingSession = AVAudioSession.sharedInstance()
        
        AVAudioSession.sharedInstance().requestRecordPermission{
            (hasPermission) in
            if hasPermission
            {
                print("accepted")
            }
        }
    }
    
    private func initializeRecordButton()
    {
        let centre = CGPoint(x: view.center.x, y: view.center.y - 150)

        let image = UIImage(systemName: "dot.circle.fill")
        
        imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: 220, height: 220)
        imageView.center = centre
        imageView.isUserInteractionEnabled = true;
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.addGestureRecognizer(UILongPressGestureRecognizer(target:self, action: #selector(handleLongGesture(sender:))))
        imageView.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(handleTap(sender:))))

        view.addSubview(imageView)
    }
    
    private func initializeCircleAnimation()
    {
        let centre = CGPoint(x: view.center.x, y: view.center.y - 150)
        let circularPath = UIBezierPath(arcCenter: centre, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)

        trackShapeLayer.path = circularPath.cgPath
        trackShapeLayer.strokeColor = UIColor.red.cgColor.copy(alpha: 0.2)
        trackShapeLayer.lineWidth = 10
        trackShapeLayer.lineCap = CAShapeLayerLineCap.round
        trackShapeLayer.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(trackShapeLayer)
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeEnd = 0
        
        view.layer.addSublayer(shapeLayer)
    }
    
    @objc private func handleLongGesture(sender: UILongPressGestureRecognizer)
    {
        print("Attempting to animate stroke.")
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        var audioName = "recording " + String(MomentList.count) + ".m4a"

        if (sender.state == .began){
            basicAnimation.toValue = 1
            basicAnimation.duration = 30
            basicAnimation.fillMode = CAMediaTimingFillMode.forwards
            basicAnimation.isRemovedOnCompletion = true
        
            shapeLayer.add(basicAnimation, forKey: "urSoBasic")
            
            print ("a")
            print (audioName)
            let audioFilename = Util.getDocumentsDirectory().appendingPathComponent(audioName)
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            do {
                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
            } catch {
                
            }
        }
        else if (sender.state == .ended)
        {
            let date = Date()
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "h:mm a"
            formatter.amSymbol = "AM"
            formatter.pmSymbol = "PM"
            
            let moment = Moment()
            moment.MomentName = "Recording " + String(MomentList.count)
            moment.MomentDate = date
            moment.AudioRecording = audioName
            
            MomentList.append(moment)
            momentTable.moments = MomentList
            momentTable.reloadData()
            
            audioRecorder.stop()
            shapeLayer.removeAllAnimations()
        }
    }
    
    @objc private func handleTap(sender: UITapGestureRecognizer)
    {
        let date = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
        _ = formatter.string(from: date)
        
        let moment = Moment()
        moment.MomentName = "Recording"
        moment.MomentDate = date
        moment.AudioRecording = ""
        
        MomentList.append(moment)
        momentTable.moments = MomentList
        momentTable.reloadData()
    }
    
    private func initializeMomentTable()
    {
        momentTable.delegate = momentTable
        momentTable.dataSource = momentTable
        
        momentTable.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 90)
        momentTable.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(momentTable);

        momentTable.topAnchor.constraint(equalTo:imageView.safeAreaLayoutGuide.bottomAnchor, constant: 30).isActive = true
        momentTable.leadingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        momentTable.trailingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        momentTable.bottomAnchor.constraint(equalTo:view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        momentTable.backgroundColor = view.backgroundColor
        
    }

}
