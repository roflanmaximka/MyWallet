import Foundation
import CoreData

enum ExpenseCDSort: String {
    case createdAt
    case updatedAt
    case occuredOn
}

enum ExpenseCDFilterTime: String {
    case all
    case week
    case month
}
//Модель для сохранения класса при входе в базу
public class ExpenseCD: NSManagedObject, Identifiable {
    //Создание операции
    @NSManaged public var createdAt: Date?
    //Обновление операции
    @NSManaged public var updatedAt: Date?
    //Тип операции
    @NSManaged public var type: String?
    //Название операции
    @NSManaged public var title: String?
    //Категория операции
    @NSManaged public var tag: String?
    //Дата операции
    @NSManaged public var occuredOn: Date?
    //Заметка операции
    @NSManaged public var note: String?
    //Сума операции
    @NSManaged public var amount: Double
    //Прикрепленное изображение
    @NSManaged public var imageAttached: Data?
}

extension ExpenseCD {
    static func getAllExpenseData(sortBy: ExpenseCDSort = .occuredOn, ascending: Bool = true, filterTime: ExpenseCDFilterTime = .all) -> NSFetchRequest<ExpenseCD> {
        let request: NSFetchRequest<ExpenseCD> = ExpenseCD.fetchRequest() as! NSFetchRequest<ExpenseCD>
        let sortDescriptor = NSSortDescriptor(key: sortBy.rawValue, ascending: ascending)
        if filterTime == .week {
            let startDate: NSDate = Date().getLast7Day()! as NSDate
            let endDate: NSDate = NSDate()
            let predicate = NSPredicate(format: "occuredOn >= %@ AND occuredOn <= %@", startDate, endDate)
            request.predicate = predicate
        } else if filterTime == .month {
            let startDate: NSDate = Date().getLast30Day()! as NSDate
            let endDate: NSDate = NSDate()
            let predicate = NSPredicate(format: "occuredOn >= %@ AND occuredOn <= %@", startDate, endDate)
            request.predicate = predicate
        }
        request.sortDescriptors = [sortDescriptor]
        return request
    }
}
