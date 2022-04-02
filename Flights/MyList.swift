//
//  MyList.swift
//  Flights
//
//  Created by Tejas on 3/7/22.
//

import SwiftUI

struct MyList<Data, Row: View>: UIViewRepresentable {
    
    private let content: (Data, Int) -> Row
    private let data: [Data]
    
    @Binding var scrollToEndRequested : Bool
    
    init(_ data: [Data], scrollToEndRequested: Binding<Bool>, _ content: @escaping (Data, Int) -> Row) {
        self.data = data
        self.content = content
        self._scrollToEndRequested = scrollToEndRequested
    }
    
    private let tableView = UITableView()
    
    func makeUIView(context: Context) -> UITableView {
        //tableView = UITableView()
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.separatorStyle = .none
        tableView.delegate = context.coordinator
        tableView.dataSource = context.coordinator
        tableView.register(HostingCell<Row>.self, forCellReuseIdentifier: "Cell")
        return tableView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(data, content)
    }
    
    func updateUIView(_ uiView: UITableView, context: Context) {
        context.coordinator.data = data
        
        if scrollToEndRequested {
            /* WIP: going out of bounds
            let row = self.data.count - 1
            let indexPath = IndexPath(row: row, section: 0)
            uiView.scrollToRow(at: indexPath, at: .top, animated: true)
             */
        } else {
            uiView.reloadData()
        }
    }
    
    class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
        
        let content: (Data, Int) -> Row
        var data: [Data]
        
        init(_ data: [Data], _ content: @escaping (Data, Int) -> Row) {
            self.data = data
            self.content = content
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            data.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? HostingCell<Row> else {
                return UITableViewCell()
            }

            let data = self.data[indexPath.row]
            let view = content(data, indexPath.row)
            tableViewCell.setup(with: view)
            return tableViewCell
        }
    }
}


private class HostingCell<Content: View>: UITableViewCell {
    var host: UIHostingController<Content>?
    
    func setup(with view: Content) {
        if host == nil {
            let controller = UIHostingController(rootView: view)
            host = controller
            
            guard let content = controller.view else { return }
            content.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(content)
            
            content.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            content.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            content.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            content.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        } else {
            host?.rootView = view
        }
        
        setNeedsLayout()
    }
}


