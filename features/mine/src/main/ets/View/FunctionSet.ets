import { ComponentsSize, ComponentsColor, ComponentsPictures } from 'utils'

@Component
export struct FunctionSet {
  @Consume('mine_pageStack') pageInfos: NavPathStack
  @State functionSets: functionSetsType[] = [
    { title: '我的收藏', img: ComponentsPictures.ICON_FUNCTION_COLLECTION, url: 'myCollection' },
    { title: '每日英语', img: ComponentsPictures.ICON_FUNCTION_STUDY, margin: 12, url: 'dailyEnglish' }, //对应赞赏值
    // { title: '学习经历', img: ComponentsPictures.ICON_FUNCTION_MEDAL, url: '' },
  ]

  build() {
    Row() {
      ForEach(this.functionSets, (item: functionSetsType, index: number) => {
        Column({ space: 15 }) {
          Image(item.img)
            .width(50)
            .margin(item.margin ? item.margin : 0)

          Text(item.title)
            .fontSize(15)
            .fontColor(ComponentsColor.AZURITE_DARK_1ST)
        }
        .layoutWeight(1)
        .height(150)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          AppStorage.set('TabsBarHeight_changeToCamera', true)
          this.pageInfos.pushPath({ name: item.url})
        })
      })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .width('90%')
    .height(150)
    .borderRadius(20)
    .padding({ left: 10, right: 10 })
    .margin({ top: 5 })
    .border({ width: 1, color: ComponentsColor.AZURITE_BRIGHT_6TH })
    .radialGradient({
      center: ['50%', '50%'],
      radius: 180,
      colors: [['#fffff', 0.0], ['#ffffff', 0.8], [ComponentsColor.AZURITE_BRIGHT_6TH, 1.0]]
    })
  }
}

interface functionSetsType {
  title: string
  img: ResourceStr
  margin?: number
  url: string
}