//
//  BoardManager.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 5/7/22.
//

import Foundation
import SwiftUI

class BoardManager {

    /// Shows which entries are due by x number of days
    /// - Parameter clas: The class to check the entries from
    /// - Parameter days: The number of days from today
    /// - Returns: The entries that are due depending on the number of days
    func homeworkDue(clas: Class, in days: Int) -> [Entry] {
        var entries: [Entry] = []
        
        let date = Date().addingTimeInterval(TimeInterval(86400 * days))
        let string = date.toFormat("dd MMMM yyyy")
        if let entryForTheDay = clas.board.entries[string] {
            
            for i in entryForTheDay {
                entries.append(i)
            }
            entries = entries.filter { entry in
                entry.entry != " "
            }
        }
        return entries
    }
    
    /// Checks the boards that are created before today and deletes their entries
    /// - Parameter clas: The class to check
    func cleanBoard(clas: Class) async {
        var clas = clas
        let nsdict = clas.board.entries as NSDictionary
        let keys = nsdict.allKeys as! [String]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        var dates: [Date] = []
        
        for key in keys {
            dates.append(dateFormatter.date(from: key)!)
        }
        
        for date in dates {
            if date.addingTimeInterval(86400) < Date() {
                let index = dates.firstIndex(of: date)!
                let clasIndex = clas.board.entries.firstIndex() { $0.key == keys[index] }!
                let key = clas.board.entries[clasIndex].key
                
                clas.board.entries.removeValue(forKey: key)
            }
        }
        
        await ClassManager().saveClass(clas: clas)
    }
}
