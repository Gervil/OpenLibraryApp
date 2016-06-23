//
//  TableViewController.swift
//  OpenLibraryApp
//
//  Created by Gerardo Villarroel on 6/20/16.
//  Copyright © 2016 Gerardo Villarroel. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {

    var listadoDeItems = [NSManagedObject]()
    var item: AnyObject = 0
    var index = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Botón para eliminar los items de la lista.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.navigationItem.leftBarButtonItem?.title = "Editar"
        
        //Botón para agregar items a la lista.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(TableViewController.agregarLibros))
    }
    
    //Actualización del botón Editar.
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if (self.editing) {
            self.editButtonItem().title = "OK"
        } else {
            self.editButtonItem().title = "Editar"
        }
    }
    
    func agregarLibros() {
        //Crear Alert Controller
        let alertController = UIAlertController(title: "Buscar Libro", message: "Ingrese el ISBN del libro", preferredStyle: UIAlertControllerStyle.Alert)
        
        //Acción del botón Aceptar
        let aceptar = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default, handler: ({
            (_) in
                let field = alertController.textFields![0]
                var resultadoBusqueda = [AnyObject]()
                resultadoBusqueda = self.buscarLibro(field.text!)
            
                if !resultadoBusqueda.isEmpty {
                    if resultadoBusqueda[0] as! String == "No Encontrado" {
                        self.errorAlert("Libro no encontrado.")
                    } else {
                        self.guardarItem(resultadoBusqueda)
                        self.tableView.reloadData()
                        self.performSegueWithIdentifier("Detalle", sender: self)
                    }
                } else {
                    self.errorAlert("Por favor revisa tu conexión a Internet.")
                }
            }
        ))
        alertController.addAction(aceptar)
        
        //Acción del botón Cancelar
        let cancelar = UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelar)

        //Campo de texto
        alertController.addTextFieldWithConfigurationHandler({
            (textField) in
            textField.placeholder = "ISBN"
            textField.keyboardType = UIKeyboardType.NumberPad
        })
        
        //Muestra de la alerta en pantalla
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //Guardar items en la lista.
    func guardarItem(itemToSave: [AnyObject]) {
        if !buscarEnListado(itemToSave[0] as! String) {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            let libro = NSEntityDescription.entityForName("Libros", inManagedObjectContext: managedContext)
            let item = NSManagedObject(entity: libro!, insertIntoManagedObjectContext: managedContext)

            item.setValue(itemToSave[0], forKey: "titulo")
            if itemToSave.count > 2 {
                item.setValue(itemToSave[1], forKey: "portada")
                item.setValue(itemToSave[2], forKey: "autores")
            } else {
                item.setValue(itemToSave[1], forKey: "autores")
            }
            
            do {
                try managedContext.save()
                listadoDeItems.append(item)
            } catch {
                print("Error de escritura!")
            }
        }
    }
    
    //Buscar en el listado de Libros preferidos.
    func buscarEnListado(tituloDelLibro: String)-> Bool {
        var respuesta = false
        var contador = 0
        if listadoDeItems.isEmpty {
            index = 1
        } else {
            for libro in listadoDeItems {
                contador += 1
                let tituloDelLibroEnLista = libro.valueForKey("titulo") as? String!
            
                if tituloDelLibroEnLista! == tituloDelLibro {
                    index = contador
                    respuesta = true
                    break
                }
                if contador == listadoDeItems.count {
                    index = contador + 1
                    break
                }
            }
        }
        return respuesta
    }
    
    //Carga Inicial.
    override func viewWillAppear(animated: Bool) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Libros")
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            listadoDeItems = results as! [NSManagedObject]
        } catch {
            print("Error de carga")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listadoDeItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
        let item = listadoDeItems[indexPath.row]
        
        //Muestra de los tìtulos en la lista.
        cell.textLabel?.text = item.valueForKey("titulo") as? String

        //Muestra de las imágenes en la lista.
        if item.valueForKey("portada") != nil {
            cell.imageView?.image = UIImage(data: (item.valueForKey("portada") as? NSData)!)
        } else {
            cell.imageView?.image = UIImage(named: "sin-portada")
        }
        
        //Cambio de tamaño de las imágenes en el listado.
        let itemSize: CGSize = CGSize(width: 74, height: 99)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.mainScreen().scale)
        let imageRect: CGRect = CGRectMake(0, 0, itemSize.width, itemSize.height)
        cell.imageView!.image?.drawInRect(imageRect)
        cell.imageView!.image? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Muestra de los autores.
        cell.detailTextLabel?.text = item.valueForKey("autores") as? String

        return cell
    }
    
    //Borrar items
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .Default, title: "Eliminar") {
            action in
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
            managedContext.deleteObject(self.self.listadoDeItems[indexPath.row])
            self.listadoDeItems.removeAtIndex(indexPath.row)
            self.tableView.reloadData()
            
            do {
                try managedContext.save()
            } catch {
                abort()
            }
        }
        return [deleteAction]
    }
    
    //ISBN de prueba: 0671041177
    //ISBN sin datos: 5
    //ISBN sin portada: 4
    func buscarLibro(textoISBN: String)-> [AnyObject] {
        let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(textoISBN)"
        let url = NSURL(string: urls)
        var resultado = [AnyObject]()
        //0 = titulo
        //1 = portada
        //2 = autores
        do {
            let datos = try NSData(contentsOfURL: url!, options: NSDataReadingOptions())
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(datos, options: NSJSONReadingOptions.MutableLeaves)
                let dico1 = json as! NSDictionary
                
                //Busqueda del Libro
                var dico2: NSDictionary? = nil
                dico2 = dico1["ISBN:\(textoISBN)"] as? NSDictionary
                if dico2 != nil {
                    resultado.append(dico2!["title"] as! NSString as String)
                    
                    //Portada del Libro
                    var dico3: NSDictionary? = nil
                    dico3 = dico2!["cover"] as? NSDictionary
                    if dico3 != nil {
                        resultado.append(loadImageFromUrl(dico3!["medium"] as! NSString as String))
                    }
                    
                    //Autores del Libro
                    if let autores = dico2!["authors"] as? [[String: AnyObject]] {
                        var contador = 0
                        for autor in autores {
                            if let name = autor["name"] as? String {
                                contador += 1
                                if autores.count == 1 {
                                    resultado.append(name)
                                } else if contador == 1 {
                                    resultado.append(name)
                                } else {
                                    resultado[2] = (resultado[2] as! String) + ", " + name
                                }
                            }
                        }
                    }
                } else {
                    resultado.append("No Encontrado")
                }
            } catch {
                errorAlert("Problemas de conexión con el servidor.")
            }
        }catch {
            errorAlert("Por favor revisa tu conexión a Internet.")
        }
        return resultado
    }
    
    //Alertas por errores.
    func errorAlert(mensaje: String) {
        let alertController = UIAlertController(title: "Error", message: mensaje, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //Paso de datos a la vista de detalle.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let sigVista = segue.destinationViewController as! DetalleViewController
        let rutaIndice = self.tableView.indexPathForSelectedRow
        
        if rutaIndice != nil {
            item = listadoDeItems[rutaIndice!.row]
        } else {
            item = listadoDeItems[index - 1]
        }
        
        var detalleLibro = [AnyObject]()
        detalleLibro.append((item.valueForKey("titulo") as? String)!)
        if item.valueForKey("portada") != nil {
            detalleLibro.append((item.valueForKey("portada") as? NSData)!)
        }
        detalleLibro.append((item.valueForKey("autores") as? String)!)
        
        sigVista.detalleLibro = detalleLibro
    }
    
    //Descargar Imagen desde Internet para guardarla en la BD.
    func loadImageFromUrl(url: String)-> NSData {
        let url = NSURL(string: url)!
        let nsData = NSData(contentsOfURL: url)!

        return nsData
    }
}

