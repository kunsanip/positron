//
//  WeeklySummaryBar.swift
//  Positron
//
//  Created by Sanip Shrestha on 10/18/20.
//  Copyright © 2020 Sanip Shrestha. All rights reserved.
//

import Foundation

public struct WeeklySummaryBar
{
    public var ShowNumber : String
    public var ViewCount : Double
    
    init(showNumber: String, viewCount : Double)
    {
        ShowNumber = showNumber
        ViewCount = viewCount
    }
}
