//
//  Structs.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 16/6/22.
//

import Foundation
import SwiftUI

protocol Item {
    var itemName: String { get }
}

struct Member: Identifiable, Equatable, Codable, Item {
    
    /// Creates an empty Member
    
    init() {
        self.username = ""
        self.password = ""
        self.clas = ""
        self.perm = .member
    }
    
    var id = UUID()
    
    var itemName: String = "users"
    /// The account's username
    var username: String
    
    /// The account's password (before encryption)
    var password: String
    
    /// The account's class (ensures they only see their own class)
    var clas: String
    
    /// The account's permission type
    var perm: Permissions
    
}

struct Class: Identifiable, Equatable, Codable, Item {
    
    ///Creates and empty class
    init(name: String, date: String) {
        self.name = name
        self.board = Board(date: date)
    }
    
    var itemName: String = "classes"
    var id = UUID()
    
    ///Name of the class
    var name: String
    
    ///The board
    var board: Board
}

struct Board: Identifiable, Equatable, Codable, Item {
    
    ///Creates an empty class
    init(date: String) {
        self.entries = [date:[]]
        self.cache = []
        self.subjects = []
    }
    
    var id = UUID()
    
    var itemName: String = "board"
    var entries: [String: [Entry]]
    var cache: [String]
    var subjects: [Subject]
}

struct Entry: Identifiable, Equatable, Codable, Item {
    
    init(entry: String?, due: String?, subject: Subject?) {
        if entry == nil {
            self.entry = " "
        } else {
            self.subject = subject
            self.entry = entry!
            self.due = due
        }
    }
    
    var id = UUID()
    
    var itemName: String = "entries"
    var subject: Subject?
    var entry: String
    var due: String?
}

struct Subject: Identifiable, Equatable, Codable, Hashable, Item {
    
    var id = UUID()
    
    var itemName: String = "subjects"
    var name: String
    var colour: RGB
}

struct RGB: Identifiable, Equatable, Codable, Hashable, Item {
    
    var id = UUID()
    
    var itemName = "RGB"
    var r: Double
    var g: Double
    var b: Double
}
