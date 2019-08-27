// DateTests.swift
// Copyright (c) 2019 Frank Yellin
// Created on 8/31/19.

import XCTest

@testable import Jewish_Calendar

class DateTests: XCTestCase {
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  /*****
   5780 120 Monday long false
   5781 600 Saturday short false
   5782 211 Tuesday normal true
   5784 601 Saturday short true
   5785 420 Thursday long false
   5786 210 Tuesday normal false
   5787 621 Saturday long true
   5788 620 Saturday long false
   5789 410 Thursday normal false
   5790 101 Monday short true
   5795 421 Thursday long true
   5797 100 Monday short false
   5803 121 Monday long true
   5812 401 Thursday short true
   ******/

  let years = [5780, 5781, 5782, 5784, 5785, 5786, 5787, 5788, 5789, 5790, 5795, 5797, 5803, 5812]
  let hc = HebrewCalendar.shared

  func testExample() {
    let fileName = "Testing3.1"
    var fh = FileHandle(forWritingAtPath: fileName)
    if fh == nil {
      FileManager.default.createFile(atPath: fileName, contents: nil, attributes: nil)
      fh = FileHandle(forWritingAtPath: fileName)!
    }
    defer {
      fh?.closeFile()
    }
    let calendar = SecularCalendar.gregorian
    let hebrewCalendar = HebrewCalendar.shared
    for year in years {
      let yearStart = hebrewCalendar.firstOfYear(year)
      let yearEnd = hebrewCalendar.firstOfYear(year + 1)
      for absolute in yearStart..<yearEnd {
        let dr = DateResult(fromAbsolute: absolute, calendar: calendar)
        assert(dr.absolute == absolute)
        assert(dr.hebrewYear == year)
        assert(absolute == hebrewCalendar.toAbsolute(year, dr.hebrewMonth, dr.hebrewDay))
        assert(absolute == calendar.toAbsolute(dr.secularYear, dr.secularMonth, dr.secularDay))
        assert(dr.hebrewDayNumber == absolute - yearStart + 1)
        let a = FindHolidays(
          fromDateResult: dr,
          inIsrael: false, showParsha: true, showOmer: true, showChol: true)
        let b = FindHolidays(
          fromDateResult: dr,
          inIsrael: true, showParsha: true, showOmer: true, showChol: true)
        var output = """
        \(absolute) \(dr.hebrewDayNumber) \(dr.hebrewYear) \(dr.hebrewMonth) \(dr.hebrewDay) \
        \(dr.secularYear) \(dr.secularMonth) \(dr.secularDay) \(dr.secularMonthLength) \(dr.secularMonthLength) \(a)
        """
        if a != b {
          output = "\(output) \(b)\n"
        } else {
          output = output + "\n"
        }
        fh!.write(Data(output.utf8))
      }
    }
  }

  func testBasicCalendarOperation() {
    for year in years {
      let roshHashanah1 = hc.firstOfYear(year)
      let roshHashanah2 = hc.toAbsolute(year, 7, 1)
      XCTAssertEqual(roshHashanah1, roshHashanah2)
      let dayOfWeek = DayOfWeek(from_absolute: roshHashanah1)
      XCTAssertNotEqual(dayOfWeek, DayOfWeek.Sunday)
      XCTAssertNotEqual(dayOfWeek, DayOfWeek.Wednesday)
      XCTAssertNotEqual(dayOfWeek, DayOfWeek.Friday)

      let yearLength = hc.firstOfYear(year + 1) - hc.firstOfYear(year)

      switch yearLength % 10 {
      case 3:
        XCTAssertEqual(hc.toAbsolute(year, 9, 1), hc.toAbsolute(year, 8, 29) + 1)
        XCTAssertEqual(hc.toAbsolute(year, 10, 1), hc.toAbsolute(year, 9, 29) + 1)
      case 4:
        XCTAssertEqual(hc.toAbsolute(year, 9, 1), hc.toAbsolute(year, 8, 29) + 1)
        XCTAssertEqual(hc.toAbsolute(year, 10, 1), hc.toAbsolute(year, 9, 30) + 1)
      case 5:
        XCTAssertEqual(hc.toAbsolute(year, 9, 1), hc.toAbsolute(year, 8, 30) + 1)
        XCTAssertEqual(hc.toAbsolute(year, 10, 1), hc.toAbsolute(year, 9, 30) + 1)
      default:
        XCTAssert(false, "Should not be here")
      }
      XCTAssert(hc.fromAbsolute(hc.toAbsolute(year, 9, 1)) == (year: year, month: 9, day: 1))
      XCTAssert(hc.fromAbsolute(hc.toAbsolute(year, 10, 1)) == (year: year, month: 10, day: 1))

      XCTAssertEqual(hc.toAbsolute(year + 1, 7, 1), hc.toAbsolute(year, 6, 29) + 1)
      if yearLength < 360 {
        XCTAssertEqual(hc.toAbsolute(year, 1, 1), hc.toAbsolute(year, 12, 29) + 1)
      } else {
        XCTAssertEqual(hc.toAbsolute(year, 13, 1), hc.toAbsolute(year, 12, 30) + 1)
        XCTAssertEqual(hc.toAbsolute(year, 1, 1), hc.toAbsolute(year, 13, 29) + 1)
      }
    }
  }

  func testIndependenceDay() {
    for year in 1940...2010 {
      let iyar2 = hc.toAbsolute(year + 3760, 2, 2)
      let holidays = (iyar2...iyar2 + 4).map { getHolidays(fromAbsolute: $0) }
      let zikaron = holidays.map { $0.contains("Yom HaZikaron") }
      let atzmaut = holidays.map { $0.contains("Yom HaAtzmaut") }
      if year < 1948 {
        XCTAssertFalse(zikaron.contains(true))
        XCTAssertFalse(atzmaut.contains(true))
      } else {
        let zikaronDate = zikaron.firstIndex(of: true)
        let atzmautDate = atzmaut.firstIndex(of: true)
        XCTAssertNotNil(zikaronDate)
        XCTAssertNotNil(atzmautDate)
        XCTAssertEqual(zikaronDate, zikaron.lastIndex(of: true))
        XCTAssertEqual(atzmautDate, atzmaut.lastIndex(of: true))
        XCTAssertEqual(zikaronDate! + 1, atzmautDate)
        let dayOfWeekOfFifth = DayOfWeek(from_absolute: hc.toAbsolute(year + 3760, 2, 5))
        let nthOfIyar = atzmautDate! + 2
        switch dayOfWeekOfFifth {
        case .Monday where year < 2004, .Wednesday:
          XCTAssertEqual(nthOfIyar, 5)
        case .Monday where year >= 2004:
          XCTAssertEqual(nthOfIyar, 6)
        case .Friday:
          XCTAssertEqual(nthOfIyar, 4)
        case .Saturday:
          XCTAssertEqual(nthOfIyar, 3)
        default:
          XCTAssertTrue(false, "Should not reach here")
        }
      }
    }
  }

  func xtestPerformanceExample() {
    // This is an example of a performance test case.
    measure {
      // Put the code you want to measure the time of here.
    }
  }

  func getHolidays(fromAbsolute absolute: Int) -> [String] {
    let dr = DateResult(fromAbsolute: absolute, calendar: SecularCalendar.gregorian)
    return FindHolidays(
      fromDateResult: dr, inIsrael: false, showParsha: true, showOmer: true, showChol: true)
  }

  func testBundle() {
    let bundle = Bundle(for: classForCoder)
    let resourceURL = bundle.url(forResource: "golden31", withExtension: "txt")!
    let contents = try! String(contentsOf: resourceURL)
    var lines = contents.split { $0.isNewline }

    let calendar = SecularCalendar.gregorian
    let hebrewCalendar = HebrewCalendar.shared
    for year in years {
      let yearStart = hebrewCalendar.firstOfYear(year)
      let yearEnd = hebrewCalendar.firstOfYear(year + 1)
      for absolute in yearStart..<yearEnd {
        let dr = DateResult(fromAbsolute: absolute, calendar: calendar)
        assert(dr.absolute == absolute)
        assert(dr.hebrewYear == year)
        assert(absolute == hebrewCalendar.toAbsolute(year, dr.hebrewMonth, dr.hebrewDay))
        assert(absolute == calendar.toAbsolute(dr.secularYear, dr.secularMonth, dr.secularDay))
        assert(dr.hebrewDayNumber == absolute - yearStart + 1)
        let a = FindHolidays(
          fromDateResult: dr,
          inIsrael: false, showParsha: true, showOmer: true, showChol: true)
        let b = FindHolidays(
          fromDateResult: dr,
          inIsrael: true, showParsha: true, showOmer: true, showChol: true)
        var output = """
        \(absolute) \(dr.hebrewDayNumber) \(dr.hebrewYear) \(dr.hebrewMonth) \(dr.hebrewDay) \
        \(dr.secularYear) \(dr.secularMonth) \(dr.secularDay) \(dr.secularMonthLength) \
        \(dr.secularMonthLength) \(a)
        """
        if a != b {
          output = "\(output) \(b)"
        }
        XCTAssertEqual(String(lines.first!), output)
        lines.removeFirst()
      }
    }
    XCTAssertTrue(lines.isEmpty)
  }
}
