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
    public static func getDateFromString(dateString: String)-> Date?
    {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd-MM-yyyy"
        
        return formatter.date(from: dateString)
    }
    
    public static func getCurrentDateString() -> String
    {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMddhhmmss"
        
        let date = Date()
        return  formatter.string(from: date)
    }
    
    public static func getUrlFriendlyDateString(date: Date) -> String
    {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd-MM-yyyy"
        
        return  formatter.string(from: date)
    }
    
    public static func getDayFromDate(dateString :String)-> String
    {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
         
        let date = formatter.date(from: dateString)!
        
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.day, from: date)
        return myCalendar.veryShortWeekdaySymbols[weekDay-1]
    }

    private func firstDayOfMonth(date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }

}

extension Date {
    func startOfWeek(using calendar: Calendar = .gregorian) -> Date {
        calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
    }
    
    func startOfMonth(using calendar: Calendar = .gregorian) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
    }
    
    func toString(using calendar: Calendar = .gregorian) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd-MM-yyyy"
        
        return  formatter.string(from: self)
    }
}

extension Calendar {
    static let gregorian = Calendar(identifier: .gregorian)
}
