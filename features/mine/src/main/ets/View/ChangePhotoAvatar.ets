import { CPAViewModel } from "../ViewModel/CPAViewModel"

@Component
export struct ChangePhotoAvatar {
  @Consume('mine_pageStack') pageInfos: NavPathStack
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @State curSel: number = -10
  @State curSelPh: string = ''
  private cpaVM: CPAViewModel = CPAViewModel.Instance()
  @State PhAvatar: string[] = this.cpaVM.pa


  build() {
    NavDestination() {
      Column() {
        Grid() {
          ForEach(this.PhAvatar, (item: string, index: number) => {
            GridItem() {
              Image($r(item))
                .width(100)
                .height(100)
                .borderRadius(50)
                .margin(5)
                .border(item.toString().substring(17, 18) == (this.curSel + 1).toString() ? { width: 2, color: Color.Blue} : { width: 0 })
                .onClick(() => {
                  this.curSel = index
                  this.curSelPh = item
                })
            }
          })
        }
        .width('100%')
        .height(400)
        .padding({ left: 20 })
        // .columnsTemplate('1r 1r 1r')
        // .rowsTemplate('1r 1r 1r')
        // .columnsGap(10)
        // .rowsGap(10)

        Button('确定')
          .width('60%')
          .height('8%')
          .onClick(() => {
            this.curSel = -10
            this.cpaVM.selImg = this.curSelPh
            this.curSelPh = ''
            this.pageInfos.pop()
          })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      // .justifyContent(FlexAlign.Center)
    }
    .title('选择头像')
    .padding({
      top: this.getUIContext().px2vp(this.topRectHeight),
    })
    .onBackPressed(() => {
      this.curSel = -10
      this.curSelPh = ''
      return false
    })
  }
}