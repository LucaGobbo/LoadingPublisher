//
//  LoadingState.swift
//
//
//  Created by Luca Gobbo on 26/01/2021.
//
import Combine
import Foundation

/// We can type erase a ``LoadingState`` to this protocol, when we need to have a less concrete type
public protocol LoadingStateProtocol {
    associatedtype LoadingOutput
    associatedtype LoadingFailure: Error
    var asLoadingState: LoadingState<LoadingOutput, LoadingFailure> { get }
}

/// Represents loading state of a value. used by ``AnyLoadingPublisher``
public enum LoadingState<Output, Failure: Swift.Error>: LoadingStateProtocol {
    public var asLoadingState: LoadingState<Output, Failure> { self }

    public typealias LoadingOutput = Output
    public typealias LoadingFailure = Failure

    /// indicates the publisher is currently loading something from somewhere
    case loading
    /// indicates the publisher has completed with a `Output` value
    case loaded(Output)
    /// indicates the publisher has failed with some `Failure`
    case failure(Failure)
}

public extension LoadingState {
    /// check if the state is in a loading state
    var isLoading: Bool {
        guard case .loading = self else { return false }
        return true
    }

    /// quickly get the output out of the current state
    var output: Output? {
        guard case let .loaded(output) = self else { return nil }
        return output
    }

    /// quickly get the failure out of the current state
    var failure: Failure? {
        guard case let .failure(failure) = self else { return nil }
        return failure
    }

    /// check if the state is loaded
    var loaded: Bool {
        guard case .loaded = self else { return false }
        return true
    }
}

extension LoadingState: Hashable where Output: Hashable, Failure: Hashable {}
extension LoadingState: Sendable where Output: Sendable, Failure: Sendable {}
extension LoadingState: Equatable where Output: Equatable, Failure: Equatable {}

public extension LoadingState {
    /// convert a ``LoadingState`` into a ``AnyLoadingPublisher``
    var loadingPublisher: AnyLoadingPublisher<Output, Failure> {
        switch self {
        case let .failure(error): return .failure(error)
        case let .loaded(output): return .loaded(output)
        case .loading: return .loading()
        }
    }

    /// convert a ``LoadingState`` into a regular `AnyPublisher` where the `Output` equals the Output of the loading
    /// state, and the Failure of the publisher equals the ``LoadingState``'s failure type
    var publisher: AnyPublisher<Output, Failure> {
        switch self {
        case let .failure(error):
            return Fail<Output, Failure>(error: error).eraseToAnyPublisher()

        case let .loaded(value):
            return Just<Output>(value).setFailureType(to: Failure.self).eraseToAnyPublisher()

        case .loading:
            return Empty(completeImmediately: false, outputType: Output.self, failureType: Failure.self)
                .eraseToAnyPublisher()
        }
    }
}
