//
//  Pipe.swift
//  TodoList
//
//  Created by Robert F. Dickerson on 8/3/16.
//
//

import Foundation
import Dispatch

class Pipe<Outcome> {
    private typealias Reader = (Outcome) -> Void
    private var outcomeIfWrittenFirst: Outcome?
    private var readerIfReadFirst: Reader?
    
    
    private let racePrevention = DispatchSemaphore(value: 1)
    private func oneAtATime(_ fn: () -> Void) {
        defer { racePrevention.signal() }
        racePrevention.wait()
        fn()
    }
    
    private let queue = DispatchQueue(label: "pipe reader")
    
    
    func write(_ outcome: Outcome) {
        oneAtATime {
            if let reader = self.readerIfReadFirst {
                self.queue.async {
                    reader(outcome)
                }
            }
            else {
                self.outcomeIfWrittenFirst = outcome
            }
        }
    }
    func then(_ reader: (Outcome) -> Void) {
        oneAtATime {
            if let outcome = self.outcomeIfWrittenFirst {
                self.queue.async {
                    reader(outcome)
                }
            }
            else {
                self.readerIfReadFirst = reader
            }
        }
    }
    func then<NewOutcome>(_ asyncTransfomer: (Outcome) -> Pipe<NewOutcome>) -> Pipe<NewOutcome> {
        let newOutcomePipe = Pipe<NewOutcome>()
        then {
            asyncTransfomer($0).then(newOutcomePipe.write)
        }
        return newOutcomePipe
    }
}
