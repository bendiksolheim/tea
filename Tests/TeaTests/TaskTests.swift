@testable import Tea
import XCTest

final class TaskTests: XCTestCase {
    enum Msg: Equatable {
        case Dummy
        case Number(Int)
        case Unset
    }

    func test_sleeping_for_point_five_seconds() {
        let cmd = Tea.sleep(0.5).andThen { print("done") }.perform { Msg.Dummy }.cmd
        if case let Command.Task(task) = cmd {
            let expectation = self.expectation(description: "Sleeptimer")
            let queue = DispatchQueue(label: "background", qos: .background)
            var msg: Msg = .Unset
            queue.async {
                msg = task()
                expectation.fulfill()
            }

            waitForExpectations(timeout: 0.6, handler: nil)
            XCTAssertEqual(msg, .Dummy)
            return
        }
        XCTFail()
    }

    func test_task_with_unnecessary_complex_addition() {
        let cmd = Task { 1 }.andThen { $0 + 1 }.perform { Msg.Number($0) }.cmd
        if case let Command.Task(task) = cmd {
            let expectation = self.expectation(description: "Additiontimer")
            let queue = DispatchQueue(label: "background", qos: .background)
            var msg: Msg = .Unset
            queue.async {
                msg = task()
                expectation.fulfill()
            }

            waitForExpectations(timeout: 0.1, handler: nil)
            XCTAssertEqual(msg, .Number(2))
            return
        }
        XCTFail()
    }
}
