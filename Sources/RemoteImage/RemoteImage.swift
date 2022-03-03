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
        self.url = url
        self.phase = .empty
    }

    func load() {
        task = Task(priority: .userInitiated) { [weak self] in
            do {
                self?.phase = .success(try await ImageLoader.default.loadImage(from: url).swiftUIImage)
            }
            catch {
                self?.phase = .failure(error)
            }
        }
    }

    func clear() {
        phase = .empty
    }
}

public struct RemoteImage<Content>: View where Content: View
{
    @ObservedObject private var viewModel: RemoteImageViewModel

    private var content: (RemoteImagePhase) -> Content

    public init(url: URL, content: @escaping (RemoteImagePhase) -> Content) {
        self.viewModel = RemoteImageViewModel(url: url)
        self.content = content
    }

    public var body: some View {
        content(viewModel.phase)
            .onAppear {
                viewModel.load()
            }
            .onDisappear {
                viewModel.clear()
            }
    }
}
