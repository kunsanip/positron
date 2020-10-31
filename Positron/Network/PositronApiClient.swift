//
//  PositronApiClient.swift
//  Positron
//
//  Created by Sanip Shrestha on 10/24/20.
//  Copyright © 2020 Sanip Shrestha. All rights reserved.
//

import Foundation
import Alamofire

public class PositronApiClient
{
    public func GetAllMoments(completion:@escaping ([MomentApiModel])->Void)
    {
        var moments = [MomentApiModel]()
        let requestURL = "\(AppDelegate.ApiURL)/getAllMoments/\(AppDelegate.UserID)/\(AppDelegate.Password)"
        
        print (requestURL)
        
        AF.request(requestURL).responseJSON { (response) in
            switch response.result {
            case .success:
                let jsonData = response.data
                do{
                    moments =  try JSONDecoder().decode([MomentApiModel].self, from: jsonData!)
                    
                    completion(moments)
                }catch {
                    print("Error: \(error)")
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    public func UploadFile(deviceURL : URL, fileWithName: String)
    {
        let toURL = "\(AppDelegate.ApiURL)/uploadRecording"
        let fileName = deviceURL.lastPathComponent
        guard let audioFile: Data = try? Data (contentsOf: deviceURL) else {return}
        
        let params = ["username": AppDelegate.UserID,
                      "password":AppDelegate.Password]
        
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in params {
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
            multipartFormData.append(audioFile, withName: fileWithName, fileName: fileName, mimeType: "audio/wav")
            
        }, to: toURL)
        .responseString(completionHandler: { (response) in
            print(response)
        })
    }
}
