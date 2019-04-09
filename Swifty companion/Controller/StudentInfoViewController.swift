//
//  StudentInfoViewController.swift
//  Swifty companion
//
//  Created by Viktoriia LIKHOTKINA on 2/7/19.
//  Copyright © 2019 Viktoriia LIKHOTKINA. All rights reserved.
//

import UIKit
import Foundation
import Charts

class StudentInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChartViewDelegate {
    var userData : Student?
    
    @IBOutlet weak var projectsTableView: UITableView!
    @IBOutlet weak var studentImage: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var pieChartView: PieChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAllData()
        projectsTableView.delegate = self
        projectsTableView.dataSource = self
        pieChartView.delegate = self
        
        let nib = UINib.init(nibName: "ProjectTableViewCell", bundle: nil)
        projectsTableView.register(nib, forCellReuseIdentifier: "projectCell")
        let projectHeaderNib = UINib.init(nibName: "ProjectsHeaderTableViewCell", bundle: nil)
        projectsTableView.register(projectHeaderNib, forCellReuseIdentifier: "projectSectionName")
        
        prepareDataForChart()
    }
    
    func prepareDataForChart() {
        if userData?.cursusUsers != nil && (userData?.cursusUsers?.count)! > 0 && (userData?.cursusUsers?[0].skills.contains(where: {$0.skillLevel > 0
        }))! {
            let dataPoints = userData!.cursusUsers?[0].skills.map { $0.skillName }
            let values = userData!.cursusUsers?[0].skills.map { $0.skillLevel}
            guard dataPoints != nil && values != nil else {
                return
            }
            setChart(dataPoints: dataPoints!, values: values!)
        }
    }
    
    func setAllData() {
        let dataImage = try? Data(contentsOf: (userData?.imageUrl)!)
        if dataImage != nil {
            studentImage.image = UIImage(data: (dataImage)!)
        }
        else {
            studentImage.image = UIImage(named: "42")
        }
        firstNameLabel.text = userData?.firstName
        lastNameLabel.text = userData?.lastName
        if let cursusUsers = userData?.cursusUsers, cursusUsers.count > 0 {
            if let grade = cursusUsers[0].grade {
                gradeLabel.text = grade
            }
            else {
                gradeLabel.text = "Not graded"
            }
            levelLabel.text = "\(String(describing: cursusUsers[0].level))"
        }
        else {
            gradeLabel.text = "Not graded"
            levelLabel.text = "0.0"
        }
        if let phoneNumber = userData?.phoneNumber, phoneNumber != "" {
            phoneLabel.text = phoneNumber
        }
        else {
            phoneLabel.text = "Unknown" 
        }
        emailLabel.text = userData?.email
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if userData?.validatedProjects != nil {
            if userData?.validatedProjects?[section].headerStatus == .open && (userData?.validatedProjects?[section].childProjects.count)! > 0 {
                return ((userData?.validatedProjects?[section].childProjects.count)!)
            }
            return 1
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return userData?.validatedProjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if (userData?.validatedProjects?[indexPath.section].childProjects.count)! > 0 && userData?.validatedProjects?[indexPath.section].headerStatus == .open {
                userData?.validatedProjects?[indexPath.section].headerStatus = .close
            }
            else if (userData?.validatedProjects?[indexPath.section].childProjects.count)! > 0 {
                userData?.validatedProjects?[indexPath.section].headerStatus = .open
            }
            tableView.reloadSections([indexPath.section], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 && (userData?.validatedProjects?[indexPath.section].childProjects.count)! > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "projectSectionName", for: indexPath) as! ProjectsHeaderTableViewCell
            cell.projectSectionName.text = userData?.validatedProjects?[indexPath.section].projectNameStruct.name
            if (userData?.validatedProjects?[indexPath.section].childProjects.count)! > 0 && userData?.validatedProjects?[indexPath.section].headerStatus == .open {
                cell.setCollapsed()
            }
            else if (userData?.validatedProjects?[indexPath.section].childProjects.count)! > 0 {
                cell.setExpanded()
            }
            if userData?.validatedProjects?[indexPath.section].validated == true {
                cell.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 0.3907320205)
            }
            else {
                cell.backgroundColor = #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 0.387895976)
            }
            return cell
        }
        else if indexPath.row == 0 && (userData?.validatedProjects?[indexPath.section].childProjects.count)! == 0 && userData?.validatedProjects?[indexPath.section].projectNameStruct.parent_id == nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell", for: indexPath) as! ProjectTableViewCell
            cell.projectNameLabel.text = userData?.validatedProjects?[indexPath.section].projectNameStruct.name
            cell.projectStatusLabel.text = userData?.validatedProjects?[indexPath.section].status
            if let finalMark = userData?.validatedProjects?[indexPath.section].finalMark {
                cell.projectMarkLabel.text = String(describing: finalMark)
            }
            else {
                cell.projectMarkLabel.text = "n/a"
            }
            if userData?.validatedProjects?[indexPath.section].validated == true {
                cell.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 0.2867615582)
            }
            else {
                cell.backgroundColor = #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 0.2910958904)
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell", for: indexPath) as! ProjectTableViewCell
            cell.projectNameLabel.text = userData?.validatedProjects?[indexPath.section].childProjects[indexPath.row].projectNameStruct.name
            cell.projectStatusLabel.text = userData?.validatedProjects?[indexPath.section].childProjects[indexPath.row].status
            if let finalMark = userData?.validatedProjects?[indexPath.section].childProjects[indexPath.row].finalMark {
                cell.projectMarkLabel.text = String(describing: finalMark)
            }
            else {
                cell.projectMarkLabel.text = "n/a"
            }
            if userData?.validatedProjects?[indexPath.section].childProjects[indexPath.row].validated == true {
                cell.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 0.2867615582)
            }
            else {
                cell.backgroundColor = #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 0.2910958904)
            }
            return cell
        }
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        let descr = Description()
        descr.text = "Percentage shown on the chart"
        pieChartView.chartDescription = descr
        pieChartView.noDataText = "User hasn't any skills"
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            if values[i] == 0 {
                continue
            }
            let dataEntry = PieChartDataEntry(value: Double(round(1000 * values[i]) / 1000), label: "\(dataPoints[i]) \(values[i])", data:  "test" as AnyObject)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "User's skills")
        let pieChartData = PieChartData(dataSets: [pieChartDataSet])
        
        pieChartDataSet.yValuePosition = .outsideSlice
        pieChartView.drawHoleEnabled = true
        pieChartDataSet.sliceSpace = 2.0
        pieChartView.holeRadiusPercent = 0.40
        pieChartView.transparentCircleRadiusPercent = 0.43
        pieChartView.usePercentValuesEnabled = true
        
        pieChartDataSet.drawValuesEnabled = true
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.zeroSymbol = ""
        pieChartData.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        pieChartData.setValueFont(.systemFont(ofSize: 9))
        pieChartData.setValueTextColor(.black)
        
        var colors: [UIColor] = []
        
        for _ in 0..<dataPoints.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        
        pieChartDataSet.colors = colors
        
        let l = pieChartView.legend
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        
        self.pieChartView.drawEntryLabelsEnabled = false
        
        pieChartView.data = pieChartData
        pieChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: Highlight) {
        pieChartView.drawSlicesUnderHoleEnabled = true
    }
}

