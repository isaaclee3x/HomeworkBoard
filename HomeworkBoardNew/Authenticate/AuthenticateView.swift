//
//  AuthenticateView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 16/6/22.
//

import SwiftUI

struct AuthenticateView: View {
    
    @State var username = ""
    @State var password = ""
    
    @Binding var success: Bool
    @ObservedObject var MM: MemberManager
    @ObservedObject var CM: ClassManager
    
    @State var createNewAccount = false
    @State var chooseClass = false
    @State var loginFail = false
    
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
                Task {
                    await MM.auth(username: username, password: password) {
                        if MM.member?.clas == "" {
                            if MM.member?.perm == .member || MM.member?.perm == .leader {
                                chooseClass = true                                
                            } else {
                                success = true
                            }
                        } else {
                            success = true
                        }
                    } not: {
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
        .onAppear {
            MM.member = nil
        }
        .alert("Login Failed", isPresented: $loginFail) {
            Button("Create", role: .cancel) {
                createNewAccount = true
            }
            
            Button("Cancel", role: .destructive) {
                loginFail = false
            }
        }
    }
}
