import XCTest
@testable import AwayLockCore

final class PresenceEngineTests: XCTestCase {
    private func t(_ seconds: Int) -> Date {
        Date(timeIntervalSinceReferenceDate: TimeInterval(seconds))
    }

    /// Una lectura por segundo, de `from` a `to` inclusive. Devuelve los eventos juntados.
    @discardableResult
    private func feed(_ engine: PresenceEngine, _ rssi: Int, from: Int, to: Int) -> [PresenceEvent] {
        (from...to).flatMap { engine.add(rssi: rssi, at: t($0)) }
    }

    /// Motor que ya te vio cerca (lecturas de 0 a 5 s).
    private func armedEngine() -> PresenceEngine {
        let engine = PresenceEngine()
        feed(engine, -50, from: 0, to: 5)
        XCTAssertEqual(engine.state, .present)
        return engine
    }

    func testStartsAwayAndArmsOnceNear() {
        let engine = PresenceEngine()
        XCTAssertEqual(engine.state, .away)
        XCTAssertEqual(feed(engine, -50, from: 0, to: 3), [.returned])
        XCTAssertEqual(engine.state, .present)
    }

    func testSignalBetweenThresholdsNeverArms() {
        let engine = PresenceEngine()
        XCTAssertEqual(feed(engine, -70, from: 0, to: 60), [])
        XCTAssertEqual(engine.state, .away)
    }

    func testShortDipDoesNotLock() {
        let engine = armedEngine()
        var events = feed(engine, -90, from: 6, to: 8)
        events += feed(engine, -50, from: 9, to: 30)
        XCTAssertEqual(events, [])
        XCTAssertEqual(engine.state, .present)
    }

    func testWalkingAwayLocksExactlyOnce() {
        let engine = armedEngine()
        XCTAssertEqual(feed(engine, -90, from: 6, to: 120), [.lock(.away)])
        XCTAssertEqual(engine.state, .away)
    }

    func testSingleSpikeWhileAwayIsIgnored() {
        let engine = armedEngine()
        feed(engine, -90, from: 6, to: 20)
        var events = engine.add(rssi: -40, at: t(21))
        events += feed(engine, -90, from: 22, to: 40)
        XCTAssertEqual(events, [])
        XCTAssertEqual(engine.state, .away)
    }

    func testReturningNeedsNearThreshold() {
        let engine = armedEngine()
        feed(engine, -90, from: 6, to: 20)
        // A media distancia no cuenta como que volviste.
        XCTAssertEqual(feed(engine, -70, from: 21, to: 40), [])
        XCTAssertEqual(feed(engine, -50, from: 41, to: 50), [.returned])
    }

    /// El caso que preguntaste: estás sentado con la señal floja, te bloquea, el
    /// Apple Watch te desbloquea y la señal sigue rondando el umbral. No tiene que
    /// volver a bloquear.
    func testWeakSignalWhileSeatedDoesNotLoop() {
        let engine = armedEngine()
        var events: [PresenceEvent] = []
        for second in 6...20 { events += engine.add(rssi: -82, at: t(second)) }
        XCTAssertEqual(events, [.lock(.away)])

        engine.userUnlocked(at: t(21))
        events = []
        for second in 21...300 {
            events += engine.add(rssi: second % 2 == 0 ? -78 : -83, at: t(second))
        }
        XCTAssertEqual(events, [])
    }

    func testLostSignalLocks() {
        let engine = armedEngine()  // última lectura a los 5 s
        XCTAssertEqual(engine.evaluate(at: t(20)), [])
        XCTAssertEqual(engine.evaluate(at: t(36)), [.lock(.signalLost)])
        XCTAssertEqual(engine.evaluate(at: t(100)), [])
    }

    func testGraceAfterUnlockPostponesLock() {
        let engine = armedEngine()
        engine.userUnlocked(at: t(5))  // no bloquea hasta los 25 s
        XCTAssertEqual(feed(engine, -90, from: 6, to: 24), [])
        XCTAssertEqual(feed(engine, -90, from: 25, to: 40), [.lock(.away)])
    }

    func testResetAfterWakeDoesNotLock() {
        let engine = armedEngine()
        engine.reset()
        XCTAssertEqual(engine.state, .away)
        XCTAssertEqual(engine.evaluate(at: t(10_000)), [])
    }

    func testIgnoresUnavailableReadings() {
        let engine = armedEngine()
        XCTAssertEqual(engine.add(rssi: 127, at: t(6)), [])
        XCTAssertEqual(engine.smoothedRSSI, -50)
    }
}
