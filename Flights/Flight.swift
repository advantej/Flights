//
//  Flight.swift
//  Flights
//
//  Created by Tejas on 2/24/22.
//
import Foundation

struct Flight: Identifiable {
    let id = UUID()
    let from: String
    let to: String
    
    init(from: String, to: String) {
        self.from = from
        self.to = to
    }
}


class FlightData {
    private static let airportCodes = ["PAO", "SJC", "RHV", "SQL", "SFO", "HAF", "MRY", "SNS", "LVK", "STS", "APC", "SBA", "JFK", "LHR", "BWI"]
    public static func randomFlight() -> Flight {
        return Flight(from: FlightData.airportCodes.randomElement() ?? "", to: FlightData.airportCodes.randomElement() ?? "")
    }
    
    public static func loadFew(_ completion: @escaping (([Flight]) -> Void)) {
        var flights = [Flight]()
        for _ in 0..<10000 {
            flights.append(FlightData.randomFlight())
        }
        completion(flights)
    }
}
