

## 기능 설명 & 동작 화면



여러개의 스톱워치 항목을 생성하여 각각 개별적으로 스톱워치를 작동시킬 수 있는 앱이다. 각 스톱워치는 TableView의 Cell로 구성되어있으며, backgroundColor는 랜덤값을 받는다.





<img src="https://user-images.githubusercontent.com/46234386/133558204-cc7074e7-071a-4f3c-aa01-24288c6afbad.gif" width = "30%"/>









## #1. CRUD 활용



### Data 구조

CoreData를 사용했다. 3개의 Attribute를 생성했는데, 

![image-20210916141632223](/Users/yujun-yong/Library/Application Support/typora-user-images/image-20210916141632223.png)



* **startOrStop** : 현재 스톱워치 항목이 측정중인지 아닌지를 Bool 값을 통해 나타낸다. 굳이 코어데이터에 넣은 이유는, 앱이 종료되었다가 다시 실행되었을때 혹은 백그라운드에서 다시 엑티브 되었을때도 정상적으로 스톱워치가 작동하도록했다. (Boolean, not Optinal)
* **startTime** : `Date()` 객체를 만들어 넣어주었다. 스톱워치를 시작한 시간을 기록하기 위함이고, `startOrStop` 속성과 마찬가지로 앱이 종료되었다가 켜졌을 때도 측정시간에 대한 데이터 손실을 막기 위함이다. (Date, Optional)
  * 스톱워치가 작동하지 않을때는 `Date()` 를 삭제하여 `nil` 이된다.
* **timeTitle** : 각 스톱워치에 대해 사용자가 입력한 제목이다. (String, not Optional)
  * 입력값이 `nil` 이라면 "무제"로 들어가도록 코드를 짰다.



### DataManager.swift

싱글톤 패턴을 사용하여, 앱 전역적으로 `DataManager.shared` 라는 하나의 CoreData객체만 사용하도록 만들었다. 각각의 스톱워치 항목은 `TimeBox()` 와 대응하며, 마찬가지로 앱 전역적으로 하나만 존재하는 `timeBoxList`에 순서대로 담겨 UI를 구성하는데 사용했다.

```swift
import CoreData
import Foundation

class DataManager{
  static let shared = DataManager()
  private init(){
  }

  var mainContext : NSManagedObjectContext{
    return persistentContainer.viewContext
  }
    var timeBoxList = [TimeBox]()
    func isOperate()->Bool{
        let length = self.timeBoxList.count - 1
        for i in 0...length{
            if self.timeBoxList[i].startOrStop{
                return true
            }
        }
        return false
    }
    
    func fetchTimeBox() {
        let request : NSFetchRequest<TimeBox> = TimeBox.fetchRequest()
        let sortByDateDesc = NSSortDescriptor(key : "startTime", ascending : false)
        request.sortDescriptors = [sortByDateDesc]
        do{
            try timeBoxList = mainContext.fetch(request)
        }catch{
            print(error)
        }
      }
    
    func addTimeBox(_ timeTitle: String?){
        let newTimeBox = TimeBox(context : mainContext)
        newTimeBox.timeTitle = timeTitle
        newTimeBox.startTime = nil
        newTimeBox.startOrStop = false
        saveContext()
        fetchTimeBox()
    }
    
    func delTimeBox(_ timeBox: TimeBox?){
        if let timeBox = timeBox{
            mainContext.delete(timeBox)
            saveContext()
            fetchTimeBox()
        }
    }
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "multipleTimer")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
```

### DataManager - Method 설명

* isOperate() : 현재 동작중인 스톱워치가 있는지 Bool값을 반환한다.
  * 동작중인 스톱워치가 있을때, 앱이 inActive되면 Push알람을 보내기 위함
* fetchTimeBox(): CoreData로부터 데이터를 fetch한다. 정렬 순서는 startTime을 기준으로 했다.
* addTimeBox() : 스톱워치의 제목을 전달인자로 받아 새로운 스톱워치 항목을 생성한다. 
* delTimeBox() : 스톱워치 항목을 삭제한다. `trailingSwipeActionsConfigurationForRowAt` 를 사용하여, 셀을 스와이프시 삭제버튼이 나타나도록 구성했다.
* saveContext() : `persistentContainer.viewContext.hasChanges` == true (데이터에 변동이 있을때) 값을 저정하는 메서드이다. 실패시 fatalError를 발생시킨다.







## #2. LifeCycle 활용



### AppDelegate : didFinishLaunchingWithOptions 

앱이 최초에 실행될 때, 사용자에게 Push알람 권한여부를 묻기 위해서 사용했다.

![image-20210916142937128](/Users/yujun-yong/Library/Application Support/typora-user-images/image-20210916142937128.png)



### SceneDelegate: sceneWillResignActive

만약 스톱워치가 동작중인 상태에서 앱이 inActive상태가 되면 아직 동작중인 스톱워치가 있음을 사용자에게 알리기 위해 사용했다.

![image-20210916143021411](/Users/yujun-yong/Library/Application Support/typora-user-images/image-20210916143021411.png)

### SceneDelegate: sceneDidEnterBackground

백그라운드로 돌입할때, 변동된 데이터를 저장하기 위해  `saveContext()` 를 호출한다.





