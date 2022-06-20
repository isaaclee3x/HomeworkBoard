//
//  Structs.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 16/6/22.
//

import Foundation

struct Member: Identifiable, Equatable, Codable {
    
    /// Creates an empty Member (the default)
    
    init() {
        self.username = ""
        self.password = ""
        self.clas = ""
        self.perm = .member
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
    
    init(name: String, date: String) {
        self.name = name
        self.board = Board(date: date)
    }
    
    var id = UUID()
    
    var name: String
    var board: Board
}

struct Board: Identifiable, Equatable, Codable {
    
    init(date: String) {
        self.entries = [date:[]]
        self.cache = []
    }
    
    var id = UUID()
    
    var entries: [String: [Entry]]
    var cache: [String]
}

struct Entry: Identifiable, Equatable, Codable {
    
    init(entry: String?, due: Date?) {
        if entry == nil {
            self.entry = " "
        } else {
            self.entry = entry!
            self.due = due
        }
    }
    
    var id = UUID()
    
    var entry: String
    var due: Date?
}
