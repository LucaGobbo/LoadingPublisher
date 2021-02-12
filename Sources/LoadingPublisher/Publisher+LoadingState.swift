//
//  File.swift
//
//
//  Created by Luca Gobbo on 26/01/2021.
//

import Combine
import Foundation

public extension Publisher where Failure == Never {
    /// ignore's error & loading state, and only outputs values
    func values<LoadingOutput, LoadingError: Swift.Error>() -> AnyPublisher<LoadingOutput, Never>
        where Output == LoadingState<LoadingOutput, LoadingError>
    {
        compactMap(\.output).eraseToAnyPublisher()
    }

    /// ignore's error & loading state, and outputs a void when value is loaded
    func loaded<LoadingOutput, LoadingError: Swift.Error>() -> AnyPublisher<Void, Never>
        where Output == LoadingState<LoadingOutput, LoadingError>
    {
        compactMap(\.output).map { _ in () }.eraseToAnyPublisher()
    }

    /// ignore's value & loading state, and only outputs failures
    func failures<LoadingOutput, LoadingError: Swift.Error>() -> AnyPublisher<LoadingError, Never>
        where Output == LoadingState<LoadingOutput, LoadingError>
    {
        compactMap(\.failure).eraseToAnyPublisher()
    }

    /// ignores value & error state, and only outputs if the current publisher is loading
    func isLoading<LoadingOutput, LoadingError: Swift.Error>() -> AnyPublisher<Bool, Never>
        where Output == LoadingState<LoadingOutput, LoadingError>
    {
        map(\.isLoading).eraseToAnyPublisher()
    }
}

public extension Publisher {
    /// Map a Publisher to `AnyLoadingSignal`, and prepends if it's loading
    /// - Note: prepend the `Publisher` with a `loading` state
    func eraseToAnyLoadingPublisher() -> AnyLoadingPublisher<Output, Failure> {
        map { LoadingState<Output, Failure>.loaded($0) }
            .catch { Just(LoadingState<Output, Failure>.failure($0)) }
            .prepend(.loading)
            .eraseToAnyPublisher()
    }
}
