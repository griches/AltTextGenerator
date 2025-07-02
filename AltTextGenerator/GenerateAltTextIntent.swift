//
//  GenerateAltTextIntent.swift
//  AltTextGenerator
//
//  Created by Gary Riches on 01/07/2025.
//

import AppIntents
import UIKit
import UniformTypeIdentifiers

enum AltTextDetailLevel: String, AppEnum {
    case quickly = "quickly"
    case normally = "normally"
    case fully = "fully"
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Detail Level")
    static var caseDisplayRepresentations: [AltTextDetailLevel: DisplayRepresentation] = [
        .quickly: DisplayRepresentation(title: "Quickly", subtitle: "Describe quickly"),
        .normally: DisplayRepresentation(title: "Normally", subtitle: "Describe in normal detail"),
        .fully: DisplayRepresentation(title: "Fully", subtitle: "Describe fully")
    ]
}

enum AltTextFocusLevel: String, AppEnum {
    case wholeScreen = "whole screen"
    case largeImages = "large images"
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Focus on")
    static var caseDisplayRepresentations: [AltTextFocusLevel: DisplayRepresentation] = [
        .wholeScreen: DisplayRepresentation(title: "Whole Screen", subtitle: "Describe entire image"),
        .largeImages: DisplayRepresentation(title: "Large Images", subtitle: "Focus on prominent elements")
    ]
}

struct GenerateAltTextIntent: AppIntent {
    static var title: LocalizedStringResource = "Alt Text"
    static var description = IntentDescription("Generate alt text for one or more images using AI")
    static var parameterSummary: some ParameterSummary {
        Summary("Generate alt text for \(\.$images). Describe \(\.$detailLevel), focus on \(\.$focusLevel)")
    }
    static var outputAttributionBundleIdentifier: String? = "mobi.bouncingball.AltTextGenerator"
    
    @Parameter(title: "Images", 
               description: "The images to generate alt text for",
               supportedContentTypes: [.image],
               inputConnectionBehavior: .connectToPreviousIntentResult)
    var images: [IntentFile]
    
    @Parameter(title: "Detail Level",
               description: "How detailed the alt text should be",
               default: .normally)
    var detailLevel: AltTextDetailLevel
    
    @Parameter(title: "Focus on",
               description: "What to focus on when describing the image",
               default: .wholeScreen)
    var focusLevel: AltTextFocusLevel
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        guard !images.isEmpty else {
            throw GenerateAltTextError.noImagesProvided
        }
        
        // Process all images in parallel
        let altTexts = try await withThrowingTaskGroup(of: (Int, String).self) { group in
            for (index, imageFile) in images.enumerated() {
                group.addTask {
                    guard let fileURL = imageFile.fileURL else {
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
                    
                    let altText = try await OpenAIService.shared.generateAltText(for: uiImage, detailLevel: detailLevel)
                    return (index, altText)
                }
            }
            
            // Collect results in order
            var results = [(Int, String)]()
            for try await result in group {
                results.append(result)
            }
            
            // Sort by index to maintain order
            results.sort { $0.0 < $1.0 }
            return results.map { $0.1 }
        }
        
        // Combine all alt texts with image numbers
        let combinedAltText = altTexts.enumerated().map { index, altText in
            if images.count > 1 {
                return "Image \(index + 1): \(altText)"
            } else {
                return altText
            }
        }.joined(separator: "\n\n")
        
        return .result(
            value: combinedAltText,
            dialog: IntentDialog(stringLiteral: combinedAltText)
        )
    }
}

enum GenerateAltTextError: LocalizedError {
    case failedToLoadImage
    case failedToGenerateAltText(String)
    case noImagesProvided
    
    var errorDescription: String? {
        switch self {
        case .failedToLoadImage:
            return "Failed to load image"
        case .failedToGenerateAltText(let message):
            return "Failed to generate alt text: \(message)"
        case .noImagesProvided:
            return "No images provided"
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
                "Describe images with \(.applicationName)"
            ],
            shortTitle: "Alt Text",
            systemImageName: "text.below.photo"
        )
    }
}
