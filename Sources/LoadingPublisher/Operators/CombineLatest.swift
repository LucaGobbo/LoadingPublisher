//
//  CombineLatest.swift
//
//
//  Created by Luca Gobbo on 20/09/2021.
//

import Combine
import Foundation

public extension LoadingPublishers {
    /// A publisher that receives and combines the latest elements from two publishers.

    struct CombineLatest<A, B>: Publisher
        where A: Publisher, B: Publisher,
        A.Failure == B.Failure,
        A.Failure == Never,
        A.Output: LoadingStateProtocol,
        B.Output: LoadingStateProtocol,
        A.Output.LoadingFailure == B.Output.LoadingFailure
    {
        /// The kind of values published by this publisher.
        ///
        /// This publisher produces two-element tuples of the upstream publishers' output types.
        public typealias Output = LoadingState<(A.Output.LoadingOutput, B.Output.LoadingOutput), LoadingFailure>

        public typealias LoadingFailure = A.Output.LoadingFailure

        public typealias LoadingOutput = Output.LoadingOutput

        /// The kind of errors this publisher might publish.
        ///
        /// This publisher produces the failure type shared by its upstream publishers.
        public typealias Failure = Never

        public let a: A

        public let b: B

        /// Creates a publisher that receives and combines the latest elements from two publishers.
        /// - Parameters:
        ///   - a: The first upstream publisher.
        ///   - b: The second upstream publisher.
        public init(_ a: A, _ b: B) {
            self.a = a
            self.b = b
        }

        public func receive<S>(subscriber: S)
            where S: Subscriber,
            Never == S.Failure, LoadingState<(A.Output.LoadingOutput, B.Output.LoadingOutput), LoadingFailure> == S.Input
        {
            Publishers.CombineLatest(a, b)
                .setFailureType(to: LoadingFailure.self)
                .flatMap(transform(lhs: rhs:))
                .map(\.output)
                .catch(transform(error:))
                .receive(subscriber: subscriber)
        }

        private enum State {
            case loading
            case value(Output.LoadingOutput)

            var output: Output {
                switch self {
                case .loading: return .loading
                case let .value(output): return .loaded(output)
                }
            }
        }

        private func transform(lhs: A.Output, rhs: B.Output) -> AnyPublisher<State, LoadingFailure> {
            switch (lhs.asLoadingState, rhs.asLoadingState) {
            case let (.loaded(lhs), .loaded(rhs)):
                return Just(State.value((lhs, rhs)))
                    .setFailureType(to: LoadingFailure.self)
                    .eraseToAnyPublisher()

            case let (.failure(error), _):
                return Fail(outputType: State.self, failure: error).eraseToAnyPublisher()

            case let (_, .failure(error)):
                return Fail(outputType: State.self, failure: error).eraseToAnyPublisher()

            default:
                return Just(State.loading)
                    .setFailureType(to: LoadingFailure.self)
                    .eraseToAnyPublisher()
            }
        }

        private func transform(error: LoadingPublishers.CombineLatest<A, B>.LoadingFailure) -> AnyPublisher<Output, Failure> {
            let state = LoadingState<Output.LoadingOutput, Output.LoadingFailure>.failure(error)
            return Just(state).eraseToAnyPublisher()
        }
    }
}
