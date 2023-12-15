//
//  ContentView.swift
//  BalanceRx
//
//  Created by Admin on 12/14/23.
//

import SwiftUI

enum InteractionModes: Int, CaseIterable {
    case interactive
    case manual
    
    public var localizedDescription: String {
        switch self {
        case .interactive: return "Interactive"
        case .manual:      return "Manual"
        }
    }
    
    public var image: Image {
        switch self {
        case .interactive: return Image(systemName: "sparkles")
        case .manual:      return Image(systemName: "wrench.and.screwdriver.fill")
        }
    }
}

struct ContentView: View {
    @State private var equation = Equation(
        reactants: [CombinedElement(coefficient: 2, elements: [Element(element: "H", sub: 2), Element(element: "O", sub: 1)])],
        products: [CombinedElement(coefficient: 2, elements: [Element(element: "H", sub: 2), Element(element: "O", sub: 1)])]
    )
    
    @State private var interactionMode = InteractionModes.interactive
    @State private var isElementViewPresented = false
    @State private var selectedElement: CombinedElement = CombinedElement(coefficient: 2, elements: [Element(element: "H", sub: 2), Element(element: "O", sub: 1)])
    
    var body: some View {
        NavigationStack {
            Group {
                switch interactionMode {
                case .interactive: interactiveModeView
                case .manual:      manualModeView
                }
            }
            .navigationTitle("BalanceRx")
            .toolbar {
                Menu {
                    Picker(selection: $interactionMode) {
                        ForEach(InteractionModes.allCases, id: \.rawValue) { interactionMode in
                            HStack {
                                Text(interactionMode.localizedDescription)
                                interactionMode.image
                            }.tag(interactionMode)
                        }
                    } label: {
                        Text("op")
                    }
                } label: {
                    Label("Options", systemImage: "ellipsis.circle")
                }
            }
        }
        .onChange(of: selectedElement) { updatedValue in
            
        }
    }
    
    private var interactiveModeView: some View {
        VStack {
            HStack {
                ForEach(equation.reactants, id: \.self) { combinedElement in
                    
                    HStack {
                        Text("\(combinedElement.coefficient)")
                        
                        ForEach(combinedElement.elements, id: \.hashValue) { element in
                            ((Text(element.element)
                                .font(.largeTitle)
                                .bold()
                            ) + Text("\(element.sub)")
                                .font(.system(size: 12))
                                .bold()
                                .baselineOffset(6.0))
                            .padding()
                        }
                    }
                    .padding()
                    .if(selectedElement == combinedElement) {
                        $0.overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.blue, lineWidth: 4)
                        )
                    }
                    .onTapGesture {
                        selectedElement = combinedElement
                        isElementViewPresented.toggle()
                    }
                    
                }
            }
            Button(action: {
                selectedElement = CombinedElement(coefficient: 2, elements: [Element(element: "H", sub: 2), Element(element: "O", sub: 1)])
                isElementViewPresented.toggle()
            }, label: {
                Image(systemName: "plus.circle.fill")
            })
        }
        .sheet(isPresented: $isElementViewPresented) {
            if #available(iOS 16.4, *) {
                ElementView(element: selectedElement)
                    .presentationDetents([.fraction(0.5)])
                    .presentationCornerRadius(15)
                    .presentationDragIndicator(.visible)
            } else {
                ElementView(element: selectedElement)
                    .presentationDetents([.fraction(0.5)])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    private var manualModeView: some View {
        @State var input = ""
        @State var output = ""
        
        return List {
            Section {
                HStack {
                    TextField("Write Chemical Equation here", text: $input)
                    
                    if (interactionMode == .manual) {
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Image(systemName: "camera.viewfinder")
                            //                                    .resizable()
                            //                                    .aspectRatio(contentMode: .fit)
                            //                                    .frame(height: 30)
                                .foregroundStyle(.black)
                        })
                    }
                }
            }
            
            Section {
                TextField("Resulting Chemical Equation here", text: $output)
                    .disabled(true)
            }
        }
    }
}

#Preview {
    ContentView()
}

struct ElementView: View {
    @State fileprivate var element: CombinedElement
    
    @Environment(\.presentationMode) private var presentationMode
    
    @FocusState private var isElementFocused: Bool
    @State private var focusedElement: Element = Element(element: "H", sub: 2)

    public var body: some View {
        VStack {
            HStack {
                Spacer()
                
                CloseButtonView(presentationMode: presentationMode)
            }
            .padding()
            
            HStack {
                Text("\(element.coefficient)")
                
                ForEach(element.elements, id: \.hashValue) { element in
                    ((Text(element.element)
                        .font(.largeTitle)
                        .bold()
                    ) + Text("\(element.sub)")
                        .font(.system(size: 12))
                        .bold()
                        .baselineOffset(6.0))
                    .padding()
                    .if(focusedElement == element) {
                        $0.overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.blue, lineWidth: 4)
                        )
                    }
                    .padding()
                    .onTapGesture {
                        focusedElement = element
                    }
                }
            }
            
            HStack {
                Text("Coefficient: ")
                
                TextField("Coefficient", value: coefficientBinding, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
            }
            
            HStack {
                Spacer(minLength: 2)
                
                var elementBinding: Binding<String> {
                    Binding {
                        return focusedElement.element
                    } set: { updatedValue in
                        focusedElement.element = updatedValue
                    }
                }
                
                var subBinding: Binding<Int> {
                    Binding {
                        return focusedElement.sub
                    } set: { updatedValue in
                        focusedElement.sub = updatedValue
                    }
                }
                
                TextField("Element", text: elementBinding)
                    .textFieldStyle(.roundedBorder)
                    .focused($isElementFocused)
                    .submitLabel(.done)
                
                Spacer(minLength: 2)
                
                TextField("Subscript", value: subBinding, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
                
                Spacer(minLength: 2)
            }
        }
        .onAppear {
            isElementFocused = true
            focusedElement = element.elements.first!
        }
    }
}

extension ElementView {
    private var coefficientBinding: Binding<Int> {
        Binding {
            return element.coefficient
        } set: { updatedValue in
            element.coefficient = updatedValue
        }
    }
    
    private var elementsBinding: Binding<[Element]> {
        Binding {
            return element.elements
        } set: { updatedValue in
            element.elements = updatedValue
        }
    }
}

