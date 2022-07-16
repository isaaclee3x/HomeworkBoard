//
//  BoardManager.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 19/6/22.
//

import Foundation
import SwiftUI

class CacheManager {
    
    @ObservedObject var CM = ClassManager()
    
    /// Updates the classes cache based on what the user did
    /// - Parameters:
    ///   - clas: The class' cache to append to
    ///   - what: What the user did
    func updateCache(clas: Class, did what: String) async {
        var clas = clas
        clas.board.cache.append(what)
        await CM.saveClass(clas: clas)
    }
}
