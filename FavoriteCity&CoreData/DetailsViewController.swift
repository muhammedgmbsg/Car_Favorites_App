//
//  DetailsViewController.swift
//  FavoriteCity&CoreData
//
//  Created by Muhammed on 22.03.2024.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var favoriteImages: UIImageView!
    
    
    
    @IBOutlet weak var modelsTextField: UITextField!
    
    
    @IBOutlet weak var yearsTextField: UITextField!
    
    
    
    @IBOutlet weak var gearsTextField: UITextField!
    
    
    
    @IBOutlet weak var fuelTextField: UITextField!
    
    
    
    @IBOutlet weak var bodyTextField: UITextField!
    
    @IBOutlet weak var saveButoon: UIButton!
    var choosenModels = ""
    var choosenId: UUID?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(choosenModels != ""){
            
            saveButoon.isHidden = true
            //CoreData
            
            
                       let appDelegate = UIApplication.shared.delegate as! AppDelegate
                       let context = appDelegate.persistentContainer.viewContext
                       
                       let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cars")
                       let idString = choosenId?.uuidString
                       fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
                       fetchRequest.returnsObjectsAsFaults = false
                       
                       do {
                          let results = try context.fetch(fetchRequest)
                           
                           if results.count > 0 {
                               
                               for result in results as! [NSManagedObject] {
                                   
                                   if let models = result.value(forKey: "car_models") as? String {
                                    modelsTextField.text = models
                                   }

                                   if let body = result.value(forKey: "car_body_type") as? String {
                                       bodyTextField.text = body
                                   }
                                   if let fuel = result.value(forKey: "car_fuel_type") as? String {
                                       fuelTextField.text = fuel
                                   }
                                   if let gear = result.value(forKey: "car_gearmodels") as? String {
                                       gearsTextField.text = gear
                                   }
                                   
                                   if let year = result.value(forKey: "car_years") as? Int {
                                       yearsTextField.text = String(year)
                                   }
                                   
                                   if let imageData = result.value(forKey: "image") as? Data {
                                       let image = UIImage(data: imageData)
                                       favoriteImages.image = image
                                   }
                                   
                               }
                           }

                       } catch{
                           print("error")
                       }
                       
                       
                   }

       //ekrana dokunma hareketlerini algılama ve klavyeyi kapama
        
        let gestureRecognizeer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizeer)
        
        
        //kullanıcı resme tıklayabilr mi ?
        favoriteImages?.isUserInteractionEnabled = true
        
        //resme dokunma hareketi verme
        let imageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        favoriteImages.addGestureRecognizer(imageTapGestureRecognizer)
        
    }
    
    //ekrana dokununca degıslıklerı kaydet kapat(klavyeyı algılar)
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
 
    //resme dokununca ne olacak ?
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker .delegate = self
        
        //görseli kameradan mı galeriden mi alacak ?
        picker.sourceType = .photoLibrary
        
        
        //görseli zoomlama gibi editleyebilecek mi ?
        picker.allowsEditing = true
        present(picker,animated: true,completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        favoriteImages.image = info[.originalImage] as? UIImage
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        //local veritabanı işlemleri için appdelegate ve context tanımlama
             let appDelegate = UIApplication.shared.delegate as! AppDelegate
             let context = appDelegate.persistentContainer.viewContext
             
        //tablo tanımlama
             let Carstable = NSEntityDescription.insertNewObject(forEntityName: "Cars", into: context)
             
       //tabloya değer set etme
       Carstable.setValue(UUID(), forKey: "id")
       Carstable.setValue(modelsTextField.text!, forKey: "car_models")
       Carstable.setValue(bodyTextField.text!, forKey: "car_body_type")
       Carstable.setValue(fuelTextField.text!, forKey: "car_fuel_type")
       Carstable.setValue(gearsTextField.text!, forKey: "car_gearmodels")
       
       if let year = Int(yearsTextField.text!) {
                 Carstable.setValue(year, forKey: "car_years")
             }
             
           
       //imageViewda tutulan resmi sıkıstırıp dataya attık.
       let data = favoriteImages.image!.jpegData(compressionQuality: 0.5)
       
       Carstable.setValue(data, forKey: "image")
             
             do {
                 try context.save()
                 print("success")
             } catch {
                 print("error")
             }
        
        //yeni data geldiğini tüm appe bildiirm olarak gönder
        NotificationCenter.default.post(name: NSNotification.Name("NewData"), object: nil)
        
        //önceki sayfaya git
        self.navigationController?.popViewController(animated: true)
   }
    }
    
    
    
    
    
  
