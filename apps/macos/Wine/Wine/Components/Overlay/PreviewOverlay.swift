//
//  PreviewOverlay.swift
//  Wine
//
//  Created by Alen Alex on 10/07/25.
//

import SwiftUI
import OSLog
import FactoryKit
import Combine
import AppKit
import Defaults
import Foundation
import UniformTypeIdentifiers

struct PreviewOverlay: View {
    let id: UUID;
    @State var viewModel : PreviewOverlayModel;
    
    init(with id: UUID, for capture: Capture) {
        self.id = id;
        self.viewModel = PreviewOverlayModel(with: id, capture: capture)
    }
    
    var body: some View {
        previewComponent
            .gesture(DragGesture(minimumDistance: 1, coordinateSpace: .local)
                .onChanged({ [self] _ in
                    self.viewModel.invalidateTimer()
                })
            )
    }
    
    @ViewBuilder
    var previewComponent : some View {
        VStack(spacing: 16) {
            ZStack {
                Color.clear
                if let image = viewModel.thumbNailImage {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    VStack {
                        ProgressView()
                        Text("Loading Preview...")
                    }
                }
            }
            .frame(width: 300, height: 250)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                if self.viewModel.isHovering {
                    actionButtonsOverlay
                }
            }
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.3)){
                    self.viewModel.isHovering = hovering
                }
            }
        }
        .padding(EdgeInsets(top: 40, leading: 20, bottom: 20, trailing: 20))
        .shadow(color: .black.opacity(0.2), radius: 15, y: 5)
        .frame(width: 300)
        
    }
    
    @ViewBuilder
    private var actionButtonsOverlay : some View {
        VStack {
            Spacer()
            HStack(spacing: 4) {
                ShareLink(item: self.viewModel.capture.filePath) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
                        .foregroundColor(self.viewModel.isShareLinkHovering ? .green : .white)
                        .frame(width: 40, height: 40)
                        .scaleEffect(self.viewModel.isShareLinkHovering ? 1.15 : 1.0)
                }
                .buttonStyle(.plain)
                .onAppear(){ self.viewModel.setInteracting(interacting: true) }
                .onDisappear(){ self.viewModel.setInteracting(interacting: false) }
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        self.viewModel.isShareLinkHovering = hovering
                    }
                }
                
                if self.viewModel.capture.type.isScreenshot(){
                    // Edit
                    ActionButton(name: "pencil.tip.crop.circle", hoverColor: Color.yellow, onClick: {
                        self.viewModel.openEditor()
                    }, isInteracting: { interacting in
                        self.viewModel.setInteracting(interacting: interacting)
                    })
                }
                
                // Copy
                ActionButton(name: "document.on.document", hoverColor: Color.blue, onClick: {
                    self.viewModel.copy();
                }, isInteracting: { interacting in
                    self.viewModel.setInteracting(interacting: interacting)
                })
                
                // Cloud
                if viewModel.isCloudSharingEnabled {
                    ActionButton(name: "icloud.and.arrow.up", hoverColor: Color.orange , onClick: {
                        
                    }, isInteracting: { interacting in
                        self.viewModel.setInteracting(interacting: interacting)
                    })
                }
                
                // Trash
                ActionButton(name: "trash", hoverColor: Color.red, onClick: {
                    self.viewModel.delete();
                }, isInteracting: { interacting in
                    self.viewModel.setInteracting(interacting: interacting)
                })
                
                ActionButton(name: "xmark.circle", normalColor: Color.red, hoverColor: Color.white, onClick: {
                    viewModel.closePanel();
                }, isInteracting: { interacting in
                    self.viewModel.setInteracting(interacting: interacting)
                })
            }
            .padding(6)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.bottom, 14)
        }.transition(.opacity.animation(.easeInOut))
    }
}

@Observable class PreviewOverlayModel {
    let id: UUID;
    let capture: Capture;
    @ObservationIgnored let logger : Logger = Logger.create();
    @ObservationIgnored var cancellables : Set<AnyCancellable> = [];
    @ObservationIgnored var dismissTimer: Timer?;
    var thumbNailImage: NSImage? = nil
    var isHovering: Bool = false;
    var isShareLinkHovering: Bool = false
    private(set) var isInteracting: Bool = false
    private(set) var isTimerFinshed: Bool = false
    let isCloudSharingEnabled: Bool;
    let preventAutoClosePreview: Bool;
    
    init(with id: UUID, capture: Capture) {
        self.id = id;
        self.capture = capture
        self.preventAutoClosePreview = Defaults[.preventAutoClosePreviewOnActivity]
        self.isCloudSharingEnabled = Defaults[.cloudProvider] != CloudProviders.none.id;
        self.dismissTimer = createTimer();
        self.initalizeSubscriptions()
    }
    
    func openEditor(){
        Container.shared.windowService.resolve().openEditorWindow(for: capture)
        self.closePanel()
    }

    func delete(){
        self.capture.delete();
        self.closePanel();
    }
    
    func copy(){
        self.capture.copyCaptureToClipboard();
        self.closePanel();
    }
    
    func createTimer() -> Timer {
        return Timer.scheduledTimer(
            withTimeInterval: Defaults[.previewPanelDuration], repeats: false
        ) { [weak self] _ in
            self?.isTimerFinshed = true;
            if self?.isInteracting == true {
                self?.logger.info("Panel is still interacting, skipping closing")
                return;
            }
            
            self?.closePanel(timeout: true)
        };
    }
    
    func setInteracting(interacting: Bool){
        if interacting {
            self.logger.trace("Panel for \(self.capture.id.uuidString) is set to be interacting")
            self.isInteracting = true
            return;
        }
        
        self.isInteracting = false;
        if self.isTimerFinshed {
            self.logger.trace("Panel for \(self.capture.id.uuidString) is not set to be interacting, closing panel")
            self.closePanel()
        }
    }
    
    func closePanel(timeout: Bool = false){
        NotificationCenter.default.post(
            name: .previewPanelClosed,
            object: capture,
            userInfo: [
                "id": self.id,
                "timeout": timeout
            ]
        )
        
        self.invalidateTimer();
    }
    
    func invalidateTimer() {
        guard let timer = dismissTimer else {
            return
        }
        
        if timer.isValid {
            timer.invalidate();
            self.logger.info( "Timer invalidated")
        }
        
        self.dismissTimer = nil;
    }
    
    private func initalizeSubscriptions() {
        capture.imagePreview
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] img in
                let id = self?.capture.id.uuidString ?? "Unknown"
                self?.logger.info("Thumbnail image has been recieved from the capture for \(id)");
                self?.thumbNailImage = img
            })
            .store(in: &cancellables)
    }
}

#Preview {
    PreviewOverlay(
        with: UUID(),
        for:
            Capture(type: .screenshot(ScreenshotOptions.defaultSettings()),
                    ext: "png",
                    filePath: URL(string: "/Users/alenalex/Downloads/Google_AI_Studio_2025-07-10T08_07_35.064Z.png")!
                   )
    )
}
