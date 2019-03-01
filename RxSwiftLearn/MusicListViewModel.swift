//
//  MusicListViewModel.swift
//  RxSwiftLearn
//
//  Created by mac on 2019/1/17.
//  Copyright © 2019 youmy. All rights reserved.
//

import RxSwift

//歌曲列表数据源
struct MusicListViewModel {
    let data = Observable.just([
        Music(name: "无条件", singer: "陈奕迅"),
        Music(name: "你曾是少年", singer: "S.H.E"),
        Music(name: "从前的我", singer: "陈洁仪"),
        Music(name: "在木星", singer: "朴树"),
        ])
}

/*
 这里我们将 data 属性变成一个可观察序列对象（Observable Squence），而对象当中的内容和我们之前在数组当中所包含的内容是完全一样的。
 关于可观察序列对象在后面的文章中我会详细介绍。简单说就是“序列”可以对这些数值进行“订阅（Subscribe）”，有点类似于“通知（NotificationCenter）”
 */


