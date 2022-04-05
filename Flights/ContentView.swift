//
//  ContentView.swift
//  Flights
//
//  Created by Tejas on 2/24/22.
//

import SwiftUI

class FlightViewModel: ObservableObject {
    @Published var flights: [Flight]? = nil
    
    init() {
        print("Flight vm created")
    }
    
    func reset() {
        flights?.removeAll()
    }
    
    func loadFirst() {
        DispatchQueue.global().async {
            FlightData.loadFew { flights in
                DispatchQueue.main.async {
                    self.flights = flights
                }
            }
        }
    }
    
    func loadMore(_ completion: (() -> Void)? = nil) {
        DispatchQueue.global().async {
            
            FlightData.loadFew { flights in
                DispatchQueue.main.async {
                    self.flights?.append(contentsOf: flights)
                    completion?()
                }
            }
        }
    }
    
    func delete(flight: Flight) {
        flights?.removeAll(where: { flt in
            flt.id == flight.id
        })
    }
}

struct FlightRow: View {
    
    let flight: Flight
    let index: Int?
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: "https://picsum.photos/50")).frame(width: 50, height: 50)
            Spacer()
            if let index = index {
                Text("\(index)")
                    .font(.system(.caption))
                Spacer()
            }
            Text(flight.from)
                .padding()
            Spacer()
            Image(systemName: "airplane").frame(width: 50, height: 50)
            Spacer()
            Text(flight.to)
                .padding()
        }.background(.background)
            .border(.gray, width: 0.5)
            .padding()
            
    }
}

struct FlightList: View {
    
    enum ViewType {
        case list
        case scrollStack
        case uiTableView
    }
    
    @StateObject var flightsViewModel : FlightViewModel
    @State var loadingData = false
    @State var viewType = ViewType.list
    @State private var didRequestScroll = false
    
    var body: some View {
        
        NavigationView {
            ZStack {
                switch viewType {
                case .list:
                    getListView()
                case .scrollStack:
                    getScrollStackView()
                case .uiTableView:
                    getMyListView()
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        viewType = .list
                        flightsViewModel.reset()
                    } label: {
                        Image(systemName: "l.circle")
                    }

                    Button {
                        viewType = .scrollStack
                        flightsViewModel.reset()
                    } label: {
                        Image(systemName: "s.circle")
                    }
                    
                    Button {
                        viewType = .uiTableView
                        flightsViewModel.reset()
                    } label: {
                        Image(systemName: "t.circle")
                    }
                }
            }
            .navigationTitle(navTitle(for: viewType))
        }
    }
    
    private func navTitle(for viewType: ViewType) -> String {
        switch viewType {
        case .list:
            return "List"
        case .scrollStack:
            return "Scroll/Stack"
        case .uiTableView:
            return "UITableView"
        }
    }
        
    private func getScrollStackView() -> some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                ScrollViewReader { value in
                    LazyVStack {
                        ForEach(flightsViewModel.flights ?? []) { flight in
                            FlightRow(flight: flight, index: nil)
                                .onAppear {
                                    if let lastFlight = flightsViewModel.flights?.last,
                                       flight.id == lastFlight.id {
                                        flightsViewModel.loadMore()
                                    }
                                }
                        }
                    }
                    .onChange(of: didRequestScroll) { newValue in
                        if didRequestScroll {
                            if let lastId = flightsViewModel.flights?.last?.id {
                                value.scrollTo(lastId)
                            }
                            didRequestScroll = false
                        }
                    }
                }
                
            }
            .onAppear {
                flightsViewModel.loadFirst()
            }
            
            Button("Scroll to end") {
                didRequestScroll = true
            }
            .buttonStyle(BlueButton())

        }
    }
    
    private func getListView() -> some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollViewReader { value in
                List(flightsViewModel.flights ?? []) { flight in
                    FlightRow(flight: flight, index: nil)
                        .onAppear {
                            if let lastFlight = flightsViewModel.flights?.last,
                               flight.id == lastFlight.id {
                                flightsViewModel.loadMore()
                            }
                        }
                }
                .onAppear {
                    flightsViewModel.loadFirst()
                }
                .onChange(of: didRequestScroll) { newValue in
                    if didRequestScroll {
                        if let lastId = flightsViewModel.flights?.last?.id {
                            value.scrollTo(lastId)
                        }
                        didRequestScroll = false
                    }
                }
            }
            
            Button("Scroll to end") {
                didRequestScroll = true
            }
            .buttonStyle(BlueButton())
        }
    }
    
    private func flightRow(for flight: Flight, index: Int) -> some View {
        let flightRow = FlightRow(flight: flight, index: index)
        if let lastFlight = flightsViewModel.flights?.last,
           flight.id == lastFlight.id, !loadingData {
            loadingData = true
            flightsViewModel.loadMore {
                loadingData = false
            }
        }
        return flightRow
    }
    
    private func getMyListView() -> some View {
        ZStack(alignment: .bottomTrailing) {
            MyList(flightsViewModel.flights ?? [], scrollToEndRequested: $didRequestScroll) { flight, idx in
                flightRow(for: flight, index: idx)
            }
            .onAppear {
                didRequestScroll = false
                flightsViewModel.loadFirst()
            }
            
            Button("Scroll to end") {
                didRequestScroll = true
            }
            .buttonStyle(BlueButton())
        }
    }
}

struct ContentView: View {
    var body: some View {
        FlightList(flightsViewModel: FlightViewModel())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct BlueButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.caption))
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .padding()
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}
