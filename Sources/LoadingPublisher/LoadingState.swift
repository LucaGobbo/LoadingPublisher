//
//  LoadingState.swift
//
//
//  Created by Luca Gobbo on 26/01/2021.
//
import Combine
import Foundation

/// Represents loading state of a value. Element of LoadingSignal.
public protocol LoadingStateProtocol {
    associatedtype LoadingOutput
    associatedtype LoadingFailure: Error
    var asLoadingState: LoadingState<LoadingOutput, LoadingFailure> { get }
}

public enum LoadingState<Output, Failure: Swift.Error>: LoadingStateProtocol {
    public var asLoadingState: LoadingState<Output, Failure> { self }

    public typealias LoadingOutput = Output
    public typealias LoadingFailure = Failure

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

extension LoadingState: Equatable where Output: Equatable, Failure: Equatable {}

public extension LoadingState {
    var loadingPublisher: AnyLoadingPublisher<Output, Failure> {
        switch self {
        case let .failure(error): return .failure(error)
        case let .loaded(output): return .loaded(output)
        case .loading: return .loading()
        }
    }

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
