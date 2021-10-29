//
//  CombineLatest.swift
//
//
//  Created by Luca Gobbo on 20/09/2021.
//

import Combine
import Foundation

// swiftlint:disable identifier_name

@available(macOS 12.0, *)
@available(iOS 14.0, *)
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
        // MARK: - Types

        public typealias Output = LoadingState<(A.Output.LoadingOutput, B.Output.LoadingOutput), LoadingFailure>
        public typealias LoadingFailure = A.Output.LoadingFailure
        public typealias LoadingOutput = Output.LoadingOutput
        public typealias Failure = Never

        // MARK: - Properties

        public let a: A
        public let b: B

        // MARK: - init

        /// Creates a publisher that receives and combines the latest elements from two publishers.
        /// - Parameters:
        ///   - a: The first upstream publisher.
        ///   - b: The second upstream publisher.
        public init(_ a: A, _ b: B) {
            self.a = a
            self.b = b
        }

        // MARK: - Publisher

        public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Never, S.Input == Output {
            Publishers.CombineLatest(a, b)
                .flatMap(transform(lhs:rhs:))
                .receive(subscriber: subscriber)
        }

        // MARK: Private

        private func transform(lhs: A.Output, rhs: B.Output) -> AnyPublisher<Output, Never> {
            switch (lhs.asLoadingState, rhs.asLoadingState) {
            case let (.loaded(lhs), .loaded(rhs)): return .loaded((lhs, rhs))

            case let (.failure(error), _): return .failure(error)
            case let (_, .failure(error)): return .failure(error)
            default: return .loading()
            }
        }
    }


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
