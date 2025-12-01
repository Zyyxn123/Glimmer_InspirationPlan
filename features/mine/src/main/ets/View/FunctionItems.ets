import { ComponentsSize, ComponentsColor, ComponentsPictures } from 'utils'

@Component
export struct FunctionItems {
  @State functionItems: functionItemsType[] = [
    { title: '设置', img: ComponentsPictures.ICON_FUNCTION_SETTING },
    { title: '个人资料', img: ComponentsPictures.ICON_FUNCTION_PERSONALITY },
  ]

  build() {
    Column({ space: 5 }) {
      ForEach(this.functionItems, (item: functionItemsType, index: number) => {
        Row() {
          Row({ space: 10 }) {
            Image(item.img)
              .width(25)
              .fillColor(ComponentsColor.AZURITE_DARK_2ND)
            Text(item.title)
              .fontSize(15)
              .fontColor(ComponentsColor.AZURITE_DARK_1ST)
          }

          Text('>')
            .fontSize(20)
            .fontColor(ComponentsColor.AZURITE_DARK_1ST)
        }
        .width('100%')
        .padding(5)
        .height(50)
        .border({
          width: { bottom: 2 }, color: ComponentsColor.AZURITE_DARK_1ST, radius: {
            topLeft: 10, bottomLeft: 10
          }
        })
        .justifyContent(FlexAlign.SpaceBetween)
        .linearGradient({
          direction: GradientDirection.Right, // 渐变方向
          colors: [[ComponentsColor.AZURITE_BRIGHT_2ND, 0.0], [ComponentsColor.AZURITE_BRIGHT_4TH, 0.3],
            ['#ffffff', 1.0]]
        })
      })
    }
    .width('90%')
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }
}

interface functionItemsType {
  title: string
  img: ResourceStr
}