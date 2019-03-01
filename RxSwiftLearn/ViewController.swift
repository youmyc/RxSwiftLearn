//
//  ViewController.swift
//  RxSwiftLearn
//
//  Created by mac on 2019/1/17.
//  Copyright © 2019 youmy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    //tableView对象
    @IBOutlet weak var tableView: UITableView!
    
    // 歌曲列表数据源
    let musicListViewModel = MusicListViewModel()
    
    //负责对象销毁
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         DisposeBag：作用是 Rx 在视图控制器或者其持有者将要销毁的时候，自动释法掉绑定在它上面的资源。它是通过类似“订阅处置机制”方式实现（类似于 NotificationCenter 的 removeObserver）。
         rx.items(cellIdentifier:）:这是 Rx 基于 cellForRowAt 数据源方法的一个封装。传统方式中我们还要有个 numberOfRowsInSection 方法，使用 Rx 后就不再需要了（Rx 已经帮我们完成了相关工作）。
         rx.modelSelected： 这是 Rx 基于 UITableView 委托回调方法 didSelectRowAt 的一个封装。
         */
        
        //将数据源数据绑定到tableView上
        musicListViewModel.data
            .bind(to: tableView.rx.items(cellIdentifier: "musicCell")){_, music, cell in
                cell.textLabel?.text = music.name
                cell.detailTextLabel?.text = music.singer
        }.disposed(by: disposeBag)
        
        //tableView点击响应
        tableView.rx.modelSelected(Music.self).subscribe(onNext: { (music) in
            print("你选中的歌曲信息【\(music)】")
        }).disposed(by: disposeBag)
        
        
        let label = UILabel(frame: CGRect(x: 100, y: 200, width: 200, height: 20))
        label.text = "RxSwift"
        view.addSubview(label)
        
//        let observer: AnyObserver<String> = AnyObserver { (event) in
//            switch event {
//            case .next(let text):
//                label.text = text
//            default:break
//            }
//        }
        
//        let observer: Binder<String> = Binder(label) { (view, text) in
//            view.text = text
//        }
        
//        let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
//
//        observable.map { CGFloat($0)}
//            .bind(to: label.rx.fontSize)
//            .disposed(by: disposeBag)
        
        variable()
    }
    
    /*
     （1）Subjects 既是订阅者，也是 Observable：
        - 说它是订阅者，是因为它能够动态地接收新的值。
        - 说它又是一个 Observable，是因为当 Subjects 有了新的值之后，就会通过 Event 将新值发出给他的所有订阅者。
     
     （2）一共有四种 Subjects，分别为：PublishSubject、BehaviorSubject、ReplaySubject、Variable。他们之间既有各自的特点，也有相同之处：
         - 首先他们都是 Observable，他们的订阅者都能收到他们发出的新的 Event。
         - 直到 Subject 发出 .complete 或者 .error 的 Event 后，该 Subject 便终结了，同时它也就不会再发出 .next 事件。
         - 对于那些在 Subject 终结后再订阅他的订阅者，也能收到 subject 发出的一条 .complete 或 .error 的 event，告诉这个新的订阅者它已经终结了。
         - 他们之间最大的区别只是在于：当一个新的订阅者刚订阅它的时候，能不能收到 Subject 以前发出过的旧 Event，如果能的话又能收到多少个。
     
     （3）Subject 常用的几个方法：
         - onNext(:)：是 on(.next(:)) 的简便写法。该方法相当于 subject 接收到一个 .next 事件。
         - onError(:)：是 on(.error(:)) 的简便写法。该方法相当于 subject 接收到一个 .error 事件。
         - onCompleted()：是 on(.completed) 的简便写法。该方法相当于 subject 接收到一个 .completed 事件。
     */
    
    func publishSubject(){
        /*
         PublishSubject 是最普通的 Subject，它不需要初始值就能创建。
         PublishSubject 的订阅者从他们开始订阅的时间点起，可以收到订阅后 Subject 发出的新 Event，而不会收到他们在订阅前已发出的 Event。
         */
        
        //创建一个PublishSubject
        let subject = PublishSubject<String>()
        
        //由于当前没有任何订阅者，所以这条信息不会输出到控制台
        subject.onNext("111")
        
        //第1次订阅subject
        subject.subscribe(onNext: { string in
            print("第1次订阅：", string)
        }, onCompleted:{
            print("第1次订阅：onCompleted")
        }).disposed(by: disposeBag)
        
        //当前有1个订阅，则该信息会输出到控制台
        subject.onNext("222")
        
        //第2次订阅subject
        subject.subscribe(onNext: { string in
            print("第2次订阅：", string)
        }, onCompleted:{
            print("第2次订阅：onCompleted")
        }).disposed(by: disposeBag)
        
        //当前有2个订阅，则该信息会输出到控制台
        subject.onNext("333")
        
        //让subject结束
        subject.onCompleted()
        
        //subject完成后会发出.next事件了。
        subject.onNext("444")
        
        //subject完成后它的所有订阅（包括结束后的订阅），都能收到subject的.completed事件，
        subject.subscribe(onNext: { string in
            print("第3次订阅：", string)
        }, onCompleted:{
            print("第3次订阅：onCompleted")
        }).disposed(by: disposeBag)
    }
    
    func behaviorSubject(){
        /*
         BehaviorSubject 需要通过一个默认初始值来创建。
         当一个订阅者来订阅它的时候，这个订阅者会立即收到 BehaviorSubjects 上一个发出的 event。之后就跟正常的情况一样，它也会接收到 BehaviorSubject 之后发出的新的 event。
         */
        
        //创建一个BehaviorSubject
        let subject = BehaviorSubject(value: "111")
        
        //第1次订阅subject
        subject.subscribe { event in
            print("第1次订阅：", event)
            }.disposed(by: disposeBag)
        
        //发送next事件
        subject.onNext("222")
        
        //发送error事件
        subject.onError(NSError(domain: "local", code: 0, userInfo: nil))
        
        //第2次订阅subject
        subject.subscribe { event in
            print("第2次订阅：", event)
            }.disposed(by: disposeBag)
    }
    
    func replaySubject(){
        /*
         ReplaySubject 在创建时候需要设置一个 bufferSize，表示它对于它发送过的 event 的缓存个数。
         比如一个 ReplaySubject 的 bufferSize 设置为 2，它发出了 3 个 .next 的 event，那么它会将后两个（最近的两个）event 给缓存起来。此时如果有一个 subscriber 订阅了这个 ReplaySubject，那么这个 subscriber 就会立即收到前面缓存的两个 .next 的 event。
         如果一个 subscriber 订阅已经结束的 ReplaySubject，除了会收到缓存的 .next 的 event 外，还会收到那个终结的 .error 或者 .complete 的 event。
         */
        
        //创建一个bufferSize为2的ReplaySubject
        let subject = ReplaySubject<String>.create(bufferSize: 2)
        
        //连续发送3个next事件
        subject.onNext("111")
        subject.onNext("222")
        subject.onNext("333")
        
        //第1次订阅subject
        subject.subscribe { event in
            print("第1次订阅：", event)
            }.disposed(by: disposeBag)
        
        //再发送1个next事件
        subject.onNext("444")
        
        //第2次订阅subject
        subject.subscribe { event in
            print("第2次订阅：", event)
            }.disposed(by: disposeBag)
        
        //让subject结束
        subject.onCompleted()
        
        //第3次订阅subject
        subject.subscribe { event in
            print("第3次订阅：", event)
            }.disposed(by: disposeBag)
    }
    
    func variable(){
        /*
         Variable 其实就是对 BehaviorSubject 的封装，所以它也必须要通过一个默认的初始值进行创建。
         Variable 具有 BehaviorSubject 的功能，能够向它的订阅者发出上一个 event 以及之后新创建的 event。
         不同的是，Variable 还把会把当前发出的值保存为自己的状态。同时它会在销毁时自动发送 .complete 的 event，不需要也不能手动给 Variables 发送 completed 或者 error 事件来结束它。
         简单地说就是 Variable 有一个 value 属性，我们改变这个 value 属性的值就相当于调用一般 Subjects 的 onNext() 方法，而这个最新的 onNext() 的值就被保存在 value 属性里了，直到我们再次修改它。
         */
        
        /*
         注意：
         Variables 本身没有 subscribe() 方法，但是所有 Subjects 都有一个 asObservable() 方法。我们可以使用这个方法返回这个 Variable 的 Observable 类型，拿到这个 Observable 类型我们就能订阅它了。
         */
        
        //创建一个初始值为111的Variable
        let variable = Variable("111")
        
        //修改value值
        variable.value = "222"
        
        //第1次订阅
        variable.asObservable().subscribe {
        print("第1次订阅：", $0)
        }.disposed(by: disposeBag)
        
        //修改value值
        variable.value = "333"
        
        //第2次订阅
        variable.asObservable().subscribe {
        print("第2次订阅：", $0)
        }.disposed(by: disposeBag)
        
        //修改value值
        variable.value = "444"
    }
    
    func behaviorRelay(){
        
        /*
         BehaviorRelay 是作为 Variable 的替代者出现的。它的本质其实也是对 BehaviorSubject 的封装，所以它也必须要通过一个默认的初始值进行创建。
         BehaviorRelay 具有 BehaviorSubject 的功能，能够向它的订阅者发出上一个 event 以及之后新创建的 event。
         与 BehaviorSubject 不同的是，不需要也不能手动给 BehaviorReply 发送 completed 或者 error 事件来结束它（BehaviorRelay 会在销毁时也不会自动发送 .complete 的 event）。
         BehaviorRelay 有一个 value 属性，我们通过这个属性可以获取最新值。而通过它的 accept() 方法可以对值进行修改。
         */
        
        let subject = BehaviorRelay<String>.init(value: "111")
        
        //修改value值
        subject.accept("222")
        
        //第1次订阅
        subject.asObservable().subscribe {
            print("第1次订阅：", $0)
            }.disposed(by: disposeBag)
        
        //修改value值
        subject.accept("333")
        
        //第2次订阅
        subject.asObservable().subscribe {
            print("第2次订阅：", $0)
            }.disposed(by: disposeBag)
        
        //修改value值
        subject.accept("444")
    }
}

extension Reactive where Base:UILabel {
    public var fontSize: Binder<CGFloat> {
        return Binder(self.base, binding: { (label, fontSize) in
            label.font = UIFont.systemFont(ofSize: fontSize)
        })
    }
}
