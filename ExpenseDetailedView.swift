import SwiftUI

struct ExpenseDetailedView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // CoreData
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @ObservedObject private var viewModel: ExpenseDetailedViewModel
    @AppStorage(UD_EXPENSE_CURRENCY) var CURRENCY: String = ""
    
    @State private var confirmDelete = false
    
    init(expenseObj: ExpenseCD) {
        viewModel = ExpenseDetailedViewModel(expenseObj: expenseObj)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.primary_color.edgesIgnoringSafeArea(.all)
                
                VStack {
                    
                    ToolbarModelView(title: "Ваша операция", button1Icon: IMAGE_DELETE_ICON, button2Icon: IMAGE_SHARE_ICON) { self.presentationMode.wrappedValue.dismiss() }
                        button1Method: { self.confirmDelete = true }
                        button2Method: { viewModel.shareNote() }
                    
                    ScrollView(showsIndicators: false) {
                        
                        VStack(spacing: 24) {
                            ExpenseDetailedListView(title: "Название", description: viewModel.expenseObj.title ?? "")
                            ExpenseDetailedListView(title: "Сумма", description: "\(viewModel.expenseObj.amount)\(CURRENCY)")
                            ExpenseDetailedListView(title: "Тип операции", description: viewModel.expenseObj.type == TRANS_TYPE_INCOME ? "Доход" : "Расход" )
                            ExpenseDetailedListView(title: "Метка", description: getTransTagTitle(transTag: viewModel.expenseObj.tag ?? ""))
                            ExpenseDetailedListView(title: "Когда", description: getDateFormatter(date: viewModel.expenseObj.occuredOn, format: "EEEE, dd MMM hh:mm a"))
                            if let note = viewModel.expenseObj.note, note != "" {
                                ExpenseDetailedListView(title: "Заметка", description: note)
                            }
                            if let data = viewModel.expenseObj.imageAttached {
                                VStack(spacing: 1) {
                                    HStack { TextView(text: "Прикрепленное изображение", type: .caption).foregroundColor(Color.init(hex: "828282")); Spacer() }
                                    Image(uiImage: UIImage(data: data)!)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 250).frame(maxWidth: .infinity)
                                        .background(Color.secondary_color)
                                        .cornerRadius(4)
                                }
                            }
                        }.padding(16)
                        
                        Spacer().frame(height: 24)
                        Spacer()
                    }
                    .alert(isPresented: $confirmDelete,
                                content: {
                                    Alert(title: Text(APP_NAME), message: Text("Вы уверены что хотите удалить операцию?"),
                                        primaryButton: .destructive(Text("Удалить")) {
                                            viewModel.deleteNote(managedObjectContext: managedObjectContext)
                                        }, secondaryButton: Alert.Button.cancel(Text("Отменить"), action: { confirmDelete = false })
                                    )
                                })
                }.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: AddExpenseView(viewModel: AddExpenseViewModel(expenseObj: viewModel.expenseObj)), label: {
                            Image("pencil_icon").resizable().frame(width: 28.0, height: 28.0)
                            Text("Редактировать").modifier(InterFont(.semiBold, size: 18)).foregroundColor(.white)
                        })
                        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 20))
                        .background(Color.main_color).cornerRadius(25)
                    }.padding(24)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

struct ExpenseDetailedListView: View {
    
    var title: String
    var description: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack { TextView(text: title, type: .caption).foregroundColor(Color.init(hex: "828282")); Spacer() }
            HStack { TextView(text: description, type: .body_1).foregroundColor(Color.text_primary_color); Spacer() }
        }
    }
}

//struct ExpenseDetailedView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExpenseDetailedView()
//    }
//}
