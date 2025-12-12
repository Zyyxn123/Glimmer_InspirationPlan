@Component
export struct MyCollection {
  @Consume('mine_pageStack') pageInfos: NavPathStack
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  build() {
    NavDestination() {}
    .title('我的收藏')
    .padding({
      top: this.getUIContext().px2vp(this.topRectHeight),
    })
  }
}