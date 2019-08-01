//
//  BasePaginationCollectionViewController.swift
//  MVVM2019June20
//
//  Created by Yee Chuan Lee on 01/07/2019.
//  Copyright © 2019 Yee Chuan Lee. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SwifterSwift

class BasePaginationCollectionViewController<VM, Res, IM, SM, FM>: BaseViewController<VM>, BasePaginationViewType where VM: BasePaginationViewModel<Res, IM, SM, FM>, SM: SectionModelType, SM.Item == IM {
    //MARK: Outlets
    @IBOutlet weak var listView: UICollectionView!
    
    //State
    var dataSource: RxCollectionViewSectionedReloadDataSource<SM>!
    
    //MARK: View Cycle
    override func loadView() {
        super.loadView()
        viewModel ??= VM()
        viewModel.disposed(by: disposeBag)
    }
    override func dispose() {
        super.dispose()
        dataSource = nil
    }
    //MARK: setupView
    override func setupView() {
        super.setupView()
        setupListView()
    }
    
    func removePullToReload() {
        listView.es.removeRefreshHeader()
    }
    
    func removePullToLoadMore() {
        listView.es.removeRefreshFooter()
    }
    
    func setupListView() {
        dataSource = RxCollectionViewSectionedReloadDataSource<SM>(configureCell: self.configureCell)
    }
    
    //MARK: setupTransformInput
    override func setupTransformInput() {
        super.setupTransformInput()
        viewModel.view = self
        viewModel.startReload = self.rx.reload
        viewModel.startLoadMore = self.rx.loadMore
    }
    
    //MARK: subscribe
    override func subscribe() {
        super.subscribe()
        subscribePullToRefresh(didReload: viewModel.didReload, collectionView: self.listView)
        subscribeLoadMore(didLoadMore: viewModel.didLoadMore, collectionView: self.listView)
        subscribeListView(sections: viewModel.sections)
    }
    
    func subscribeListView(sections: Driver<[SM]>) {
        sections
            .asObservable()
            .bind(to: self.listView.rx.items(dataSource: self.dataSource))
            .disposed(by: disposeBag)
    }
    
    func configureCell(ds: CollectionViewSectionedDataSource<SM>, tv: UICollectionView, ip: IndexPath, item: IM) -> UICollectionViewCell {
        
        return UICollectionViewCell()
    }
}
