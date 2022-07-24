//
//  MassCreateUsersView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 20/7/22.
//

import SwiftUI
import Foundation

struct MassCreateUsersView: View {
    
    @State var chooseFile = false
    @State var createFile = false
    
    @State var members = [Member()]
    @Binding var isSheetPresented: Bool
    
    @ObservedObject var MM: MemberManager
    @ObservedObject var CM: ClassManager
    
    var body: some View {
        Form {
            Text("Enter the member's name under the class")
            
            Section("Classes") {
                if let classes = CM.classes {
                    ForEach(classes) { clas in
                        HStack {
                            Text(clas.name)
                            
                            Button {
                                var member = Member()
                                member.clas = clas.name
                                members.append(member)
                                print(members)
                            } label: {
                                Image(systemName: "plus.circle")
                            }
                            .padding()
                        }
                    }
                }
            }
            
            Button {
                let members = self.members.filter() { $0.name != "" }
                for i in members {
                    Task {
                        await MM.saveAccount(member: i, perm: .member)
                    }
                }
            } label: {
                Text("Submit")
            }
            
        }
        .onAppear {
            Task {
                await CM.getClasses()
            }
        }
        .navigationTitle("Create Accounts")
    }
}

struct MassCreateUsersView_Previews: PreviewProvider {
    static var previews: some View {
        MassCreateUsersView(isSheetPresented: .constant(true), MM: MemberManager(), CM: ClassManager())
    }
}
