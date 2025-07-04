import SwiftUI

/// A SwiftUI view that presents sharing options to the user before an upload.
/// This view is designed to look like the provided screenshot for a macOS app.
struct SharePopupView: View {

    // MARK: - State Variables
    // These hold the user's input from the form.
    @State private var title: String = ""
    @State private var password: String = ""
    @State private var linkExpiration: Expiration = .oneHour
    @State private var publicLinkType: LinkType = .webpage
    @State private var createLongLink: Bool = false

    // State to manage which text field is focused, to show the cursor as in the screenshot.
    @FocusState private var isTitleFieldFocused: Bool
    
    // In a real app, you would pass the actual thumbnail image into this view.
    // let contentThumbnail: Image

    // Enums to define the options for the Pickers (dropdowns).
    // This makes the code cleaner and less error-prone.
    enum Expiration: String, CaseIterable, Identifiable {
        case oneHour = "1 hour"
        case sixHours = "6 hours"
        case oneDay = "1 day"
        case oneWeek = "1 week"
        case never = "Never"
        var id: Self { self }
    }

    enum LinkType: String, CaseIterable, Identifiable {
        case webpage = "Webpage"
        case directLink = "Direct link"
        var id: Self { self }
    }

    // The main body of the SwiftUI View.
    var body: some View {
        VStack(spacing: 16) {
            // 1. Header Section
            headerView

            // 2. Subtitle
            Text("Choose how you'd like to share your dragged content:")
                .foregroundColor(.secondary)

            // 3. Main Content Area (Form and Thumbnail)
            formAndThumbnailView

            // 4. Footer Button Bar
            footerButtonsView
        }
        .padding(24)
        .frame(width: 500, height: 350) // Fixed size for a popup window
        .background(Color(nsColor: .windowBackgroundColor))
        .cornerRadius(16)
        .onAppear {
            // Automatically focus the title field when the view appears.
            isTitleFieldFocused = true
        }
    }

    // MARK: - Subviews

    /// The header containing the title and cloud icon.
    private var headerView: some View {
        HStack {
            Text("Dropover Cloud")
                .font(.title2)
                .fontWeight(.semibold)
            Image(systemName: "cloud")
                .font(.title2)
                .foregroundColor(.accentColor)
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
                Text("Title:")
                    .gridColumnAlignment(.trailing)
                TextField("Optional", text: $title)
                    .focused($isTitleFieldFocused) // Bind focus state
            }

            GridRow {
                Text("Password:")
                TextField("Optional", text: $password)
            }

            GridRow {
                Text("Link expiration")
                Picker("", selection: $linkExpiration) {
                    ForEach(Expiration.allCases) { Text($0.rawValue).tag($0) }
                }
                .labelsHidden()
            }

            GridRow {
                Text("Public link type")
                Picker("", selection: $publicLinkType) {
                    ForEach(LinkType.allCases) { Text($0.rawValue).tag($0) }
                }
                .labelsHidden()
            }
            
            // This row is for the checkbox, aligned under the controls.
            GridRow {
                Color.clear // An empty view to push the toggle into the second column
                    .gridCellUnsizedAxes([.horizontal, .vertical])
                
                Toggle(isOn: $createLongLink) {
                    Text("Create long link")
                }
                .toggleStyle(.checkbox)
            }
        }
    }
    
    /// The thumbnail preview of the content to be shared.
    private var thumbnailView: some View {
        // We use a system image as a placeholder representing code.
        Image(systemName: "curlybraces.square")
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
            Button(action: { /* TODO: Show help */ }) {
                Image(systemName: "questionmark.circle")
            }
            .buttonStyle(.plain)
            .font(.title3)
            .foregroundColor(.secondary)

            Spacer()

            Button("Cancel") {
                // In a real app, this would dismiss the window/view.
                print("Upload cancelled.")
            }
            .keyboardShortcut(.cancelAction) // Allows Esc key to trigger it

            Button("Share") {
                // This is where you'd trigger your upload logic.
                // You would pass the state variables to your upload function.
                print("Sharing with the following settings:")
                print("- Title: \(title.isEmpty ? "None" : title)")
                print("- Password: \(password.isEmpty ? "None" : "Set")")
                print("- Expiration: \(linkExpiration.rawValue)")
                print("- Link Type: \(publicLinkType.rawValue)")
                print("- Long Link: \(createLongLink)")
                
                // Example of how you might call your upload function:
                // Task {
                //     let uploadOptions = UploadOptions(
                //          title: title, password: password, expiration: linkExpiration, ...
                //     )
                //     let result = await tryUpload(capturedFile: yourFile, options: uploadOptions)
                //     // Handle result...
                // }
            }
            .keyboardShortcut(.defaultAction) // Makes this the primary button (blue)
        }
    }
}

// MARK: - Xcode Preview
#Preview {
    // Wrap the view in a ZStack with a background color to get a nice preview.
    ZStack {
        // A typical macOS background color for a window behind the main one.
        Color(nsColor: .underPageBackgroundColor).edgesIgnoringSafeArea(.all)
        SharePopupView()
            // Force dark mode for the preview to match the screenshot.
            .preferredColorScheme(.dark)
    }
}
