//
//  MainView.swift
//  AltTextGenerator
//
//  Created by Gary Riches on 01/07/2025.
//

import SwiftUI
import PhotosUI

struct MainView: View {
    @State private var selectedImage: UIImage?
    @State private var generatedText: String = ""
    @State private var isLoading: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var showSettings: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var hasAPIKey: Bool = false
    @State private var isCopied: Bool = false
    @State private var autoCopyEnabled: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(10)
                        .padding(.horizontal)
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 300)
                        .overlay(
                            VStack {
                                Image(systemName: "photo")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("No image selected")
                                    .foregroundColor(.gray)
                            }
                        )
                        .padding(.horizontal)
                }
                
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()) {
                        Label("Select Image", systemImage: "photo")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .onChange(of: selectedItem) { _, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                selectedImage = image
                                generatedText = ""
                            }
                        }
                    }
                
                Button(action: generateAltText) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(10)
                    } else {
                        Label("Generate Alt Text", systemImage: "wand.and.rays")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedImage != nil ? Color.green : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .disabled(selectedImage == nil || isLoading)
                
                if !generatedText.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Generated Alt Text:")
                            .font(.headline)
                        
                        Text(generatedText)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        
                        Button(action: copyToClipboard) {
                            HStack {
                                Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
                                Text(isCopied ? "Copied to Clipboard!" : "Copy to Clipboard")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isCopied ? Color.green : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .animation(.easeInOut(duration: 0.3), value: isCopied)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Alt Text Generator")
            .navigationBarItems(trailing: Button(action: {
                showSettings = true
            }) {
                Image(systemName: "gearshape")
            })
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .alert("Alt Text Generator", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                checkForAPIKey()
                loadAutoCopySettings()
            }
            .onChange(of: showSettings) { _, newValue in
                if !newValue {
                    checkForAPIKey()
                    loadAutoCopySettings()
                }
            }
        }
    }
    
    private func checkForAPIKey() {
        hasAPIKey = KeychainService.shared.retrieve() != nil
    }
    
    private func loadAutoCopySettings() {
        autoCopyEnabled = UserDefaults.standard.bool(forKey: "autoCopyToClipboard")
    }
    
    private func generateAltText() {
        guard let image = selectedImage else { return }
        
        isLoading = true
        generatedText = ""
        
        Task {
            do {
                let altText = try await OpenAIService.shared.generateAltText(for: image)
                await MainActor.run {
                    self.generatedText = altText
                    self.isLoading = false
                    
                    // Auto-copy to clipboard if enabled
                    if self.autoCopyEnabled {
                        self.copyToClipboard()
                    }
                }
            } catch {
                await MainActor.run {
                    if error.localizedDescription.contains("API Key not found") {
                        self.alertMessage = "No API key found. Please:\n\n1. Tap the settings icon (⚙️) in the top right\n2. Get an API key from platform.openai.com\n3. Enter your API key and tap Save\n4. Make sure you have credits in your OpenAI account"
                    } else {
                        self.alertMessage = error.localizedDescription
                    }
                    self.showAlert = true
                    self.isLoading = false
                }
            }
        }
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = generatedText
        
        // Animate the button change
        withAnimation(.easeInOut(duration: 0.3)) {
            isCopied = true
        }
        
        // Reset after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isCopied = false
            }
        }
    }
}

#Preview {
    MainView()
}