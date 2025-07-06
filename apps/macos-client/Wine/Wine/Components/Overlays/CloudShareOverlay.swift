import SwiftUI

struct CloudShareOverlay: View {

    // MARK: - State Variables
    
    @State private var capturedFile: CapturedFile;
    @State private var cloudShareOverlayModel : CloudShareOverlayModel = CloudShareOverlayModel();
    @FocusState private var isTitleFieldFocused: Bool
    @State private var contentThumbnail: Image = Image(systemName: "curlybraces.square");

    var onCancel: () -> Void = { }
    var onShare: (CloudShareOverlayModel, CapturedFile) -> Void = { (_, _) in }
    
    init(capturedFile: CapturedFile, onCancel: @escaping () -> Void, onShare: @escaping (CloudShareOverlayModel, CapturedFile) -> Void) {
        self.capturedFile = capturedFile
        self.onCancel = onCancel
        self.onShare = onShare
    }
    
    var body: some View {
        VStack(spacing: 10) {
            headerView
            Text("Configure your cloud upload")
                .foregroundColor(.secondary)

            formAndThumbnailView
            footerButtonsView
        }
        .padding(20)
        .frame(width: 500, height: 300)
        .background(Color(nsColor: .windowBackgroundColor))
        .cornerRadius(16)
        .onAppear {
            isTitleFieldFocused = true
        }.task {
            if let imageWrapper = await self.capturedFile.getThumbnailImage() {
                let nsImage = imageWrapper.image
                self.contentThumbnail = Image(nsImage: nsImage)
            }
            let name = await self.capturedFile.fileName;
            self.cloudShareOverlayModel.fileName = name;
        }
    }

    // MARK: - Subviews

    /// The header containing the title and cloud icon.
    private var headerView: some View {
        HStack {
            Text("Wine Cloud")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)
            Spacer()
        }
    }

    /// The central container with form fields and the content thumbnail.
    private var formAndThumbnailView: some View {
        HStack(alignment: .top, spacing: 20) {
            formFieldsView
            thumbnailView
        }
        .padding(20)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(10)
    }

    /// The form fields, aligned neatly in a Grid.
    private var formFieldsView: some View {
        Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 12, verticalSpacing: 14) {
            GridRow {
                Text("Name:")
                    .gridColumnAlignment(.trailing)
                TextField("Optional", text: $cloudShareOverlayModel.fileName)
                    .focused($isTitleFieldFocused) // Bind focus state
            }

            GridRow {
                Text("Password:")
                TextField("Optional", text: $cloudShareOverlayModel.securePassword)
            }

            GridRow {
                Text("Link expiration")
                Picker("", selection: $cloudShareOverlayModel.expiration) {
                    ForEach(Expiration.allCases) { Text($0.rawValue).tag($0) }
                }
                .labelsHidden()
            }
            
            GridRow {
                Text("Tags:")
                TextField("Optional", text: $cloudShareOverlayModel.tags)
            }

            GridRow {
                Text("Public link type")
                Picker("", selection: $cloudShareOverlayModel.linkType) {
                    ForEach(LinkType.allCases) { Text($0.rawValue).tag($0) }
                }
                .labelsHidden()
            }
            
            // This row is for the checkbox, aligned under the controls.
//            GridRow {
//                Color.clear // An empty view to push the toggle into the second column
//                    .gridCellUnsizedAxes([.horizontal, .vertical])
//                
//                Toggle(isOn: $createLongLink) {
//                    Text("Create long link")
//                }
//                .toggleStyle(.checkbox)
//            }
        }
    }
    
    /// The thumbnail preview of the content to be shared.
    private var thumbnailView: some View {
        self.contentThumbnail
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.green)
            .padding()
            .frame(width: 130, height: 80)
            .background(.black)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.white.opacity(0.8), lineWidth: 2)
            )
            .cornerRadius(4)
            .shadow(color: .black.opacity(0.4), radius: 5)
            .padding(.top, 5)
    }

    /// The footer containing the help, cancel, and share buttons.
    private var footerButtonsView: some View {
        HStack {
            Spacer()

            Button("Cancel") {
                onCancel();
            }
            .keyboardShortcut(.cancelAction)

            Button("Upload") {
                onShare(self.cloudShareOverlayModel, self.capturedFile);
            }
            .keyboardShortcut(.defaultAction)
        }
    }
}
