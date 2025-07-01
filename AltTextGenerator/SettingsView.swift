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
    @State private var hasAPIKey: Bool = false
    @State private var autoCopyToClipboard: Bool = false
    @State private var autoGenerateAltText: Bool = false
    @FocusState private var isAPIKeyFieldFocused: Bool
    
    let shouldFocusAPIKey: Bool
    
    init(shouldFocusAPIKey: Bool = false) {
        self.shouldFocusAPIKey = shouldFocusAPIKey
    }
    
    var body: some View {
        NavigationStack {
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
                                    .font(.body)
                                    .focused($isAPIKeyFieldFocused)
                                    .accessibilityLabel("API Key")
                                    .accessibilityHint("Enter your OpenAI API key here. The key is currently visible.")
                                    .accessibilityIdentifier("apiKeyTextField")
                            } else {
                                SecureField("Enter your OpenAI API key", text: $apiKey)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.body)
                                    .focused($isAPIKeyFieldFocused)
                                    .accessibilityLabel("API Key")
                                    .accessibilityHint("Enter your OpenAI API key here. The key is currently hidden for security.")
                                    .accessibilityIdentifier("apiKeySecureField")
                            }
                            
                            Button(action: {
                                showApiKey.toggle()
                            }) {
                                Image(systemName: showApiKey ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.blue)
                                    .frame(width: 24, height: 24)
                            }
                            .accessibilityLabel(showApiKey ? "Hide API key" : "Show API key")
                            .accessibilityHint("Toggle visibility of your API key text")
                            .accessibilityIdentifier("toggleApiKeyVisibilityButton")
                        }
                        
                        if !apiKey.isEmpty {
                            HStack(alignment: .center, spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .frame(width: 16, height: 16)
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
                        saveAPIKey()
                    }
                    .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityLabel("Save API Key")
                    .accessibilityHint(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Enter an API key first before saving" : "Saves your API key securely to the device keychain")
                    .accessibilityIdentifier("saveApiKeyButton")
                    
                    Button("Clear API Key") {
                        if KeychainService.shared.delete() {
                            apiKey = ""
                            alertMessage = "API Key removed successfully"
                            hasAPIKey = false
                            // Announce removal to VoiceOver
                            UIAccessibility.post(notification: .announcement, argument: "API Key cleared")
                        } else {
                            apiKey = ""
                            alertMessage = "API Key cleared from field"
                            hasAPIKey = false
                        }
                        showAlert = true
                    }
                    .foregroundColor(.red)
                    .accessibilityLabel("Clear API Key")
                    .accessibilityHint("Removes your API key from secure storage and clears the text field")
                    .accessibilityIdentifier("clearApiKeyButton")
                    
                    Toggle("Auto-generate alt text", isOn: $autoGenerateAltText)
                        .toggleStyle(SwitchToggleStyle())
                        .accessibilityLabel("Auto-generate alt text")
                        .accessibilityHint(autoGenerateAltText ? "When enabled, alt text is automatically generated as soon as an image is selected. Currently enabled." : "When enabled, alt text is automatically generated as soon as an image is selected. Currently disabled.")
                        .accessibilityIdentifier("autoGenerateToggle")
                    
                    Toggle("Auto-copy to clipboard", isOn: $autoCopyToClipboard)
                        .toggleStyle(SwitchToggleStyle())
                        .accessibilityLabel("Auto-copy to clipboard")
                        .accessibilityHint(autoCopyToClipboard ? "When enabled, generated alt text is automatically copied to clipboard. Currently enabled." : "When enabled, generated alt text is automatically copied to clipboard. Currently disabled.")
                        .accessibilityIdentifier("autoCopyToggle")
                }
                
                if !hasAPIKey {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("How to Get an API Key")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .accessibilityAddTraits(.isHeader)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: 12) {
                                Text("1")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .accessibilityHidden(true)
                                Text("Visit platform.openai.com")
                                    .font(.subheadline)
                                Spacer()
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Step 1: Visit platform.openai.com")
                            
                            HStack(alignment: .top, spacing: 12) {
                                Text("2")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .accessibilityHidden(true)
                                Text("Sign in or create an account")
                                    .font(.subheadline)
                                Spacer()
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Step 2: Sign in or create an account")
                            
                            HStack(alignment: .top, spacing: 12) {
                                Text("3")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .accessibilityHidden(true)
                                Text("Go to API Keys in your account settings")
                                    .font(.subheadline)
                                Spacer()
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Step 3: Go to API Keys in your account settings")
                            
                            HStack(alignment: .top, spacing: 12) {
                                Text("4")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .accessibilityHidden(true)
                                Text("Click 'Create new secret key'")
                                    .font(.subheadline)
                                Spacer()
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Step 4: Click 'Create new secret key'")
                            
                            HStack(alignment: .top, spacing: 12) {
                                Text("5")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .accessibilityHidden(true)
                                Text("Copy the key and paste it above")
                                    .font(.subheadline)
                                Spacer()
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Step 5: Copy the key and paste it above")
                        }
                        
                        HStack(alignment: .center, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .frame(width: 16, height: 16)
                                .accessibilityHidden(true)
                            Text("Keep your API key private and secure")
                                .font(.footnote)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Security warning: Keep your API key private and secure")
                        .accessibilityAddTraits(.isStaticText)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(footer: Text("Your API key is stored securely in the device keychain. You will need to add credits to your OpenAI account to use the API.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Auto-save API key if user has entered one but not saved it
                        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
                        let savedKey = KeychainService.shared.retrieve() ?? ""
                        
                        if !trimmedKey.isEmpty && trimmedKey != savedKey {
                            let _ = KeychainService.shared.save(trimmedKey)
                        }
                        
                        dismiss()
                    }
                    .accessibilityLabel("Done")
                    .accessibilityHint("Closes settings and returns to the main screen")
                    .accessibilityIdentifier("doneButton")
                }
            }
            .alert("Settings", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
        .onAppear {
            if let savedKey = KeychainService.shared.retrieve() {
                apiKey = savedKey
                hasAPIKey = true
            } else {
                hasAPIKey = false
            }
            autoCopyToClipboard = UserDefaults.standard.bool(forKey: "autoCopyToClipboard")
            autoGenerateAltText = UserDefaults.standard.bool(forKey: "autoGenerateAltText")
            
            // Focus API key field if requested (for accessibility)
            if shouldFocusAPIKey {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isAPIKeyFieldFocused = true
                }
            }
        }
        .onChange(of: autoCopyToClipboard) { _, newValue in
            UserDefaults.standard.set(newValue, forKey: "autoCopyToClipboard")
        }
        .onChange(of: autoGenerateAltText) { _, newValue in
            UserDefaults.standard.set(newValue, forKey: "autoGenerateAltText")
        }
    }
    
    private func saveAPIKey() {
        // Dismiss keyboard
        isAPIKeyFieldFocused = false
        
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedKey.isEmpty {
            alertMessage = "Please enter an API key before saving"
        } else if KeychainService.shared.save(trimmedKey) {
            alertMessage = "API Key saved successfully! You can now generate alt text."
            hasAPIKey = true
            // Announce success to VoiceOver
            UIAccessibility.post(notification: .announcement, argument: "API Key saved successfully")
        } else {
            alertMessage = "Failed to save API Key to secure storage"
        }
        showAlert = true
    }
}

#Preview {
    SettingsView(shouldFocusAPIKey: false)
}