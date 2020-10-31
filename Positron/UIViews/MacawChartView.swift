//
//  MacawChartView.swift
//  Positron
//
//  Created by Sanip Shrestha on 10/18/20.
//  Copyright © 2020 Sanip Shrestha. All rights reserved.
//

import Foundation
import Macaw

public class MacawChartView : MacawView
{

    static let lastSevenShows           = createDummyData()
    static let maxValue                 = 6000
    static let maxValueLineHeight       = 180
    static let lineWidth :Double        = 375
    
    static let dataDivisor              = Double(maxValue/maxValueLineHeight)
    static let adjustedData :[Double]   = lastSevenShows.map({$0.ViewCount / dataDivisor})
    static var animation : [Animation]  = []
    
    required init(coder aDecoder: NSCoder) {
        super.init(node: MacawChartView.createChart(), coder: aDecoder)!
        self.backgroundColor = .clear
    }
    
    public static func createChart() -> Group
    {
        var items: [Node] = addYAxisItem() + addXAxisItem()
        items.append(createBars())
        
        return Group(contents: items, place: .identity)
    }
    
    private static func addYAxisItem() -> [Node]
    {
        let maxLines                = 6
        let lineInterval            = Int(maxValue/maxLines)
        let yAxisHeight : Double    = 200
        let lineSpacing : Double    = 30
        
        var newNodes: [Node]        = []
        
        for i in 1...maxLines
        {
            let y = yAxisHeight - (Double(i) * lineSpacing)
            let valueLine = Line(x1: -5, y1: y, x2: lineWidth, y2: y).stroke(fill: Color.white.with(a: 0.10))
            let valueText = Text(text: "\(i * lineInterval)", fill: Color.white, align: .max, baseline: .mid, place: .move(dx: -10, dy : y))
            
            newNodes.append(valueLine)
            newNodes.append(valueText)
        }
        
        let yAxis = Line(0, 0, 0, yAxisHeight).stroke(fill: Color.white.with(a: 0.25))
        newNodes.append(yAxis)
        
        return newNodes
    }
    
    private static func addXAxisItem() -> [Node]
    {
        let chartBaseY: Double  = 200
        var newNodes: [Node]    = []
        
        for i in 1...adjustedData.count
        {
            let x = Double(i * 50)
            let valueText = Text(text: lastSevenShows[i - 1].ShowNumber,align: .max, baseline: .mid, place: .move(x, chartBaseY + 15) )
            
            valueText.fill = Color.white
            
            newNodes.append(valueText)
        }
        
        let xAxis = Line(x1: 0, y1: chartBaseY, x2: lineWidth, y2: chartBaseY).stroke(color: Color.white.with(a: 0.25))
        newNodes.append(xAxis)
        
        return newNodes
    }
    
    private static func createBars() -> Group
    {
        let fill = LinearGradient(degree: 90, from: Color(val: 0xff4704), to: Color(val: 0xff4704).with(a: 0.33))
        let items = adjustedData.map {_ in Group()}
        
        animation = items.enumerated().map { (i: Int, item: Group) in
            item.contentsVar.animation(delay: Double(i) * 0.1){ t in
                let height = adjustedData[i] * t
                let rect = Rect(Double(i * 50 + 25), 200-height, 30, height)
                return [rect.fill(with: fill)]
            }
        }
        
        return items.group()
    }
    
    static func playAnimation()
    {
        animation.combine().play()
    }
    
    private static func createDummyData() -> [WeeklySummaryBar]
    {
        let one     = WeeklySummaryBar(showNumber: "Mon", viewCount: 3465)
        let two     = WeeklySummaryBar(showNumber: "Tue", viewCount: 3465)
        let three   = WeeklySummaryBar(showNumber: "Wed", viewCount: 3465)
        let four    = WeeklySummaryBar(showNumber: "Thu", viewCount: 3465)
        let five    = WeeklySummaryBar(showNumber: "Fri", viewCount: 3465)
        let six     = WeeklySummaryBar(showNumber: "Sat", viewCount: 3465)
        let seven   = WeeklySummaryBar(showNumber: "Sun", viewCount: 3465)
        
        return [one, two, three, four, five, six, seven]
    }
}
