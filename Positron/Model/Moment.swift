//
//  Moment.swift
//  Positron
//
//  Created by Sanip Shrestha on 10/17/20.
//  Copyright © 2020 Sanip Shrestha. All rights reserved.
//

import Foundation

public class Moment: NSObject
{
    public var MomentName : String?
    public var MomentDate : Date?
    public var AudioRecordingURL : String?
    public var TranscribedNotes : String?
    
    public func getTime() -> String
    {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
        return formatter.string(from: MomentDate!) 
    }
    
    public func getSmallDate() -> String
    {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd MM yyyy h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
        return formatter.string(from: MomentDate!)
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
