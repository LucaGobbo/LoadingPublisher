import Combine
import XCTest
@testable import LoadingPublisher

final class LoadingPublisherTests: XCTestCase {
    private var bag: Set<AnyCancellable> = []

    enum Error: Swift.Error, Equatable {
        case failure
    }

    override func setUp() {
        super.setUp()
        bag = []
    }

    func testLoadingPublisherToValues() {
        let receivedAllValues = expectation(description: "all values received")
        var expectedValues: [Int] = [1, 2]

        let sink = PassthroughSubject<LoadingState<Int, Error>, Never>()

        sink.values()
            .sink(receiveValue: { value in
                guard let expectedValue = expectedValues.first else {
                    XCTFail("Received more values than expected.")
                    return
                }

                guard expectedValue == value else {
                    XCTFail("Expected received value \(value) to match first expected value \(expectedValue)")
                    return
                }

                expectedValues = Array(expectedValues.dropFirst())

                if expectedValues.isEmpty {
                    receivedAllValues.fulfill()
                }
            })
            .store(in: &bag)

        sink.send(.loading)
        sink.send(.loaded(1))
        sink.send(.failure(.failure))
        sink.send(.loaded(2))

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testLoadingPublisherToFailures() {
        let receivedAllValues = expectation(description: "all values received")
        var expectedValues: [Error] = [.failure]

        let sink = PassthroughSubject<LoadingState<Int, Error>, Never>()

        sink.failures()
            .sink(receiveValue: { value in
                guard let expectedValue = expectedValues.first else {
                    XCTFail("Received more values than expected.")
                    return
                }

                guard expectedValue == value else {
                    XCTFail("Expected received value \(value) to match first expected value \(expectedValue)")
                    return
                }

                expectedValues = Array(expectedValues.dropFirst())

                if expectedValues.isEmpty {
                    receivedAllValues.fulfill()
                }
            })
            .store(in: &bag)

        sink.send(.loading)
        sink.send(.loaded(1))
        sink.send(.failure(.failure))
        sink.send(.loaded(2))

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testLoadingPublisherToLoaded() {
        let receivedAllValues = expectation(description: "all values received")
        var expectedValues: [Bool] = [true, true]

        let sink = PassthroughSubject<LoadingState<Int, Error>, Never>()

        sink.loaded().map { _ in true }
            .sink(receiveValue: { value in
                guard let expectedValue = expectedValues.first else {
                    XCTFail("Received more values than expected.")
                    return
                }

                guard expectedValue == value else {
                    XCTFail("Expected received value \(value) to match first expected value \(expectedValue)")
                    return
                }

                expectedValues = Array(expectedValues.dropFirst())

                if expectedValues.isEmpty {
                    receivedAllValues.fulfill()
                }
            })
            .store(in: &bag)

        sink.send(.loading)
        sink.send(.loaded(1))
        sink.send(.failure(.failure))
        sink.send(.loaded(2))
        sink.send(.loading)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testLoadingPublisherToIsLoading() {
        let receivedAllValues = expectation(description: "all values received")
        var expectedValues: [Bool] = [true, false, false, false, true]

        let sink = PassthroughSubject<LoadingState<Int, Error>, Never>()

        sink.isLoading()
            .sink(receiveValue: { value in
                guard let expectedValue = expectedValues.first else {
                    XCTFail("Received more values than expected.")
                    return
                }

                guard expectedValue == value else {
                    XCTFail("Expected received value \(value) to match first expected value \(expectedValue)")
                    return
                }

                expectedValues = Array(expectedValues.dropFirst())

                if expectedValues.isEmpty {
                    receivedAllValues.fulfill()
                }
            })
            .store(in: &bag)

        sink.send(.loading)
        sink.send(.loaded(1))
        sink.send(.failure(.failure))
        sink.send(.loaded(2))
        sink.send(.loading)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFailure() {
        let receivedAllValues = expectation(description: "all values received")
        var expectedValues: [LoadingState<Int, Error>] = [.loading, .failure(.failure)]

        let sink = PassthroughSubject<Int, Error>()

        sink.eraseToAnyLoadingPublisher()
            .sink(receiveValue: { value in
                guard let expectedValue = expectedValues.first else {
                    XCTFail("Received more values than expected.")
                    return
                }

                guard expectedValue == value else {
                    XCTFail("Expected received value \(value) to match first expected value \(expectedValue)")
                    return
                }

                expectedValues = Array(expectedValues.dropFirst())

                if expectedValues.isEmpty {
                    receivedAllValues.fulfill()
                }
            })
            .store(in: &bag)

        sink.send(completion: .failure(.failure))

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testErasingToAnyLoadingPublisherShouldPrependLoadingState() {
        let receivedAllValues = expectation(description: "all values received")
        var expectedValues: [LoadingState<Int, Error>] = [.loading, .loaded(1)]

        let sink = PassthroughSubject<Int, Error>()

        sink.eraseToAnyLoadingPublisher()
            .sink(receiveValue: { value in
                guard let expectedValue = expectedValues.first else {
                    XCTFail("Received more values than expected.")
                    return
                }

                guard expectedValue == value else {
                    XCTFail("Expected received value \(value) to match first expected value \(expectedValue)")
                    return
                }

                expectedValues = Array(expectedValues.dropFirst())

                if expectedValues.isEmpty {
                    receivedAllValues.fulfill()
                }
            })
            .store(in: &bag)

        sink.send(1)

        waitForExpectations(timeout: 1, handler: nil)
    }

    static var allTests = [
        ("testLoadingPublisherToValues", testLoadingPublisherToValues),
        ("testLoadingPublisherToFailures", testLoadingPublisherToFailures),
        ("testLoadingPublisherToLoaded", testLoadingPublisherToLoaded),
        ("testLoadingPublisherToIsLoading", testLoadingPublisherToIsLoading),
        ("testFailure", testFailure),
        ("testErasingToAnyLoadingPublisherShouldPrependLoadingState", testErasingToAnyLoadingPublisherShouldPrependLoadingState)
    ]
}
