//
//  SecondViewController.swift
//  Positron
//
//  Created by Sanip Shrestha on 9/22/20.
//  Copyright © 2020 Sanip Shrestha. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import Speech
import ProgressHUD

class DailyMomentViewController: UIViewController, AVAudioRecorderDelegate, SFSpeechRecognizerDelegate{
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var imageView: UIImageView!
    var textView: UILabel!

    var dailyTable: DailyStatTableView!
    var task: SFSpeechRecognitionTask!

    let shapeLayer = CAShapeLayer()
    let trackShapeLayer = CAShapeLayer()
    
    let audioEngine = AVAudioEngine()
    let speechRecogniser : SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    
    var message: String = ""
    var AudioFileName: String = ""
    var MomentList: [Moment] = []
    var numberOfRecord = 0
    
    var countLabel : UILabel = UILabel()
    var refreshControl : UIRefreshControl = UIRefreshControl()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        ProgressUtil.normal()

        dailyTable = DailyStatTableView(instance: self)
        
        initializeRefresh()
        initializeAudioRecord()
        initializeCircleAnimation()
        initializeRecordButton()
        initializeDailyTable()
        initializeText()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        refreshData()
    }
    
    private func initializeRefresh()
    {
        refreshControl = UIRefreshControl()
        refreshControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        refreshControl.tintColor = .white
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
    }
    
    @objc func refresh(_ sender: AnyObject) {
      refreshData()
    }
    
    private func initializeAudioRecord()
    {
        recordingSession = AVAudioSession.sharedInstance()
        try! recordingSession.setCategory(AVAudioSession.Category.playAndRecord)
        Util.requestAudioPermissions(session: recordingSession)
        Util.requestTranscribePermissions()
    }
    
    private func initializeRecordButton()
    {
        let centre = CGPoint(x: view.center.x, y: view.center.y)
        let image = UIImage(systemName: "dot.circle.fill")?
            .withTintColor(UIColor(red: 0.0863, green: 0.2745, blue: 0.349, alpha: 1.0) , renderingMode: .alwaysOriginal)
        
        imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: 220, height: 220)
        imageView.center = centre
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.addGestureRecognizer(UILongPressGestureRecognizer(target:self, action: #selector(handleLongGesture(sender:))))
        imageView.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(handleTap(sender:))))

        countLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        countLabel.center = centre
        countLabel.font = UIFont(name: "arial", size: 30)
        countLabel.textAlignment = .center
        countLabel.textColor = .green
        
        view.addSubview(countLabel)
        view.addSubview(imageView)
    }
    
    private func initializeCircleAnimation()
    {
        let centre = CGPoint(x: view.center.x, y: view.center.y)
        let circularPath = UIBezierPath(arcCenter: centre, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)

        trackShapeLayer.path = circularPath.cgPath
        trackShapeLayer.strokeColor = UIColor.darkGray.cgColor.copy(alpha: 0.2)
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
        let centre = CGPoint(x: view.center.x, y: view.center.y)

        print("Attempting to animate stroke.")
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")

        if (sender.state == .began){
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

            AudioFileName = "\(AppDelegate.UserID)-\(UtilDate.getCurrentDateString()).wav"

            let circularPath = UIBezierPath(arcCenter: centre, radius: 80, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
            trackShapeLayer.path = circularPath.cgPath
            shapeLayer.path = circularPath.cgPath
            imageView.frame = CGRect(x: 0, y: 0, width: 180, height: 180)
            imageView.center = centre
                
            UIView.animate(withDuration: 1, animations: {
                self.imageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
              
            }) { (finished) in
                UIView.animate(withDuration: 1, animations: {
                    self.imageView.transform = CGAffineTransform.identity
                })
            }
            //startSpeechRecognition()
            basicAnimation.toValue = 1
            basicAnimation.duration = 30
            basicAnimation.fillMode = CAMediaTimingFillMode.forwards
            basicAnimation.isRemovedOnCompletion = true
            
            shapeLayer.add(basicAnimation, forKey: "urSoBasic")
            
            print (AudioFileName)
            let audioFilePath = Util.getDocumentsDirectory().appendingPathComponent(AudioFileName)
            
            let settings = [
                AVEncoderBitRateKey: 16,
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
            ]  as [String : Any]
            
            do {
                audioRecorder = try AVAudioRecorder(url: audioFilePath, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
            } catch {
                
            }
        }
        else if (sender.state == .ended)
        {
            let circularPath = UIBezierPath(arcCenter: centre, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
            trackShapeLayer.path = circularPath.cgPath
            shapeLayer.path = circularPath.cgPath
            imageView.frame = CGRect(x: 0, y: 0, width: 220, height: 220)
            imageView.center = centre
            
            let toURL = "\(AppDelegate.ApiURL)/uploadRecording"
            let moment = MomentApiModel()
            moment.MomentName = "Moment"
            moment.MomentDate = moment.getDateForApi()
            moment.AudioRecordingURL = ""
            moment.TranscribedNotes = ""
            moment.UserID = AppDelegate.UserID

            let deviceURL = Util.getDocumentsDirectory().appendingPathComponent(AudioFileName)
            //momentTable.moments = MomentList
            
            ProgressUtil.custom(text: "Saving your recording.\nPlease wait..")
            self.UploadFile(deviceURL: deviceURL, toURL: toURL, completion: { (url) in
                moment.AudioRecordingURL = url
                self.audioRecorder.stop()
                self.transcribeAudio(url: deviceURL) { (result) in
                    moment.TranscribedNotes = result
                    
                    AppDelegate.WebApi.InsertMoment(moment: moment) { (insertResult) in
                        self.refreshData()
                    }}
            })

            shapeLayer.removeAllAnimations()
        }
    }
    
    @objc private func handleTap(sender: UITapGestureRecognizer)
    {
        let centre = CGPoint(x: view.center.x, y: view.center.y)

        if (sender.state == .began){
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

            AudioFileName = "\(AppDelegate.UserID)-\(UtilDate.getCurrentDateString()).wav"

            let circularPath = UIBezierPath(arcCenter: centre, radius: 80, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
            trackShapeLayer.path = circularPath.cgPath
            shapeLayer.path = circularPath.cgPath
            imageView.frame = CGRect(x: 0, y: 0, width: 180, height: 180)
            imageView.center = centre
            imageView.backgroundColor = .clear
                
            UIView.animate(withDuration: 1, animations: {
                self.imageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
              
            }) { (finished) in
                UIView.animate(withDuration: 1, animations: {
                    self.imageView.transform = CGAffineTransform.identity
                })
            }
        }
        else if (sender.state == .ended){
            let circularPath = UIBezierPath(arcCenter: centre, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
            trackShapeLayer.path = circularPath.cgPath
            shapeLayer.path = circularPath.cgPath
            imageView.frame = CGRect(x: 0, y: 0, width: 220, height: 220)
            imageView.center = centre
            
            refreshData()
        }
        
        let moment = MomentApiModel()
        moment.MomentName = "Moment"
        moment.MomentDate = moment.getDateForApi()
        moment.AudioRecordingURL = ""
        moment.TranscribedNotes = ""
        moment.UserID = AppDelegate.UserID
        
        AppDelegate.WebApi.InsertMoment(moment: moment) { (result) in
            print("success before")
            self.refreshData()
        }
    }
    
    private func initializeDailyTable()
    {
        dailyTable.delegate = dailyTable
        dailyTable.dataSource = dailyTable
        
        dailyTable.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 20)
        dailyTable.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(dailyTable);
        
        dailyTable.topAnchor.constraint(equalTo:view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        dailyTable.leadingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        dailyTable.trailingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        dailyTable.bottomAnchor.constraint(equalTo:imageView.safeAreaLayoutGuide.topAnchor).isActive = true
        
        dailyTable.backgroundColor = .clear
    }
    
    private func initializeText()
    {
        let label = UILabel()
        label.text = "Tap to count. Long press to record."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .white
        
        textView = label
        textView.frame.size = CGSize(width: view.bounds.width, height: 20)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.alpha = 1

        UIView.animate(withDuration: 0.6, delay: 7, options: .curveEaseInOut, animations: {
            self.textView.alpha = 0
        })
        
        view.addSubview(textView);
        
        textView.topAnchor.constraint(equalTo:dailyTable.safeAreaLayoutGuide.topAnchor, constant: 80).isActive = true
        textView.leadingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo:imageView.safeAreaLayoutGuide.topAnchor).isActive = true

        textView.backgroundColor = .clear
    }

    public func refreshData()
    {
        AppDelegate.WebApi.GetTodaysMoments { (momentsViewModel) in
            self.numberOfRecord = momentsViewModel.count
            self.dailyTable.reloadData()
            
            self.refreshControl.endRefreshing()
            ProgressUtil.dismiss()
        }
    }
    
    private func transcribeAudio(url: URL, completion :@escaping (String ) -> Void)
    {
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        let request = SFSpeechURLRecognitionRequest(url: url)
            
        request.shouldReportPartialResults = true

        if (recognizer?.isAvailable)! {

            recognizer?.recognitionTask(with: request) { result, error in
                guard error == nil else { print("Error: \(error!)"); return }
                guard let result = result else { print("No result!"); return }
 
                if result.isFinal{
                let resultTranscription = (result.bestTranscription.formattedString)
                    completion(resultTranscription);
                }
            }
        } else {
            print ("Device doesn't support speech recognition")
        }
    }
    
    public func UploadFile(deviceURL : URL, toURL: String, completion :@escaping (String ) -> Void)
    {
        let fileName = deviceURL.lastPathComponent
        guard let audioFile: Data = try? Data (contentsOf: deviceURL) else {return}
        
        let params = ["username": AppDelegate.UserID,
                      "password": AppDelegate.Password,
                      "filename": "audiofile"]
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in params {
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            multipartFormData.append(audioFile, withName: "audiofile", fileName: fileName, mimeType: "audio/wav")
        
        }, to: toURL)
        .responseString(completionHandler: { (response) in
            switch response.result {
            case .success:
                let jsonData = response.data
                print(response)
                do{
                    let apiresponse =  try JSONDecoder().decode(ApiResponseModel.self, from: jsonData!)

                    if let url = apiresponse.Data {
                        completion(url)
                    }
                }catch {
                    print("Error: \(error)")
                }
                
            case .failure(let error):
                print(error)
            }
        })
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        .lightContent
    }
}
