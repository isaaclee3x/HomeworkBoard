//
//  ContentView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 16/6/22.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var MM = MemberManager()
    @StateObject var CM = ClassManager()
    
    @State var success = false
    @State var chooseClassView = false
    
    var body: some View {
        if !success {
            NavigationView {
                AuthenticateView(success: $success, MM: MM, CM: CM)
                
            }
        } else {
            NavigationView {
                ClassesView(success: $success, chooseClassView: $chooseClassView, MM: MM)
            }
        }
    }
}
