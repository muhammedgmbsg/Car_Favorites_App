//
//  ViewController.swift
//  FavoriteCity&CoreData
//
//  Created by Muhammed on 22.03.2024.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    //verileri çekince diziye atmak için dizi tanımlıyoruz
    var modelsArray = [String]()
    var idArray = [UUID]()
    
    var selectedModels = ""
    var selectedId : UUID?
    
    
    
    //diğer sayfadan mesaj gelince getDatayı calıstır
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getDAta), name: NSNotification.Name(rawValue:"NewData"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
      
        
      //Navigaton barda icon tanımlama
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClick))
        
        getDAta()
    }
    

    @objc func addButtonClick(){
        selectedModels = ""
        performSegue(withIdentifier: "toDetailsVc", sender: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.text = modelsArray[indexPath.row]
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toDetailsVc"{
            
            let destinationVc = segue.destination as! DetailsViewController
            destinationVc.choosenModels =  selectedModels
            destinationVc.choosenId = selectedId
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedModels = modelsArray[indexPath.row]
        selectedId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVc", sender: nil)
    }
    
    //VERİ ÇEKME
  	@objc   func getDAta(){
        modelsArray.removeAll(keepingCapacity: false)
             idArray.removeAll(keepingCapacity: false)
             
             let appDelegate = UIApplication.shared.delegate as! AppDelegate
             let context = appDelegate.persistentContainer.viewContext
             
             let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cars")
        
             //Çekme işlemini hızlandıran ayar
             fetchRequest.returnsObjectsAsFaults = false
             
             do {
                 let results = try context.fetch(fetchRequest)
                 if results.count > 0 {
                     
                     //gelen veriyi parçalayıp diziye atıyoruz.
                     for result in results as! [NSManagedObject] {
                         
                                     if let name = result.value(forKey: "car_models") as? String {
                                         self.modelsArray.append(name)
                                     }
                                     
                                     if let id = result.value(forKey: "id") as? UUID {
                                         self.idArray.append(id)
                                     }
                                     //tableviewı veri geldikce gunceller
                                     self.tableView.reloadData()
                                     
                                 }
                 }
                 

             } catch {
                 print("error")
             }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cars")
            let idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
               let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                        
                        if let id = result.value(forKey: "id") as? UUID {
                            
                            if id == idArray[indexPath.row] {
                                context.delete(result)
                                modelsArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                do {
                                    try context.save()
                                    
                                } catch {
                                    print("error")
                                }
                                
                                break
                                
                            }
                            
                        }
                        
                        
                    }
                    
                    
                }
            } catch {
                print("error")
            }
            
            
            
            
        }
    }
}



          
