//
//  ListCloudUploads.swift
//  Wine
//
//  Created by Alen Alex on 06/07/25.
//

import SwiftUI
import FactoryKit
import Combine

struct ListCloudUploads: View {
    
    @StateObject private var viewModel = ListCloudUploadsViewModel()
    
    @State private var sortOrder = [KeyPathComparator(\FilesItem.fileName)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SettingHeader(
                heading: SettingsSidebarPages.list.rawValue,
                description: SettingsSidebarPages.list.description
            )
            .padding(.top, 10)
            .padding(.bottom, 20)
            
            Table(viewModel.items, sortOrder: $sortOrder) {
                TableColumn("File Name", value: \.fileName) { fileItem in
                    Text(fileItem.fileName)
                        .onAppear {
                            if fileItem.id == viewModel.items.last?.id {
                                Task {
                                    await viewModel.fetchData()
                                }
                            }
                        }
                }
                
                TableColumn("Size") { fileItem in
                    if let size = fileItem.size {
                        Text(ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file))
                    } else {
                        Text("-")
                    }
                }
                
                TableColumn("Expiration") { fileItem in
                    Text(fileItem.relativeExpiration)
                }
                
                TableColumn("Created") { fileItem in
                    Text(fileItem.relativeCreatedAt)
                }
                
                TableColumn("Action") { fileItem in
                    HStack(spacing: 8) {
                        Button {
                            self.viewModel.open(lineItem: fileItem)
                        } label: {
                            Image(systemName: "eye")
                                .help("View")
                        }
                        .buttonStyle(.borderless)
                        .disabled(self.viewModel.hasExpired(lineItem: fileItem))

//                        Button {
//                        } label: {
//                            Image(systemName: "pencil")
//                                .help("Edit")
//                        }
//                        .buttonStyle(.borderless)

                        Button {
                        } label: {
                            Image(systemName: "trash")
                                .help("Delete")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.borderless)
                        .disabled(self.viewModel.hasExpired(lineItem: fileItem))

                    }
                }

            }
            
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding()
            }
        }
        .task {
            if viewModel.items.isEmpty {
                await viewModel.fetchData()
            }
        }
    }
}

#Preview {
    ListCloudUploads()
}

@MainActor
class ListCloudUploadsViewModel: ObservableObject {
    
    @Published var items: [FilesItem] = []
    @Published var isLoading: Bool = false
    
    private var skip: Int = 0
    private let take: Int = 20
    private var canLoadMore: Bool = true
    
    private let fileUploadApi = Container.shared.fileUploadApi.resolve()
    private let settingsService = Container.shared.settingsService.resolve()

    func fetchData() async {
        guard !isLoading, canLoadMore else {
            print("Is Loading")
            return
        }
        
        isLoading = true
        
        let result = await fileUploadApi.listUploads(request: FileListQuery(skip: skip, take: take))
        
        isLoading = false

        switch result {
        case .success(let value):
            if value.items.isEmpty {
                canLoadMore = false
                return
            }
            
            items.append(contentsOf: value.items)
            skip += value.items.count
            
        case .failure(let error):
            print("Error fetching data: \(error)")
        }
    }
    
    func open(lineItem: FilesItem) {
        guard case let .wine(settings) = self.settingsService.uploadSettings.type else {
            return
        }
        
        let url = settings.serverAddress.appending(path: lineItem.id)
        NSWorkspace.shared.open(url);
    }
    
    func hasExpired(lineItem: FilesItem) -> Bool{
        return lineItem.expiration?.timeIntervalSinceNow ?? 0 < 0
    }
    
    func delete(lineItem: FilesItem) async -> Result<Bool, Error> {
        do {
            return .success(true)
        }catch {
            return .failure(error)
        }
    }
}
