//
//  SettingsView.swift
//  AltTextGenerator
//
//  Created by Gary Riches on 01/07/2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var apiKey: String = ""
    @State private var showApiKey: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("OpenAI API Key")) {
                    HStack {
                        if showApiKey {
                            TextField("Enter API Key", text: $apiKey)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            SecureField("Enter API Key", text: $apiKey)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        Button(action: {
                            showApiKey.toggle()
                        }) {
                            Image(systemName: showApiKey ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    HStack {
                        Button("Save") {
                            if apiKey.isEmpty {
                                alertMessage = "Please enter an API key before saving"
                            } else if KeychainService.shared.save(apiKey) {
                                alertMessage = "API Key saved successfully"
                            } else {
                                alertMessage = "Failed to save API Key"
                            }
                            showAlert = true
                        }
                        .disabled(apiKey.isEmpty)
                        
                        Spacer()
                        
                        Button("Clear") {
                            if KeychainService.shared.delete() {
                                apiKey = ""
                                alertMessage = "API Key removed successfully"
                            } else {
                                alertMessage = "No API Key to clear"
                            }
                            showAlert = true
                        }
                        .foregroundColor(.red)
                    }
                }
                
                Section(header: Text("How to Get an API Key")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("1. Visit platform.openai.com")
                            .font(.footnote)
                        Text("2. Sign in or create an account")
                            .font(.footnote)
                        Text("3. Go to API Keys in your account settings")
                            .font(.footnote)
                        Text("4. Click 'Create new secret key'")
                            .font(.footnote)
                        Text("5. Copy the key and paste it above")
                            .font(.footnote)
                        Text("⚠️ Keep your API key private and secure")
                            .font(.footnote)
                            .foregroundColor(.orange)
                    }
                    .padding(.vertical, 5)
                }
                
                Section(footer: Text("Your API key is stored securely in the device keychain. You will need to add credits to your OpenAI account to use the API.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
            .alert("Settings", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
        .onAppear {
            if let savedKey = KeychainService.shared.retrieve() {
                apiKey = savedKey
            }
        }
    }
}

#Preview {
    SettingsView()
}