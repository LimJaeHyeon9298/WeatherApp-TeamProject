



import UIKit
import WeatherKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // -MARK: iboutlet
    //첫번째 뷰
    @IBOutlet weak var firstview: UIView!
    @IBOutlet weak var tempLabel: UILabel!
    //작년 날씨 뷰
    @IBOutlet weak var LYtempView: UIView!
    //캘린더 뷰
    @IBOutlet weak var calenderView: UIView!
    //기능 뷰
    @IBOutlet weak var otherOptionView: UIView!
    //테이블뷰
    @IBOutlet weak var weekWeatherTableView: UITableView!
    //스크롤뷰
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    //서울의 좌표
    var myLocation = CLLocation(latitude: 37.5666, longitude: 126.9784)
    //날씨 데이터 저장
    var weather: Weather?
    //10일간 최고 최저 온도
    var weekWeatherMaxTempArray: [Int] = []
    var weekWeatherMinTempArray: [Int] = []
    var weekWeatherSymbolArray: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //ui함수
        setupUI()
        
        //view를 클릭 가능하도록 설정
        self.firstview.isUserInteractionEnabled = true
        self.LYtempView.isUserInteractionEnabled = true
        self.calenderView.isUserInteractionEnabled = true
        self.otherOptionView.isUserInteractionEnabled = true
        //제쳐스 추가
        self.firstview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.firstViewTapped)))
        self.LYtempView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.LYtempViewTapped)))
        self.calenderView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.calenderViewTapped)))
        self.otherOptionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.otherOptionViewTapped)))
        //테이블뷰 델리케이트 설정
        weekWeatherTableView.delegate = self
        weekWeatherTableView.dataSource = self
        
        //위치 매니저 생성 및 설정
        var locationManager = CLLocationManager()
        // 델리게이트를 설정하고,
        locationManager.delegate = self
        // 거리 정확도
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 위치 사용 허용 알림
        locationManager.requestWhenInUseAuthorization()
        DispatchQueue.global().async {
            // 위치 사용을 허용하면 현재 위치 정보를 가져옴
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
                self.myLocation = CLLocation(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)
            }
            else {
                print("위치 서비스 허용 off")
            }
        }
        
        reloadView()
        runWeatherKit()
    }
    //새로고침 함수
    func reloadView() {
        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    //새로고침 동작
    @objc func handleRefreshControl() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.scrollView.refreshControl?.endRefreshing()
            self.weekWeatherTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // data fetch(데이터 요청)
        //        WeatherService().getWeather { result in
        //            switch result {
        //            case .success(let weatherResponse):
        //                DispatchQueue.main.async {
        //                    self.weather = weatherResponse.weather.first
        //                    self.main = weatherResponse.main
        //                    self.name = weatherResponse.name
        //                    self.setWeatherUI()
        //                }
        //            case .failure(_ ):
        //                print("error")
        //            }
        //        }
    }
    
    func runWeatherKit() {
        //weatherkit 사용
        let weatherService = WeatherService.shared
        
        DispatchQueue.main.async {
            Task {
                do {
                    self.weather = try await weatherService.weather(for: self.myLocation)
                    //초기화
                    self.weekWeatherMaxTempArray = []
                    self.weekWeatherMinTempArray = []
                    self.weekWeatherSymbolArray = []
                    //10일간 날씨 받아오기
                    for i in 0...9 {
                        self.weekWeatherMaxTempArray.append(Int(round(self.weather!.dailyForecast[i].highTemperature.value)))
                        self.weekWeatherMinTempArray.append(Int(round(self.weather!.dailyForecast[i].lowTemperature.value)))
                        self.weekWeatherSymbolArray.append(self.weather!.dailyForecast[i].symbolName)
                    }
                    
                    //ui세팅
                    self.weekWeatherTableView.reloadData()
                } catch {
                    print("error")
                }
            }
        }
    }
    
    func setupUI() {
        //view들 모서리 커브
        firstview.layer.cornerRadius = 15
        LYtempView.layer.cornerRadius = 15
        calenderView.layer.cornerRadius = 15
        otherOptionView.layer.cornerRadius = 15
        
        firstview.backgroundColor = UIColor(patternImage: UIImage(named: "earthBackGround")!)
    }
    
    //첫번째 뷰를 눌렀을 때
    @objc func firstViewTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "showFirstView", sender: sender)
    }
    @objc func LYtempViewTapped(_ sender: UITapGestureRecognizer) {
        //alert 생성
        let sheet = UIAlertController(title: "'작년 오늘'의 온도는 국내 지역의 평균기온만 제공됩니다.", message: nil, preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "확인", style: .cancel, handler: { _ in print("확인")}))
        present(sheet, animated: true)
    }
    //캘린더뷰를 눌렀을 때
    @objc func calenderViewTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "showCalenderView", sender: sender)
    }
    //지역뷰를 눌렀을 때
    @objc func otherOptionViewTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "showRegionView", sender: sender)
    }
}

class WeekWeatherTableViewCell: UITableViewCell {
    //주간 날씨 테이블뷰 ui
    @IBOutlet weak var weekDay: UILabel!
    @IBOutlet weak var weekWeatherMinTemp: UILabel!
    @IBOutlet weak var weekWeatherMaxTemp: UILabel!
    @IBOutlet weak var weekWeatherImage: UIImageView!
    @IBOutlet weak var tempProgressView: UIProgressView!
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    //테이블뷰 셀의 숫자
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    //테이블뷰 셀 설정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = weekWeatherTableView.dequeueReusableCell(withIdentifier: "WeekWeatherTableViewCell", for: indexPath) as! WeekWeatherTableViewCell
        cell.selectionStyle = .none
        //DateFormatter 생성
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        //요일만 나오도록 설정
        formatter.dateFormat = "EEE"
        //오늘은 오늘이라고 설정하고 나머지는 요일로 나타내는 배열
        var weekDayArray: [String] = ["오늘"]
        for i in 1...9 {
            weekDayArray.insert(formatter.string(from: Date(timeIntervalSinceNow: 86400 * Double(i))), at: i)
        }
        //셀에 요일 넣기
        cell.weekDay.text = weekDayArray[indexPath.row]
        //최고, 최저 온도 및
        if self.weekWeatherMaxTempArray.count == 10, self.weekWeatherSymbolArray.count == 10 {
            cell.weekWeatherMaxTemp.text = "\(self.weekWeatherMaxTempArray[indexPath.row])º"
            cell.weekWeatherMinTemp.text = "\(self.weekWeatherMinTempArray[indexPath.row])º"
            cell.weekWeatherImage.image = UIImage(named: self.weekWeatherSymbolArray[indexPath.row])
            cell.tempProgressView.progress = 0.5 + Float((self.weekWeatherMaxTempArray[indexPath.row] + self.weekWeatherMinTempArray[indexPath.row])) / 100.0
        }
        
        return cell
    }
}
