//
//  Publisher+LoadingState.swift
//
//
//  Created by Luca Gobbo on 26/01/2021.
//
import Combine
import Foundation

public extension Publisher where Failure == Never {
    /// ignore's error & loading state, and only outputs values
    func values<LoadingOutput, LoadingError: Swift.Error>()
        -> AnyPublisher<LoadingOutput, Never>
        where Output == LoadingState<LoadingOutput, LoadingError>
    {
        compactMap(\.output).eraseToAnyPublisher()
    }

    /// ignore's error & loading state, and outputs a void when value is loaded
    func loaded<LoadingOutput, LoadingError: Swift.Error>()
        -> AnyPublisher<Void, Never>
        where Output == LoadingState<LoadingOutput, LoadingError>
    {
        compactMap(\.output).map { _ in () }.eraseToAnyPublisher()
    }

    /// ignore's value & loading state, and only outputs failures
    func failures<LoadingOutput, LoadingError: Swift.Error>()
        -> AnyPublisher<LoadingError, Never>
        where Output == LoadingState<LoadingOutput, LoadingError>
    {
        compactMap(\.failure).eraseToAnyPublisher()
    }

    /// ignores value & error state, and only outputs if the current publisher is loading
    func isLoading<LoadingOutput, LoadingError: Swift.Error>()
        -> AnyPublisher<Bool, Never>
        where Output == LoadingState<LoadingOutput, LoadingError>
    {
        map(\.isLoading).eraseToAnyPublisher()
    }

    func mapLoadingOutput<NewOutput, LoadingOutput, LoadingError: Swift.Error>(
        _ transform: @escaping ((LoadingOutput) -> NewOutput))
        -> AnyLoadingPublisher<NewOutput, LoadingError>
        where Output == LoadingState<LoadingOutput, LoadingError>
    {
        map { element in

            switch element {
            case .loading: return .loading
            case let .failure(error): return .failure(error)
            case let .loaded(value): return .loaded(transform(value))
            }
        }
        .eraseToAnyPublisher()
    }

    func mapLoadingFailure<NewFailure: Error, LoadingOutput, LoadingError: Swift.Error>(
        _ transform: @escaping ((LoadingError) -> NewFailure))
        -> AnyLoadingPublisher<LoadingOutput, NewFailure>
        where Output == LoadingState<LoadingOutput, LoadingError>
    {
        map { element in

            switch element {
            case .loading: return .loading
            case let .failure(error): return .failure(transform(error))
            case let .loaded(value): return .loaded(value)
            }
        }
        .eraseToAnyPublisher()
    }

    func flatMapLatestLoading<NewOutput, LoadingOutput, LoadingError: Swift.Error>(
        _ transform: @escaping ((LoadingOutput) -> AnyLoadingPublisher<NewOutput, LoadingError>))
        -> AnyLoadingPublisher<NewOutput, LoadingError>
        where Output == LoadingState<LoadingOutput, LoadingError>
    {
        map { (value: LoadingState<LoadingOutput, LoadingError>) -> AnyLoadingPublisher<NewOutput, LoadingError> in
            switch value {
            case let .failure(error): return .failure(error)
            case let .loaded(value): return transform(value)
            case .loading: return .loading()
            }
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }

    /// Dematerialises the current loading state. ignores the loading state of the enum
    /// - Returns: a new `Publisher` which de-materialises the loading state element into output and failure
    /// - Note: loading elements are filtered out the sequence
    func dematerializeLoadingState<LoadingOutput, LoadingError: Swift.Error>()
        -> AnyPublisher<LoadingOutput, LoadingError>
        where Output == LoadingState<LoadingOutput, LoadingError>
    {
        filter { !$0.isLoading }
            .setFailureType(to: LoadingError.self)
            .flatMap(\.publisher)
            .eraseToAnyPublisher()
    }
}

public extension Publisher {
    /// Map a Publisher to `AnyLoadingSignal`, and prepends if it's loading
    /// - Note: prepend the `Publisher` with a `loading` state
    func eraseToAnyLoadingPublisher(prepend: Bool = true) -> AnyLoadingPublisher<Output, Failure> {
        if prepend {
            return map { LoadingState<Output, Failure>.loaded($0) }
                .catch { Just(LoadingState<Output, Failure>.failure($0)) }
                .prepend(.loading)
                .eraseToAnyPublisher()
        } else {
            return map { LoadingState<Output, Failure>.loaded($0) }
                .catch { Just(LoadingState<Output, Failure>.failure($0)) }
                .eraseToAnyPublisher()
        }
    }
}
