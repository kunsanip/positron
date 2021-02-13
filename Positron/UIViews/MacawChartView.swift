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
    static let maxValue                 = 5
    static let maxValueLineHeight       = 1
    static let lineWidth :Double        = 375
    static let dataDivisor              = Double(maxValue/maxValueLineHeight)
    static var lastSevenShows           = [WeeklySummaryBar]()
    static var adjustedData :[Double]   = [Double]()
    static var animation : [Animation]  = []
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(node: MacawChartView.createBars(), coder: aDecoder)!
        self.backgroundColor = .clear
        MacawChartView.createChart { (group) in
            super.node = group
            MacawChartView.playAnimation()
        }
    }
    
    public static func createChart(completion:@escaping (Group)->Void)
    {
        ProgressUtil.barProgress()
        createDummyData(completion: { (weeklySummaries) in
            lastSevenShows = weeklySummaries
            adjustedData   = weeklySummaries.map({$0.ViewCount / dataDivisor})
            
            var items: [Node] = addYAxisItem() + addXAxisItem()
            items.append(createBars())
            
            completion(Group(contents: items, place: .identity))
            ProgressUtil.dismiss()
        })
    }
    
    private static func addYAxisItem() -> [Node]
    {
        let maxLines                = 5
        let lineInterval            = Int(maxValue/maxLines)
        let yAxisHeight : Double    = 200
        let lineSpacing : Double    = 40
        
        var newNodes: [Node]        = []
        
        for i in 1...maxLines
        {
            let y = yAxisHeight - (Double(i) * lineSpacing)
            let valueLine = Line(x1: -5, y1: y, x2: lineWidth, y2: y).stroke(fill: Color.white.with(a: 0.10))
            let valueText = Text(text: "\(i * lineInterval * 10)", fill: Color.white, align: .max, baseline: .mid, place: .move(dx: -10, dy : y))
            
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
            let valueText = Text(text: "\(lastSevenShows[i - 1].ShowNumber)",align: .max, baseline: .mid, place: .move(x, chartBaseY + 15) )
  
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
            item.contentsVar.animation(delay: Double(i) * 0.01){ t in
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
    
    private static func createDummyData(completion:@escaping ([WeeklySummaryBar])->Void)
    {
        var graphData = [WeeklySummaryBar]()
        
        AppDelegate.WebApi.GetAllMoments { (moments) in
            let momentsViewModel = moments.filter({ (moment) -> Bool in
                if let date = moment.getDate(){
                    return date >= Date().startOfWeek()
                }
                return false
            })
            
            let monCount = momentsViewModel.filter { $0.getDays() == 2}.count
            let tueCount = momentsViewModel.filter { $0.getDays() == 3}.count
            let wedCount = momentsViewModel.filter { $0.getDays() == 4 }.count
            let thuCount = momentsViewModel.filter { $0.getDays() == 5 }.count
            let friCount = momentsViewModel.filter { $0.getDays() == 6}.count
            let satCount = momentsViewModel.filter { $0.getDays() == 7 }.count
            let sunCount = momentsViewModel.filter { $0.getDays() == 1 }.count
            
            let one     = WeeklySummaryBar(showNumber: "Sun", viewCount: Double(sunCount * 200 / 10 ))
            let two     = WeeklySummaryBar(showNumber: "Mon", viewCount: Double(monCount * 200 / 10 ))
            let three   = WeeklySummaryBar(showNumber: "Tue", viewCount: Double(tueCount * 200 / 10 ))
            let four    = WeeklySummaryBar(showNumber: "Wed", viewCount: Double(wedCount * 200 / 10 ))
            let five    = WeeklySummaryBar(showNumber: "Thu", viewCount: Double(thuCount * 200 / 10 ))
            let six     = WeeklySummaryBar(showNumber: "Fri", viewCount: Double(friCount * 200 / 10 ))
            let seven   = WeeklySummaryBar(showNumber: "Sat", viewCount: Double(satCount * 200 / 10 ))
            
            graphData = [one, two, three, four, five, six, seven]
            
            completion(graphData)
        }
    }
}
