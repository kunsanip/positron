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
    }
    
    public func refreshData(viewby: SummaryViewBy)
    {
        MacawChartView.createChart(viewby: viewby) { (group) in
            super.node = group
            MacawChartView.playAnimation()
        }
    }
    
    public static func createChart(viewby:SummaryViewBy, completion:@escaping (Group)->Void)
    {
        ProgressUtil.barProgress()
        
        createWeeklyData(viewby: viewby, completion: { (weeklySummaries) in
            lastSevenShows = weeklySummaries
            adjustedData   = weeklySummaries.map({$0.CalculatedCount / dataDivisor})
            
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
            let numberText = Text(text: "\(lastSevenShows[i - 1].TotalCount)",align: .max, baseline: .mid, place: .move(x, -30) )
            valueText.fill = Color.white
            numberText.fill = Color.orange
            
            newNodes.append(valueText)
            newNodes.append(numberText)
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
    
    private static func createWeeklyData(viewby: SummaryViewBy, completion:@escaping ([WeeklySummaryBar])->Void)
    {
        var graphData = [WeeklySummaryBar]()
        let cal = Calendar.current
        var comps = cal.dateComponents([.weekOfYear, .yearForWeekOfYear], from: Date())
        comps.weekday = 3// Monday
        
        var startDate = cal.date(from: comps)!
        var thisweek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: startDate)!
        print(startDate)
        
        if (viewby == .thisweek)
        {
            startDate = thisweek
            print(startDate)
        }
        else if (viewby == .lastweek)
        {
            startDate = Calendar.current.date(byAdding: .weekOfYear, value: -2, to: startDate)!
            print(startDate)
        }
        else if (viewby == .thismonth)
        {
            let calendar = NSCalendar.current
            let components = calendar.dateComponents([.year, .month], from: Date())
            startDate = calendar.date(from: components)!
        }
        
        AppDelegate.WebApi.GetAllMoments { (moments) in
            let momentsViewModel = moments.filter({ (moment) -> Bool in
                if let date = moment.getDate(){
                    if (viewby == .lastweek)
                    {
                        return date >= startDate && date < thisweek
                    }
                    return date >= startDate
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
            
            let one     = WeeklySummaryBar(showNumber: "Sun", calculatedCount: Double(sunCount * 200 / 10 ), totalCount:  sunCount)
            let two     = WeeklySummaryBar(showNumber: "Mon", calculatedCount: Double(monCount * 200 / 10 ), totalCount:  monCount)
            let three   = WeeklySummaryBar(showNumber: "Tue", calculatedCount: Double(tueCount * 200 / 10 ), totalCount:  tueCount)
            let four    = WeeklySummaryBar(showNumber: "Wed", calculatedCount: Double(wedCount * 200 / 10 ), totalCount:  wedCount)
            let five    = WeeklySummaryBar(showNumber: "Thu", calculatedCount: Double(thuCount * 200 / 10 ), totalCount:  thuCount)
            let six     = WeeklySummaryBar(showNumber: "Fri", calculatedCount: Double(friCount * 200 / 10 ), totalCount:  friCount)
            let seven   = WeeklySummaryBar(showNumber: "Sat", calculatedCount: Double(satCount * 200 / 10 ), totalCount:  satCount)
            
            graphData = [two, three, four, five, six, seven, one]
            
            completion(graphData)
        }
    }
}
