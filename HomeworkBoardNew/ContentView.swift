//
//  ContentView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 16/6/22.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var MM = AccountManager()
    @StateObject var CM = ClassManager()
    
    @State var success = false
    
    var body: some View {
        NavigationView {
            if !success {
                AuthenticateView(success: $success, MM: MM)
            } else {
                ClassesView(MM: MM)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
