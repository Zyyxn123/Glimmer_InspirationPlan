import { MyCollectionItem } from "../components/MyCollectionItem";
import { BasicDataViewModel, myBasicDataItemType } from "../ViewModel/BasicDataViewModel";

@Component
export struct MyCollection {
  @Consume('mine_pageStack') pageInfos: NavPathStack
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  private basicDataVM: BasicDataViewModel = BasicDataViewModel.Instance()


  build() {
    NavDestination() {
      Column() {
        List({ space: 5 }) {
          ForEach(this.basicDataVM.itemLists, (item: myBasicDataItemType, index: number) => {
            ListItem() {
              MyCollectionItem({ items: item })
            }
            .width('100%')
            .padding({ top: 5, bottom: 5})
            .border({ width: {bottom: 1}, color: Color.Black, radius: 5 })
          })
        }
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .width('90%')
      }
      .width('100%')
    }
    .title('我的收藏')
    .padding({
      top: this.getUIContext().px2vp(this.topRectHeight),
    })
    .onBackPressed(() => {
      AppStorage.set('TabsBarHeight_changeToCamera', false)
      return false
    })
  }
}