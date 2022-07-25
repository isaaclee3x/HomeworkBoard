//
//  MassCreateUsersView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 20/7/22.
//

import SwiftUI
import Foundation

struct MassCreateUsersView: View {
    
    @State var chosenClass = ""
    @State var members: [String: [Member]] = [:]
    @State var mutableMember = Member()
    
    @Binding var isSheetPresented: Bool
    @ObservedObject var MM: MemberManager
    
    var classes: [String]
    
    var body: some View {
        Form {
            ForEach(classes, id: \.self) { clas in
                Section(clas) {
                    if let members = members[clas] {
                        ForEach(0 ..< members.count, id: \.self) { member in
                            let binding = Binding {
                                return members[member].name
                            } set: { newValue in
                                self.members[clas]![member].name = newValue
                            }
                            
                            TextField("Name", text: binding)
                                .disableAutocorrection(true)
                                .onSubmit {
                                    var member = Member()
                                    member.perm = .member
                                    member.clas = clas
                                    member.password = MM.defaultPassword
                                    self.members[clas]?.append(member)
                                }
                        }
                    }
                }
            }
            
            Button {
                let values = self.members as NSDictionary
                
                let value = values.allValues as? [[Member]] ?? []
                guard value != [] else { return }
                let members = value[0]
                Task {
                    for member in members {
                        await MM.saveAccount(member: member, perm: .member)
                    }
                }
                
                isSheetPresented = false
                
            } label: {
                Text("Submit")
            }
        }
        .onAppear {
            for clas in classes {
                if members[clas] == nil { members[clas] = [] }
                var member = Member()
                member.perm = .member
                member.clas = clas
                member.password = MM.defaultPassword
                members[clas]?.append(member)
            }
        }
    }
}

struct MassCreateUsersView_Previews: PreviewProvider {
    static var previews: some View {
        MassCreateUsersView(isSheetPresented: .constant(false), MM: MemberManager(), classes: [])
    }
}
