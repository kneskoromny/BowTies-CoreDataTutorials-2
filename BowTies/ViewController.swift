/// Copyright (c) 2020 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import CoreData

class ViewController: UIViewController {
  // MARK: - IBOutlets
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var ratingLabel: UILabel!
  @IBOutlet weak var timesWornLabel: UILabel!
  @IBOutlet weak var lastWornLabel: UILabel!
  @IBOutlet weak var favoriteLabel: UILabel!
  @IBOutlet weak var wearButton: UIButton!
  @IBOutlet weak var rateButton: UIButton!

  // MARK: - Properties
    var managedContext: NSManagedObjectContext!
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    // создаем экземпляр appdelegate чтоб получить доступ к контексту
    let appDelegate =
       UIApplication.shared.delegate as? AppDelegate
     managedContext = appDelegate?.persistentContainer.viewContext
    
   // загружаем данные из plist в Core Data
     insertSampleData()
    
   // segmented сontrol имеет вкладки для фильтрации по цвету, поэтому предикат добавляет условие для поиска галстуков-бабочек, соответствующих выбранному цвету.
     let request: NSFetchRequest<BowTie> = BowTie.fetchRequest()
     let firstTitle = segmentedControl.titleForSegment(at: 0) ?? ""
    // условие для запроса
     request.predicate = NSPredicate(
       format: "%K = %@",
       argumentArray: [#keyPath(BowTie.searchKey), firstTitle])
    
   do { // создаем массив с элементами согласно запросу с предикатом
       let results = try managedContext.fetch(request)
   // выводим на экран первый элемент массива
       if let tie = results.first {
         populate(bowtie: tie)
       }
     } catch let error as NSError {
       print("Could not fetch \(error), \(error.userInfo)")
     }
    
  }

  // MARK: - IBActions

  @IBAction func segmentedControl(_ sender: UISegmentedControl) {
    // Add code here
  }

  @IBAction func wear(_ sender: UIButton) {
    // Add code here
  }

  @IBAction func rate(_ sender: UIButton) {
    // Add code here
  }
  
  // загружаем данные из plist в Core Data
  func insertSampleData() {
    let fetch: NSFetchRequest<BowTie> = BowTie.fetchRequest()
    fetch.predicate = NSPredicate(format: "searchKey != nil")
    let tieCount = (try? managedContext.count(for: fetch)) ?? 0
    // проверяем загружен ли уже список в Core Data
    if tieCount > 0 {
      return
  }
    // если нет, то загружаем его
    let path = Bundle.main.path(forResource: "SampleData",
                                ofType: "plist")
    let dataArray = NSArray(contentsOfFile: path!)!
    
    for dict in dataArray {
      // экземпляр сущности/класса в контексте
      let entity = NSEntityDescription.entity(
        forEntityName: "BowTie",
        in: managedContext)!
      // экземпляр модели сущности/класса
      let bowtie = BowTie(entity: entity,
                          insertInto: managedContext)
      // кастим словарь из plist до нужного типа данных
      let btDict = dict as! [String: Any]
      bowtie.id = UUID(uuidString: btDict["id"] as! String)
      bowtie.name = btDict["name"] as? String
      bowtie.searchKey = btDict["searchKey"] as? String
      bowtie.rating = btDict["rating"] as! Double
      
      // работа с цветом
      let colorDict = btDict["tintColor"] as! [String: Any]
      bowtie.tintColor = UIColor.color(dict: colorDict)
      
      // работа с изображением
      let imageName = btDict["imageName"] as? String
      let image = UIImage(named: imageName!)
      bowtie.photoData = image?.pngData()
      
      bowtie.lastWorn = btDict["lastWorn"] as? Date
      let timesNumber = btDict["timesWorn"] as! NSNumber
      bowtie.timesWorn = timesNumber.int32Value
      bowtie.isFavourite = btDict["isFavorite"] as! Bool
      bowtie.url = URL(string: btDict["url"] as! String)
      
  }
    try? managedContext.save()
  }
  // вставляем данные элемента массива в аутлеты
  func populate(bowtie: BowTie) {
    // извлекаем опционалы
    guard let imageData = bowtie.photoData as Data?,
      let lastWorn = bowtie.lastWorn as Date?,
      let tintColor = bowtie.tintColor else {
  return
  }
    imageView.image = UIImage(data: imageData)
    nameLabel.text = bowtie.name
    ratingLabel.text = "Rating: \(bowtie.rating)/5"
    timesWornLabel.text = "# times worn: \(bowtie.timesWorn)"
    // форматтер нужен для определения стиля даты
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none
    
    lastWornLabel.text =
      "Last worn: " + dateFormatter.string(from: lastWorn)
    favoriteLabel.isHidden = !bowtie.isFavourite
    view.tintColor = tintColor
  }
}

//расширение для работы с цветом
private extension UIColor {
 static func color(dict: [String: Any]) -> UIColor? {
   guard
     let red = dict["red"] as? NSNumber,
     let green = dict["green"] as? NSNumber,
     let blue = dict["blue"] as? NSNumber else {
return nil
}
   return UIColor(
     red: CGFloat(truncating: red) / 255.0,
     green: CGFloat(truncating: green) / 255.0,
     blue: CGFloat(truncating: blue) / 255.0,
     alpha: 1)
} }