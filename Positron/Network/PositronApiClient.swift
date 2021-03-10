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
    
    public func Login(username: String, password: String, completion:@escaping (Bool)->Void)
    {
        
        let requestURL = "\(AppDelegate.ApiURL)/login/\(username)/\(password)"
        
        print (requestURL)
        
        AF.request(requestURL).responseJSON { (response) in
            switch response.result {
            case .success:
                let jsonData = response.data
                do{
                    let loginresult  =  try JSONDecoder().decode(ApiResponseModel.self, from: jsonData!)

                    completion(loginresult.Success ?? false)
                }catch {
                    print("Error: \(error)")
                    completion(false)
                }
                
            case .failure( _):
                completion(false)
            }
        }
    }
    
    public func GetTodaysMoments(completion:@escaping ([MomentApiModel])->Void)
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
                    
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.dateFormat = "yyyy-MM-dd"
                  
                    let dateString = formatter.string(from: Date())
                    
                    completion(moments.filter{$0.getDateString() == dateString})
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
    
    public func SignupUser(apiModel: SignupApiModel, completion:@escaping (ApiResponseModel)->Void)
    {
        AF.request("\(AppDelegate.ApiURL)/signupUser",
                   method: .post,
                   parameters: apiModel,
                   encoder: JSONParameterEncoder.default).response { response in
                        switch response.result {
                        case .success:
                            let jsonData = response.data
                            do{
                                let signupresult  =  try JSONDecoder().decode(ApiResponseModel.self, from: jsonData!)

                                completion(signupresult)
                            }catch {
                                print("Error: \(error)")
                                let vm = ApiResponseModel()
                                vm.Success = false
                                vm.Message = "Failed to sign up. An unknown error has occured."
                                completion(vm)
                            }
                        case .failure(_):
                            let vm = ApiResponseModel()
                            vm.Success = false
                            vm.Message = "Failed to sign up. An unknown error has occured."
                            completion(vm)
                        }
                   }
    }
    
    public func GetUsernameForExplorer(completion: @escaping (String)->Void)
    {
        let requestURL = "\(AppDelegate.ApiURL)/GetUsernameForExplorer/"
        
        print (requestURL)
        
        AF.request(requestURL).responseJSON { (response) in
            switch response.result {
            case .success:
                let jsonData = response.data
                do{
                    let explorerResult  =  try JSONDecoder().decode(ApiResponseModel.self, from: jsonData!)
                    

                    completion(explorerResult.Message ?? "")
                }catch {
                    print("Error: \(error)")
                    completion("")
                }
                
            case .failure( _):
                completion("")
            }
        }
    }
        
    public func InsertMoment(moment: MomentApiModel, completion:@escaping (String)->Void)
    {
        AF.request("\(AppDelegate.ApiURL)/addMoment",
                   method: .post,
                   parameters: moment,
                   encoder: JSONParameterEncoder.default).response { response in
                    print("After this")
                    debugPrint(response)
                    completion("")
                   }
    }
    
    public func UpdateMoment(moment: MomentApiModel, completion:@escaping (String)->Void)
    {
        AF.request("\(AppDelegate.ApiURL)/updateMoment",
                   method: .post,
                   parameters: moment,
                   encoder: JSONParameterEncoder.default).response { response in
                    print("After this")
                    debugPrint(response)
                    completion("")
                   }
    }

    public func DeleteMoment(momentID : Int, completion:@escaping (String)->Void)
    {
        let params = ["MomentID": momentID]
        
        AF.request("\(AppDelegate.ApiURL)/deleteMoment",
                   method: .delete,
                   parameters: params,
                   encoder: JSONParameterEncoder.default).response { response in
                    completion(response.description)
                   }
    }
    
}
