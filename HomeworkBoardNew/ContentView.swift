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
    
    var body: some View {
        if !success {
            NavigationView {
                AuthenticateView(success: $success, MM: MM)
                    .background(color: "lightestBlue")
            }
        } else {
            TabView {
                ClassesView(success: $success, MM: MM)
                    .tabItem {
                        VStack {
                            Text("Classes")
                            Image(systemName: "books.vertical")
                        }
                    }
                
                
                SettingsView(MM: MM)
                    .tabItem {
                        VStack {
                            Text("Settings")
                            Image(systemName: "gear")
                        }
                    }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
