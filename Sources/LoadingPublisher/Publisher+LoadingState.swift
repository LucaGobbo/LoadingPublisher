//
//  File.swift
//
//
//  Created by Luca Gobbo on 26/01/2021.
//

import Combine
import Foundation

public extension Publisher where Failure == Never {
    func values<LoadingOutput, LoadingError: Swift.Error>() -> AnyPublisher<LoadingOutput, Never>
        where Output == LoadingState<LoadingOutput, LoadingError>
    {
        compactMap(\.output).eraseToAnyPublisher()
    }

    func loaded<LoadingOutput, LoadingError: Swift.Error>() -> AnyPublisher<Void, Never>
        where Output == LoadingState<LoadingOutput, LoadingError>
    {
        compactMap(\.output).map { _ in () }.eraseToAnyPublisher()
    }

    func failures<LoadingOutput, LoadingError: Swift.Error>() -> AnyPublisher<LoadingError, Never>
        where Output == LoadingState<LoadingOutput, LoadingError>
    {
        compactMap(\.failure).eraseToAnyPublisher()
    }

    func isLoading<LoadingOutput, LoadingError: Swift.Error>() -> AnyPublisher<Bool, Never>
        where Output == LoadingState<LoadingOutput, LoadingError>
    {
        map(\.isLoading).eraseToAnyPublisher()
    }
}

public extension Publisher {

    /// Map a Publisher to `AnyLoadingSignal`
    /// - Returns: the same Publisher but as an `AnyLoadingPublisher`
    /// - Note: prepend the `Publisher` with a `loading` state
    func eraseToAnyLoadingPublisher() -> AnyLoadingPublisher<Output, Failure> {
        map { LoadingState<Output, Failure>.loaded($0) }
            .catch { Just(LoadingState<Output, Failure>.failure($0)) }
            .prepend(.loading)
            .eraseToAnyPublisher()
    }

    /// Map a Publisher to `AnyLoadingSignal`
    /// - Returns: the same Publisher but as an `AnyLoadingPublisher`

    func eraseToAnyLoadingNotPrependLoadingPublisher() -> AnyLoadingPublisher<Output, Failure> {
        map { LoadingState<Output, Failure>.loaded($0) }
            .catch { Just(LoadingState<Output, Failure>.failure($0)) }    
            .eraseToAnyPublisher()
    }
}
