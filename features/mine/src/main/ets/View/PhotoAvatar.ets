import { ComponentsSize, ComponentsColor, ComponentsPictures} from 'utils'


@Component
export struct PhotoAvatar {
  @State isShow_bindSheet: boolean = false
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageLink('PageInfos')pageStack : NavPathStack = new NavPathStack();

  @Builder
  myBindSheetBuilder() {
    Column({ space: 20}) {

      Row() {
        Text('选择头像')
          .fontSize(25)
          .fontColor(ComponentsColor.AZURITE_DARK_6TH)
          .fontWeight(900)

        Button('关闭')
          .borderRadius(10)
          .backgroundColor(ComponentsColor.AZURITE_BRIGHT_7TH)
          .fontColor(ComponentsColor.AZURITE_DARK_2ND)
          .padding(8)
          .onClick(() => {
            this.isShow_bindSheet = false
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')


      Button('从图库选择头像')
        .backgroundColor(ComponentsColor.AZURITE_BRIGHT_5TH)
        .fontColor(ComponentsColor.AZURITE_BRIGHT_1ST)
        .width('80%')
      Button('选择默认头像')
        .width('80%')
        .backgroundColor(ComponentsColor.AZURITE_BRIGHT_5TH)
        .fontColor(ComponentsColor.AZURITE_BRIGHT_1ST)
    }
    .margin({ left: 15, right: 20, top: 20 })
  }

  build() {
    Column({ space: 15}) {
      Text('我的')
        .width(100)
        .fontSize(25)
        .fontWeight(900)
        .fontColor(ComponentsColor.AZURITE_DARK_6TH)

      Image(ComponentsPictures.AVATAR_FIRST)
        .width(100)
        .height(100)
        .borderRadius(50)
        .bindSheet($$this.isShow_bindSheet, this.myBindSheetBuilder, {
          // backgroundColor: ComponentsColor.
          blurStyle: BlurStyle.Thin,
          borderWidth: { top: 2, right: 3, left: 3 },
          borderColor: ComponentsColor.AZURITE_DARK_1ST,
          detents: [250],
          showClose: false,
          onAppear: () => {
            this.isShow_bindSheet = true
          },
          onDisappear: () => {
            this.isShow_bindSheet = false
          }
        })
        .onClick(() => {
          this.isShow_bindSheet = true
        })
    }
    .width(100)
    // .height('25%')
    .margin({ left: 15, top: this.getUIContext().px2vp(this.topRectHeight)})
  }
}