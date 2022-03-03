//
//  RemoteImage.swift
//  RemoteImage
//
//  Created by Paul Calnan on 2/25/22.
//

import SwiftUI

public enum RemoteImagePhase {
    case empty
    case success(Image)
    case failure(Error)
}

@MainActor
class RemoteImageViewModel: ObservableObject {

    @Published var phase: RemoteImagePhase

    private let url: URL

    private var task: Task<Void, Never>?

    init(url: URL) {
        self.phase = .empty
        self.url = url
    }

    func load(imageLoader: ImageLoader) {
        task = Task(priority: .userInitiated) { [weak self] in
            do {
                self?.phase = .success(try await imageLoader.loadImage(from: url).swiftUIImage)
            }
            catch {
                self?.phase = .failure(error)
            }
        }
    }

    func unload() {
        phase = .empty
    }
}

public struct RemoteImage<Content>: View where Content: View {

    @Environment(\.imageLoader) var imageLoader

    @ObservedObject private var viewModel: RemoteImageViewModel

    private var content: (RemoteImagePhase) -> Content

    public init(url: URL, @ViewBuilder content: @escaping (RemoteImagePhase) -> Content) {
        self.viewModel = RemoteImageViewModel(url: url)
        self.content = content
    }

    public var body: some View {
        content(viewModel.phase)
            .onAppear {
                viewModel.load(imageLoader: imageLoader)
            }
            .onDisappear {
                viewModel.unload()
            }
    }
}
