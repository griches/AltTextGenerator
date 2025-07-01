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
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("OpenAI API Key", systemImage: "key.fill")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            if showApiKey {
                                TextField("sk-proj-...", text: $apiKey)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.system(.body, design: .monospaced))
                            } else {
                                SecureField("Enter your OpenAI API key", text: $apiKey)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.system(.body, design: .monospaced))
                            }
                            
                            Button(action: {
                                showApiKey.toggle()
                            }) {
                                Image(systemName: showApiKey ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.blue)
                                    .frame(width: 24, height: 24)
                            }
                        }
                        
                        if !apiKey.isEmpty {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("API key entered")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                Spacer()
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Actions") {
                    Button("Save API Key") {
                        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmedKey.isEmpty {
                            alertMessage = "Please enter an API key before saving"
                        } else if KeychainService.shared.save(trimmedKey) {
                            alertMessage = "API Key saved successfully! You can now generate alt text."
                        } else {
                            alertMessage = "Failed to save API Key to secure storage"
                        }
                        showAlert = true
                    }
                    .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    Button("Clear API Key") {
                        if KeychainService.shared.delete() {
                            apiKey = ""
                            alertMessage = "API Key removed successfully"
                        } else {
                            apiKey = ""
                            alertMessage = "API Key cleared from field"
                        }
                        showAlert = true
                    }
                    .foregroundColor(.red)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("How to Get an API Key", systemImage: "questionmark.circle.fill")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: 12) {
                                Text("1")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                Text("Visit platform.openai.com")
                                    .font(.subheadline)
                                Spacer()
                            }
                            
                            HStack(alignment: .top, spacing: 12) {
                                Text("2")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                Text("Sign in or create an account")
                                    .font(.subheadline)
                                Spacer()
                            }
                            
                            HStack(alignment: .top, spacing: 12) {
                                Text("3")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                Text("Go to API Keys in your account settings")
                                    .font(.subheadline)
                                Spacer()
                            }
                            
                            HStack(alignment: .top, spacing: 12) {
                                Text("4")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                Text("Click 'Create new secret key'")
                                    .font(.subheadline)
                                Spacer()
                            }
                            
                            HStack(alignment: .top, spacing: 12) {
                                Text("5")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                Text("Copy the key and paste it above")
                                    .font(.subheadline)
                                Spacer()
                            }
                        }
                        
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Keep your API key private and secure")
                                .font(.footnote)
                                .foregroundColor(.orange)
                        }
                        .padding(.top, 8)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding(.vertical, 8)
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