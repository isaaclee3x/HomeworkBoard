//
//  BoardManager.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 5/7/22.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseDatabaseSwift

class BoardManager {
    
    private var CM = ClassManager()
    
    /// Creates a new board if the clas.board[date] value is nil
    /// - Parameters:
    ///   - clas: The class to save the new entries in
    ///   - date: The key to save in
    func createBoard(clas: Class, date: String) async -> Class {
        var clas = clas
        clas.board.entries[date] = [Entry(entry: nil, due: nil, subject: nil)]
        for _ in 0 ..< 9 {
            clas.board.entries[date]?.append(Entry(entry: nil, due: nil, subject: nil))
        }
        await CM.saveClass(clas: clas)
        return clas
    }
    
    /// Checks what entries happen in the week after today
    /// - Parameter clas: The class to check the entries from
    /// - Returns: The entries that are due next week
    func homeworkForTheWeek(clas: Class) -> [Entry] {
        var entries: [Entry] = []
        
        for i in 0 ..< 7 {
            let date = Date().addingTimeInterval(TimeInterval(86400 * i))
            let string = date.toFormat("dd MMMM yyyy")
            if let entryForTheDay = clas.board.entries[string] {
                
                for i in entryForTheDay {
                    entries.append(i)
                }
                entries = entries.filter { entry in
                    entry.entry != " "
                }
            }
        }
        return entries
    }
    
    /// Checks the boards that are created before today and deletes their entries
    /// - Parameter clas: The class to check their boards
    func cleanBoard(clas: Class) async {
        var clas = clas
        let nsdict = clas.board.entries as NSDictionary
        let keys = nsdict.allKeys as! [String]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        var dates: [Date] = []
        
        for key in keys {
            dates.append(dateFormatter.date(from: key)!)
        }
        
        for date in dates {
            if date < Date().addingTimeInterval(-86400) {
                let index = dates.firstIndex(of: date)!
                let clasIndex = clas.board.entries.firstIndex() { $0.key == keys[index] }!
                let key = clas.board.entries[clasIndex].key
                
                clas.board.entries[key] = []
            }
        }
        
        await CM.saveClass(clas: clas)
    }
}
