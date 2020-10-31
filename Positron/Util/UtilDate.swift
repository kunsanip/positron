//
//  UtilDate.swift
//  Positron
//
//  Created by Sanip Shrestha on 10/31/20.
//  Copyright © 2020 Sanip Shrestha. All rights reserved.
//

import Foundation

public class UtilDate
{
    public static func getCurrentDateString() -> String
    {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        
        let date = Date()
        return  formatter.string(from: date)
    }
}
