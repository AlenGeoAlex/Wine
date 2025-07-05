//
//  PreviewViewComponent.swift
//  Wine
//
//  Created by Alen Alex on 26/06/25.
//

import SwiftUI
import FactoryKit
import OSLog

// MARK: - Processing State Enum (No changes needed)
enum ProcessingState: Equatable {
    case none
    case copying
    case uploading
    case deleting
    case failedDeleting;
    case failedUploading;
    case linkCopied;
    
    var message: String {
        switch self {
        case .none:
            return ""
        case .copying:
            return "Copying to Clipboard..."
        case .uploading:
            return "Uploading to Cloud..."
        case .deleting:
            return "Deleting File..."
        case .failedDeleting:
            return "Failed to delete file."
        case .failedUploading:
            return "Failed to upload file."
        case .linkCopied:
            return "Link copied to clipboard!"
        }
    }
    
    var isProgress : Bool {
        switch self {
        case .copying, .uploading, .deleting:
            return true
        default:
            return false
        }
    }
    
    var isError : Bool {
        switch self {
        case .failedDeleting, .failedUploading:
            return true
        default:
            return false
        }
    }
    
    var isSuccess : Bool {
        switch self {
        case .none, .linkCopied:
            return true
        default:
            return false
        }
    }
}


struct PreviewViewComponent: View {
    
    let uploadContent: CapturedFile;
    let onClose: () -> Void
    let logger : Logger
    let isInInteraction: (Bool) -> Void
    
    @InjectedObject(\.settingsService) private var settingsService : SettingsService
    @Injected(\.screenshotOrchestra) private var screenshotOrchestra: AppOrchestra;
    @State private var isHovering = false
    @State private var isShareLinkHovering = false
    
    @State private var processingState: ProcessingState = .none
    @State private var loadedImage: Image? = nil
    
    init(uploadContent: CapturedFile, onClose: @escaping () -> Void, isInInteraction: @escaping (Bool) -> Void) {
        self.uploadContent = uploadContent
        self.onClose = onClose
        self.isInInteraction  = isInInteraction
        self.logger = Logger(subsystem: AppConstants.reversedDomain, category: "PreviewViewComponent")
    }
    
    var body: some View {
        ZStack {
            previewComponent
                .disabled(processingState != .none)
            
            processingOverlay()
        }
        .task {
            if let imageWrapper = await uploadContent.getThumbnailImage() {
                let nsImage = imageWrapper.image
                self.loadedImage = Image(nsImage: nsImage)
            }
        }
    }
    
    // MARK: - UI Components

    /// The overlay containing the action buttons.
    private var actionButtonsOverlay: some View {
        VStack {
            Spacer()
            HStack(spacing: 4) {
                ShareLink(item: self.uploadContent.fileContent) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
                        .foregroundColor(isShareLinkHovering ? .blue : .primary)
                        .frame(width: 40, height: 40)
                        .scaleEffect(isShareLinkHovering ? 1.15 : 1.0)
                }
                    .buttonStyle(.plain)
                    .onAppear(){ isInInteraction(true) }
                    .onDisappear(){ isInInteraction(false) }
                    .onHover { hovering in withAnimation(.easeInOut(duration: 0.15)) { self.isShareLinkHovering = hovering } }
                
                ActionButton(iconName: "pencil.tip.crop.circle", isInInteraction: self.isInInteraction, hoverColor: .orange) { /* Edit action */ }
                
                ActionButton(iconName: "document.on.document",isInInteraction: self.isInInteraction, hoverColor: .cyan) {
                    Task {
                        self.processingState = .copying
                        try? await Task.sleep(for: .milliseconds(300))
                        ClipboardHelper.copyFileToClipboard(fileURL: uploadContent.fileContent)
                        self.processingState = .none
                    }
                }
                
                if self.settingsService.uploadSettings.type != .none {
                    ActionButton(iconName: "icloud.and.arrow.up", isInInteraction: self.isInInteraction, hoverColor: .blue) {
                        Task {
                            self.processingState = .uploading
                            self.isInInteraction(true);
                            let response = await self.screenshotOrchestra.tryUpload(capturedFile: self.uploadContent)
                            try? await Task.sleep(for: .seconds(3))
                            var isSuccess: Bool = false
                            switch response {
                                case .success:
                                isSuccess = true
                                self.processingState = .linkCopied
                            case .failure:
                                self.processingState = .failedUploading
                            }
                            
                            try? await Task.sleep(for: .seconds(3))
                            self.isInInteraction(false);
                            if isSuccess { onClose() }
                        }
                    }
                }
                
                ActionButton(iconName: "trash", isInInteraction: { _ in}, hoverColor: .red) {
                    Task {
                        self.processingState = .deleting
                        try? await Task.sleep(for: .milliseconds(300))
                        let fileDeleteResult = FileHelpers.delete(file: uploadContent.fileContent)
                        if case .failure(let error) = fileDeleteResult {
                            self.processingState = .failedDeleting
                            try? await Task.sleep(for: .seconds(3))
                            self.logger.log("Failed to delete file: \(error)")
                        }
                        self.processingState = .none
                        onClose()
                    }
                }
                
                ActionButton(iconName: "xmark.circle", isInInteraction: { _ in}, hoverColor: .purple) { onClose() }
            }
            .padding(6)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.bottom, 8)
        }
        .transition(.opacity.animation(.easeInOut))
    }
    
    // --- THIS IS THE CORRECTED LAYOUT ---
    var previewComponent : some View {
        VStack(spacing: 16) {
            // 1. This ZStack is our main image container.
            ZStack {
                // 2. We give it a "greedy" background. A Color or Shape will expand
                //    to fill the entire frame proposed by its parent.
                //    This FORCES the ZStack to be 300x300.
                Color.clear // A transparent, greedy background.

                // 3. Now, we place the content on top of this greedy background.
                if let image = loadedImage {
                    image
                        .resizable()
                        .scaledToFit() // This will now fit inside the guaranteed 300x300 space.
                } else {
                    // The placeholder will also be centered in the 300x300 space.
                    ProgressView()
                }
            }
            // 4. We apply a single, definitive frame to the container.
            .frame(width: 300, height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            // 5. The buttons are placed in an overlay so they don't affect layout.
            .overlay {
                if isHovering {
                    actionButtonsOverlay
                }
            }
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.isHovering = hovering && self.processingState == .none
                }
            }
        }
        .padding(EdgeInsets(top: 40, leading: 20, bottom: 20, trailing: 20))
        .shadow(color: .black.opacity(0.2), radius: 15, y: 5)
        .frame(width: 300)
    }

    @ViewBuilder
    private func processingOverlay() -> some View {
        // This component remains unchanged.
        if processingState != .none {
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(.background.opacity(0.7)).background(.thinMaterial).clipShape(RoundedRectangle(cornerRadius: 12))
                VStack(spacing: 15) {
                    if processingState.isProgress { ProgressView().controlSize(.large) }
                    else if processingState.isError { Image(systemName: "exclamationmark.triangle").font(.largeTitle) }
                    Text(processingState.message).font(.headline).foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: 300)
            .transition(.opacity.animation(.easeInOut))
        }
    }
}


struct ActionButton: View {
    let iconName: String
    let normalColor: Color
    let hoverColor: Color
    let action: () -> Void
    let isInInteraction : (Bool) -> Void

    @State private var isHovering = false

    init(iconName: String, normalColor: Color = .primary, isInInteraction : @escaping (Bool) -> Void, hoverColor: Color, action: @escaping () -> Void) {
        self.iconName = iconName
        self.normalColor = normalColor
        self.hoverColor = hoverColor
        self.action = action
        self.isInInteraction = isInInteraction
    }

    var body: some View {
        Button(action: action) { Image(systemName: iconName) }
            .buttonStyle(PlainActionButtonStyle(isHovering: isHovering, normalColor: normalColor, hoverColor: hoverColor))
            .onHover { hovering in withAnimation(.easeInOut(duration: 0.15)) { self.isHovering = hovering } }
            .onAppear(){ isInInteraction(true) }
            .onDisappear(){ isInInteraction(false) }
    }
}

struct PlainActionButtonStyle: ButtonStyle {
    var isHovering: Bool
    var normalColor: Color
    var hoverColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20))
            .foregroundColor(isHovering ? hoverColor : normalColor)
            .frame(width: 40, height: 40)
            .scaleEffect(isHovering ? 1.15 : 1.0)
            .contentShape(Rectangle())
    }
}
