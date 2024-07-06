//
//  CompareView.swift
//  Compare
//
//  Created by Aanchal Patial on 22/06/24.
//

import SwiftUI
import Lottie

struct CompareView: View {

    @StateObject private var viewModel = CompareViewModel2()
    @FocusState private var isFocused: Bool
    let placeholderImage = UIImage(systemName: "plus")!

    var body: some View {
        UITextField.appearance().clearButtonMode = .whileEditing
        return NavigationStack {
            List {
                Toggle(viewModel.inputType.toggleText, isOn: $viewModel.inputType.toggleValue)
                Section(viewModel.inputType.inputSectionText) {
                    HStack(spacing: 8) {
                        switch viewModel.inputType {
                        case .text:
                            TextField("First keyword", text: $viewModel.firstKeyword)
                                .multilineTextAlignment(.leading)
                            Divider()
                            TextField("Second keyword", text: $viewModel.secondKeyword)
                                .multilineTextAlignment(.leading)
                        case .image:
                            BlackBorderImageView(image: $viewModel.firstImage, placeholder: placeholderImage)
                            Spacer()
                            BlackBorderImageView(image: $viewModel.secondImage, placeholder: placeholderImage)
                        }
                    }

                    TextField("Ask your question here", text: $viewModel.question)

                    HStack {
                        TextField("(Optional) Add criterias here ...", text: $viewModel.criteria)
                            .focused($isFocused)
                        SecondaryButtonView(title: "add", width: 60, handler: {
                            viewModel.addCategoryButtonPressed()
                            isFocused = false
                        })
                    }

                    if !viewModel.criteriaList.isEmpty {
                        CriteriaListView(criterias: $viewModel.criteriaList)
                    }

                    PrimaryButtonView(title: "compare", handler: {
                        viewModel.compareButtonPressed()
                        isFocused = false
                    })
                }

                if viewModel.playbackMode == .playing(.fromProgress(0, toProgress: 1, loopMode: .loop)) {
                    HStack {
                        Spacer()
                        LottieView(animation: .named("loader-cube"))
                            .playbackMode(viewModel.playbackMode)
                        Spacer()
                    }
                }

                if let comparisonResult = viewModel.comparisonResult {

                    Section("Introduction") {
                        Text(comparisonResult.introduction)
                    }

                    Section("Comparison Table") {
                        Grid(alignment: .leading) {
                            ForEach(comparisonResult.comparisonTable, id: \.self) { row in

                                GridRow {
                                    ForEach(row, id: \.self) { cell in
                                        if row == comparisonResult.comparisonTable.first {
                                            Text(cell)
                                                .fontWeight(.semibold)
                                        } else {
                                            Text(cell)
                                        }
                                    }
                                }
                                Divider()
                            }

                        }
                        .fixedSize(horizontal: false, vertical: true)
                    }

                    Section("Conclusion") {
                        Text(comparisonResult.conclusion)
                    }
                }
            }
            .font(.custom("Verdana", size: 14))
            .navigationTitle("compareIt!")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("", systemImage: "line.3.horizontal") {
                        viewModel.presentHamburgerSheet = true
                    }
                    .tint(.black)
                    .confirmationDialog("", isPresented: $viewModel.presentHamburgerSheet) {
                        Button("Tutorial") {
                            viewModel.presentTutorialSheet = true
                        }
                        Button("Logout") {
                            viewModel.alertType = .logout
                            viewModel.presentAlert = true
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("\(viewModel.remainingFreeTrialDays) days left") {
                        viewModel.presentPremiumSheet = true
                    }
                }
            }
            .alert(isPresented: $viewModel.presentAlert) {
                switch viewModel.alertType {
                case .logout:
                    Alert(title: Text(viewModel.alertType.title),
                          message: Text(viewModel.alertType.message),
                          primaryButton: .cancel(),
                          secondaryButton: .destructive(Text("Yes"), action: {
                        viewModel.logout()
                    }))
                case .premium:
                    Alert(title: Text(viewModel.alertType.title),
                          message: Text(viewModel.alertType.message),
                          primaryButton: .default(Text("Buy"), action: {
                        viewModel.presentPremiumSheet = true
                    }), secondaryButton: .destructive(Text("Cancel")))
                default:
                    Alert(title: Text(viewModel.alertType.title),
                          message: Text(viewModel.alertType.message))
                }

            }
        }
        .sheet(isPresented: $viewModel.presentPremiumSheet) {
            PremiumView(freePremiumDaysLeft: viewModel.remainingFreeTrialDays)
        }
        .sheet(isPresented: $viewModel.presentTutorialSheet) {
            TutorialView()
                .presentationBackground(.clear)
        }
    }
}

#Preview {
    CompareView()
}
