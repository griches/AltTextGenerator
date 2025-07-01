//
//  GenerateAltTextIntent.swift
//  AltTextGenerator
//
//  Created by Gary Riches on 01/07/2025.
//

import AppIntents
import UIKit
import UniformTypeIdentifiers

struct GenerateAltTextIntent: AppIntent {
    static var title: LocalizedStringResource = "Alt Text"
    static var description = IntentDescription("Generate alt text for an image using AI")
    static var parameterSummary: some ParameterSummary {
        Summary("Generate alt text for \(\.$image)")
    }
    static var outputAttributionBundleIdentifier: String? = "mobi.bouncingball.AltTextGenerator"
    
    @Parameter(title: "Image", 
               description: "The image to generate alt text for",
               supportedContentTypes: [.image],
               inputConnectionBehavior: .connectToPreviousIntentResult)
    var image: IntentFile
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        
        guard let fileURL = image.fileURL else {
            throw GenerateAltTextError.failedToLoadImage
        }
        
        // Start accessing the security-scoped resource
        let accessing = fileURL.startAccessingSecurityScopedResource()
        defer {
            if accessing {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }
        
        guard let imageData = try? Data(contentsOf: fileURL) else {
            throw GenerateAltTextError.failedToLoadImage
        }
        
        guard let uiImage = UIImage(data: imageData) else {
            throw GenerateAltTextError.failedToLoadImage
        }
        
        do {
            let altText = try await OpenAIService.shared.generateAltText(for: uiImage)
            return .result(
                value: altText,
                dialog: IntentDialog("\(altText)")
            )
        } catch {
            throw GenerateAltTextError.failedToGenerateAltText(error.localizedDescription)
        }
    }
}

enum GenerateAltTextError: LocalizedError {
    case failedToLoadImage
    case failedToGenerateAltText(String)
    
    var errorDescription: String? {
        switch self {
        case .failedToLoadImage:
            return "Failed to load image"
        case .failedToGenerateAltText(let message):
            return "Failed to generate alt text: \(message)"
        }
    }
}

struct AltTextGeneratorShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GenerateAltTextIntent(),
            phrases: [
                "Generate alt text with \(.applicationName)",
                "Create alt text in \(.applicationName)",
                "Describe image with \(.applicationName)"
            ],
            shortTitle: "Alt Text",
            systemImageName: "text.below.photo"
        )
    }
}
