//
//  ViewController.swift
//  CalendarExample
//
//  Created by Enrique Melgarejo on 28/03/22.
//

import FSCalendar
import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var fsCalendarView: FSCalendar!

    private let calendar = DateHelper.shared.calendar

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupCalendar()
    }

    private func setupCalendar() {
        fsCalendarView.dataSource = self
        fsCalendarView.delegate = self
        fsCalendarView.register(CalendarCell.self,
                                forCellReuseIdentifier: "CalendarCell")

        // Appearance
        fsCalendarView.appearance.caseOptions = .weekdayUsesSingleUpperCase
        fsCalendarView.appearance.titleOffset = CGPoint(x: 0.0, y: 2.5)

        // Customizations
        fsCalendarView.placeholderType = .none
        fsCalendarView.calendarHeaderView.isHidden = true
    }
}

extension ViewController: FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(
            withIdentifier: "CalendarCell",
            for: date,
            at: position
        )
        return cell
    }
}

extension ViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.configureCell(cell, for: date, at: monthPosition)
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.configureVisibleCells()
    }

    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.configureVisibleCells()
    }
}

// MARK: - Private methods
extension ViewController {

    private func configureCell(_ cell: FSCalendarCell?, for date: Date?, at position: FSCalendarMonthPosition) {
        guard let cell = cell as? CalendarCell else { return }

        var selectionType = SelectionType.none

        if let date = date,
            let cellCalendar = cell.calendar,
            cellCalendar.selectedDates.contains(where: { $0.isEqual(date: date, toGranularity: .day) }),
           let previousDate = self.calendar.date(byAdding: .day, value: -1, to: date),
            let nextDate = self.calendar.date(byAdding: .day, value: 1, to: date) {

            if cellCalendar.selectedDates.contains(previousDate) && cellCalendar.selectedDates.contains(nextDate) {
                selectionType = .middle
            } else if cellCalendar.selectedDates.contains(previousDate) && cellCalendar.selectedDates.contains(date) {
                selectionType = .rightBorder
            } else if cellCalendar.selectedDates.contains(nextDate) {
                selectionType = .leftBorder
            } else {
                selectionType = .single
            }
        } else if let date = date, date.isEqual() {
            selectionType = .today
        } else {
            selectionType = .none
        }
        cell.selectionType = selectionType
    }

    private func configureVisibleCells() {
        fsCalendarView.visibleCells().forEach { (cell) in
            let date = fsCalendarView.date(for: cell)
            let position = fsCalendarView.monthPosition(for: cell)
            configureCell(cell, for: date, at: position)
        }
    }
}
