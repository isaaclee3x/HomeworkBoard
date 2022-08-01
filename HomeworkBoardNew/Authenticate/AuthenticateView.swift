//
//  AuthenticateView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 16/6/22.
//

import SwiftUI
import Firebase

struct AuthenticateView: View {
    
    @State var username = ""
    @State var password = ""
    @Binding var member: Member
    
    @Binding var success: Bool
    var MM = MemberManager()
    var CM = ClassManager()
    
    @State var createNewAccount = false
    @State var chooseClass = false
    @State var loginFail = false
    @State var resetDefaultPassword = false
    
    var body: some View {
        VStack {
            Text("**Login** to your account")
                .header()
            
            TextField("Username", text: $username)
                .disableAutocorrection(true)
                .credStyle(width: 300, height: 60)
            
            SecureField("Password", text: $password)
                .credStyle(width: 300, height: 60)
            
            Button {
                let ref = Database.database().reference()
                
                ref.child("users").child(username).observeSingleEvent(of: .value) { snapshot in
                    let value = snapshot.value as? String
                    guard value != nil else { loginFail = true; return }
                    let decoder = JSONDecoder()
                    
                    var member = try? decoder.decode(Member.self, from: value!.data(using: .utf8)!)
                    let edit = member
                    member?.password = (edit?.password.fromBase64())!
                    self.member = member!
                    if member?.name == username && member?.password == password {
                        if member?.clas == "" {
                            if member?.perm == .member || member?.perm == .leader {
                                chooseClass = true
                            } else {
                                success = true
                            }
                        } else {
                            success = true
                        }
                    }
                    else if member?.password == MM.defaultPassword {
                        resetDefaultPassword = true
                    } else {
                        loginFail = true
                    }
                }
            } label: {
                Text("Login")
                    .bold()
            }
            .bottomButton()
            .padding()
            
            HStack {
                Text("Create Account")
                    .bold()
                    .font(.system(size: 15))
                    .foregroundColor(Color("murkyBlue"))
                    .onTapGesture {
                        createNewAccount = true
                    }
            }
        }
        .background(color: "lightestBlue")
        .sheet(isPresented: $createNewAccount) {
            NewAccountView(isSheetPresented: $createNewAccount, MM: MM, CM: CM)
        }
        .sheet(isPresented: $chooseClass) {
            NoClassChooseView(username: $username, success: $success, isSheetPresented: $chooseClass, MM: MM, CM: CM)
        }
        .sheet(isPresented: $resetDefaultPassword) {
            success = true
        } content: {
            ChangeDefaultPassword(isSheetPresented: $resetDefaultPassword, member: $member, MM: MM)
        }
        .alert("Login Failed", isPresented: $loginFail) {
            Button("Cancel", role: .destructive) {
                loginFail = false
            }
            
            Button("Create", role: .cancel) {
                createNewAccount = true
            }
        }
    }
}
