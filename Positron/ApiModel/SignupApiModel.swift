//
//  SignupApiModel.swift
//  Positron
//
//  Created by Sanip Shrestha on 2/13/21.
//  Copyright © 2021 Sanip Shrestha. All rights reserved.
//

import Foundation


public class SignupApiModel:Codable
{
    public var Firstname: String?
    
    public var Lastname: String?
    public var UserID: String?
    public var Password: String?
    public var Phonenumber: String?
    public var DOB: String?
    
    enum CodingKeys: String, CodingKey
    {
        case Firstname = "Firstname"
        case Lastname = "Lastname"
        case UserID = "UserID"
        case Password = "Password"
        case Phonenumber = "Phonenumber"
        case DOB = "DOB"
    }
}
