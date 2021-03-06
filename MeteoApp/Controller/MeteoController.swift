//
//  MeteoController.swift
//  MeteoApp
//
//  Created by Dea-loC on 05/04/2018.
//  Copyright © 2018 Dea-loC. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

class MeteoController: UIViewController {

    @IBOutlet weak var villeLabel: UILabel!
    
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var iconeTempActuel: UIImageView!
    @IBOutlet weak var descTempActuel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let previsionCell = "PrevisionCell"
    
    var locationManager: CLLocationManager?
    var previsions = [Prevision]()
    var previsionsJournalieres = [PrevisionJournaliere]()
    var enTrainDeRecupererLeDonnees = false
    var jour = UIColor(red: 0, green: 191 / 255, blue: 1, alpha: 1)
    var nuit = UIColor(red: 19 / 255, green: 24 / 255, blue: 98 / 255, alpha: 1)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        miseEnPlaceCLLocation()
        miseEnPlaceTableView()
    }

    func obtenirPrevisionsMeteo(latitude: Double, longitude: Double) {
        enTrainDeRecupererLeDonnees = true
        let urlDeBase = "http://api.openweathermap.org/data/2.5/forecast?"
        let latitude = "lat=" + String(latitude)
        let longitude = "&lon=" + String(longitude)
        let uniteEtLangue = "&units=metric&lang=fr"
        let cleApi = "&APPID=" + API
        let urlString = urlDeBase + latitude + longitude + uniteEtLangue + cleApi
        guard let url = URL(string: urlString) else { return }
        Alamofire.request(url).responseJSON { (response) in
            if let reponse = response.value as? [String: AnyObject] {
                if let infoVille = reponse["city"] as? [String: AnyObject] {
                    if let maVille = infoVille["name"] as? String {
                        self.villeLabel.text = maVille
                        if let liste = reponse["list"] as? NSArray {
                            for element in liste {
                                if let dict = element as? [String: AnyObject] {
                                    if let main = dict["main"] as? [String: AnyObject] {
                                        if let temp = main["temp"] as? Double {
                                            if let weather = dict["weather"] as? NSArray, weather.count > 0 {
                                                if let tempsActuel = weather[0] as? [String: AnyObject] {
                                                    if let desc = tempsActuel["description"] as? String {
                                                        if let icone = tempsActuel["icon"] as? String {
                                                            if let date = dict["dt_txt"] as? String {
                                                                let nouvellePrevision = Prevision(temperature: temp, date: date, icone: icone, desc: desc)
                                                                self.previsions.append(nouvellePrevision)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            // Recharger les données
                            self.miseEnPlaceValeursDuMoment()
                            self.obtenirPrevisionsJournalieres()
                        }
                    }
                }
            }
        }
    }
    
    func miseEnPlaceValeursDuMoment() {
        if previsions.count > 0 {
            let tempsActuel = previsions[0]
            temperatureLabel.text = tempsActuel.temperateur.convertirEnIntString()
            descTempActuel.text = tempsActuel.desc
            ImageDownloader.obtenir.imageDepuis(tempsActuel.icone, imageView: iconeTempActuel)
            if tempsActuel.icone.contains("d") {
                view.backgroundColor = jour
            } else {
                view.backgroundColor = nuit
            }
        }
    }
    
    func obtenirPrevisionsJournalieres() {
        var jour = ""
        var icone = ""
        var min = 0.0
        var max = 0.0
        var desc = ""
        for prevision in previsions {
            if prevision.jour != "" {
                if prevision.jour != jour {
                    if jour != "" {
                        let nouvelleJournee = PrevisionJournaliere(jour: jour, icone: icone, min: min, max: max, desc: desc)
                        previsionsJournalieres.append(nouvelleJournee)
                    }
                    jour = prevision.jour
                    icone = prevision.icone
                    min = prevision.temperateur
                    max = prevision.temperateur
                    desc = prevision.desc
                    
                } else {
                    if prevision.temperateur > max {
                        max = prevision.temperateur
                    }
                    if prevision.temperateur < min {
                        min = prevision.temperateur
                    }
                    if prevision.date.contains("12:") {
                        icone = prevision.icone
                        desc = prevision.desc
                    }
                }
                
            }
        }
        enTrainDeRecupererLeDonnees = false
        self.tableView.reloadData()
    }

}
