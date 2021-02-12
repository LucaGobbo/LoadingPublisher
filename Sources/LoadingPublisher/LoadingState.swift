//
//  File.swift
//
//
//  Created by Luca Gobbo on 26/01/2021.
//

import Foundation

public enum LoadingState<Output, Failure: Swift.Error> {
    case loading
    case loaded(Output)
    case failure(Failure)
}

public extension LoadingState {
    var isLoading: Bool {
        guard case .loading = self else { return false }
        return true
    }

    var output: Output? {
        guard case let .loaded(output) = self else { return nil }
        return output
    }

    var failure: Failure? {
        guard case let .failure(failure) = self else { return nil }
        return failure
    }
    var loaded: Bool {
        guard case .loaded = self else { return false }
        return true
    }
}
