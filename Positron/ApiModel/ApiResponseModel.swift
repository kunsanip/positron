//
//  ApiResponseModel.swift
//  Positron
//
//  Created by Sanip Shrestha on 11/7/20.
//  Copyright © 2020 Sanip Shrestha. All rights reserved.
//

import Foundation

public class ApiResponseModel: Codable
{
    public var Success : Bool?
    public var Data : String?
    public var Message: String?
    
    enum CodingKeys: String, CodingKey
    {
        case Success = "success"
        case Data = "data"
        case Message = "message"
    }
    
}
