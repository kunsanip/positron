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

class DailyMomentViewController: UIViewController, AVAudioRecorderDelegate, SFSpeechRecognizerDelegate{
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var imageView: UIImageView!
    var momentTable : MomentTableView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        momentTable = MomentTableView(instance: self)
        
        initializeAudioRecord()
        initializeCircleAnimation()
        initializeRecordButton()
        initializeMomentTable()
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
        let centre = CGPoint(x: view.center.x, y: view.center.y - 100)

        let image = UIImage(systemName: "dot.circle.fill")?
            .withTintColor(UIColor(red: 0.0863, green: 0.2745, blue: 0.349, alpha: 1.0) , renderingMode: .alwaysOriginal)
        
        imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: 220, height: 220)
        imageView.center = centre
        imageView.isUserInteractionEnabled = true;
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.addGestureRecognizer(UILongPressGestureRecognizer(target:self, action: #selector(handleLongGesture(sender:))))
        imageView.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(handleTap(sender:))))

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        label.center = centre
        label.text = "🙈"
        label.font = UIFont(name: "arial", size: 30)
        label.textAlignment = .center

        label.textColor = .green
        
        view.addSubview(label)
        view.addSubview(imageView)
    }
    
    private func initializeCircleAnimation()
    {
        let centre = CGPoint(x: view.center.x, y: view.center.y - 100)
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
        let centre = CGPoint(x: view.center.x, y: view.center.y - 100)

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
            // startSpeechRecognization()
            basicAnimation.toValue = 1
            basicAnimation.duration = 30
            basicAnimation.fillMode = CAMediaTimingFillMode.forwards
            basicAnimation.isRemovedOnCompletion = true
            
            shapeLayer.add(basicAnimation, forKey: "urSoBasic")
            
            print ("a")
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
            
            print(self.message)
            let toURL = "\(AppDelegate.ApiURL)/uploadRecording"

            let moment = Moment()
            moment.MomentName = "Recording " + String(MomentList.count)
            moment.MomentDate = Date()
            moment.AudioRecordingURL = toURL
            moment.TranscribedNotes = "notes"
            
            let deviceURL = Util.getDocumentsDirectory().appendingPathComponent(AudioFileName)
            MomentList.append(moment)
            //momentTable.moments = MomentList
            
            self.UploadFile(deviceURL: deviceURL, toURL: toURL)
            
            momentTable.reloadData()
            audioRecorder.stop()
            shapeLayer.removeAllAnimations()
            //transcribeAudio(url: deviceURL, moment: moment)
        }
    }
    
    @objc private func handleTap(sender: UITapGestureRecognizer)
    {
        let moment = MomentApiModel()
        moment.MomentName = "Recording \(moment.getDateForApi())"
        moment.MomentDate = moment.getDateForApi()
        moment.AudioRecordingURL = "Test"
        moment.TranscribedNotes = "TestNotes"
        moment.UserID = AppDelegate.UserID
        
        InsertMoment(moment: moment)
        
        //MomentList.append(moment)
        //momentTable.moments = MomentList
        momentTable.reloadData()
    }
    
    private func initializeMomentTable()
    {
        momentTable.delegate = momentTable
        momentTable.dataSource = momentTable
        
        momentTable.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 90)
        momentTable.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(momentTable);
        
        AppDelegate.WebApi.GetAllMoments { (momentsViewModel) in
            self.momentTable.moments = momentsViewModel
            self.momentTable.reloadData()
        }
        
        momentTable.topAnchor.constraint(equalTo:imageView.safeAreaLayoutGuide.bottomAnchor, constant: 30).isActive = true
        momentTable.leadingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        momentTable.trailingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        momentTable.bottomAnchor.constraint(equalTo:view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        momentTable.backgroundColor = view.backgroundColor
    }

    private func transcribeAudio(url: URL, moment: Moment) {
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        let request = SFSpeechURLRecognitionRequest(url: url)
            
        request.shouldReportPartialResults = true

        if (recognizer?.isAvailable)! {

            recognizer?.recognitionTask(with: request) { result, error in
                guard error == nil else { print("Error: \(error!)"); return }
                guard let result = result else { print("No result!"); return }

                let resultTranscription = (result.bestTranscription.formattedString)
                moment.TranscribedNotes = resultTranscription
            }
        } else {
            print ("Device doesn't support speech recognition")
        }
    }
    
    public func UploadFile(deviceURL : URL, toURL: String)
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
            debugPrint(response)
        })
    }
    
    public func InsertMoment(moment: MomentApiModel)
    {
        AF.request("https://aquasarmedia.com/monkeymind/addMoment",
                   method: .post,
                   parameters: moment,
                   encoder: JSONParameterEncoder.default).response { response in
                    debugPrint(response)
                   }
    }
}


