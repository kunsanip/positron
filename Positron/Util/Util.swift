//
//  Util.swift
//  Positron
//
//  Created by Sanip Shrestha on 10/11/20.
//  Copyright © 2020 Sanip Shrestha. All rights reserved.
//

import Foundation
import Speech
import AVFoundation

class Util
{
    public static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    public static func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization {authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    print("Good to go!")
                } else {
                    print("Transcription permission was declined.")
                }
            }
        }
    }
    
    public static func requestAudioPermissions(session : AVAudioSession)
    {
        session.requestRecordPermission{
            (hasPermission) in
            if hasPermission
            {
                print("accepted")
            }
        }
    }
}
