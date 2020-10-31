//
//  MomentApiModel.swift
//  Positron
//
//  Created by Sanip Shrestha on 10/24/20.
//  Copyright © 2020 Sanip Shrestha. All rights reserved.
//

import Foundation


public class MomentApiModel: Codable
{
    public var MomentName : String?
    public var AudioRecordingURL : String?
    public var TranscribedNotes : String?
    public var MomentDate : String?
    
    enum CodingKeys: String, CodingKey
    {
        case  MomentName = "MomentName"
        case  AudioRecordingURL = "AudioRecordingURL"
        case  TranscribedNotes = "TranscribedNotes"
        case  MomentDate = "MomentDate"
    }
    
    public func getTime() -> String
    {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let convMomentDate = formatter.date(from: MomentDate!)
        {
            formatter.dateFormat = "h:mm a"
            formatter.amSymbol = "AM"
            formatter.pmSymbol = "PM"
            
            return formatter.string(from: convMomentDate)
        }
        
        return ""
    }
    
    public func getSmallDate() -> String
    {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let convMomentDate = formatter.date(from: MomentDate!)
        {
            formatter.dateFormat = "dd MM yyyy h:mm a"
            formatter.amSymbol = "AM"
            formatter.pmSymbol = "PM"
            return formatter.string(from: convMomentDate)
        }
        return ""

    }
    
    public func listPropertiesWithValues(reflect: Mirror? = nil) ->  String {
        let mirror = reflect ?? Mirror(reflecting: self)
        
        var result = ""
        
        for (index, attr) in mirror.children.enumerated() {
            if let property_name = attr.label {
                //You can represent the results however you want here!!!
                result += ("\(mirror.description) \(index): \(property_name) = \(attr.value)")
            }
        }
        
        return result
    }
    
}
