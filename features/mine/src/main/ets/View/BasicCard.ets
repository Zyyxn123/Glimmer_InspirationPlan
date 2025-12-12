import { ComponentsSize, ComponentsColor, ComponentsPictures } from 'utils'

@Component
export struct BasicCard {
  @State basicCardsMsg: basicCardsMsgType[] =
    [{ title: '签到天数', text: 2 },
      { title: '累计学习', text: 1 }, // 每日英语打卡总共次数
      { title: '累计查询', text: 0 },
      { title: '坚持天数', text: 2 },]

  build() {
    Row() {
      ForEach(this.basicCardsMsg, (item: basicCardsMsgType, index: number) => {
        Column({ space: 5 }) {
          Text(item.text.toString())
            .fontColor(ComponentsColor.AZURITE_BRIGHT_6TH)
            .fontSize(20)
            .fontWeight(800)
          Text(item.title)
            .fontColor(ComponentsColor.AZURITE_BRIGHT_4TH)
            .fontSize(15)
        }
        .padding({ right: 10 })
        .border(index == 3 ? {} : { width: { right: 1 }, color: ComponentsColor.AZURITE_DARK_7TH })
      })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .width('90%')
    .height(100)
    .backgroundColor(ComponentsColor.AZURITE_DARK_2ND)
    // .backgroundColor(Color.White)
    .borderRadius(20)
    .padding({ left: 20, right: 10 })
    .margin({ top: 15 })
  }
}

interface basicCardsMsgType {
  text: number
  title: string
}