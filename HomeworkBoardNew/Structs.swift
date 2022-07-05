//
//  Structs.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 16/6/22.
//

import Foundation
import SwiftUI

struct Member: Identifiable, Equatable, Codable {
    
    /// Creates an empty Member
    
    init() {
        self.username = ""
        self.password = ""
        self.clas = ""
        self.perm = .admin
    }
    
    var id = UUID()
    
    /// The account's username
    var username: String
    
    /// The account's password (before encryption)
    var password: String
    
    /// The account's class (ensures they only see their own class)
    var clas: String
    
    /// The account's permission type
    var perm: Permissions
    
}

struct Class: Identifiable, Equatable, Codable {
    
    ///Creates and empty class
    init(name: String, date: String) {
        self.name = name
        self.board = Board(date: date)
    }
    
    var id = UUID()
    
    ///Name of the class
    var name: String
    
    ///The board
    var board: Board
}

struct Board: Identifiable, Equatable, Codable {
    
    ///Creates an empty class
    init(date: String) {
        self.entries = [date:[]]
        self.cache = []
    }
    
    var id = UUID()
    
    var entries: [String: [Entry]]
    var cache: [String]
}

struct Entry: Identifiable, Equatable, Codable {
    
    init(entry: String?, due: String?) {
        if entry == nil {
            self.entry = " "
        } else {
            self.subject = nil
            self.entry = entry!
            self.due = due
        }
    }
    
    var id = UUID()
    
    var subject: Subject?
    var entry: String
    var due: String?
}

struct Subject: Identifiable, Equatable, Codable {
    
    var id = UUID()
    
    var name: String
    var colour: RGB
}

struct RGB: Identifiable, Equatable, Codable {
    
    var id = UUID()
    
    var r: Double
    var g: Double
    var b: Double
}
