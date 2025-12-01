import { ComponentsSize, ComponentsColor, ComponentsPictures} from 'utils'

@Component
export struct FunctionSet {
  @State functionSets: functionSetsType[] = [
    {title: '我的收藏', img: ComponentsPictures.ICON_FUNCTION_COLLECTION},
    {title: '学习详情', img: ComponentsPictures.ICON_FUNCTION_STUDY, margin: 12},
    {title: '勋章墙', img: ComponentsPictures.ICON_FUNCTION_MEDAL},
  ]

  build() {
    Row() {
      ForEach(this.functionSets, (item: functionSetsType, index: number) => {
        Column({ space: 15}) {
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
      })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .width('90%')
    .height(150)
    .borderRadius(20)
    .padding({ left: 10, right: 10})
    .margin({ top: 5 })
    .border({ width: 1, color: ComponentsColor.AZURITE_BRIGHT_6TH})
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
}