import { ComponentsColor } from "utils"

interface basicInfosType {
  text: string
  nums: number
}

@Component
export struct BasicData {
  @State basicInfos: basicInfosType[] = [
    { text: '赞赏值', nums: 4325 },// 打卡一个得到2分
    { text: '收藏', nums: 10 },
    { text: '喜欢', nums: 7 },]// 喜欢的每日英语的词语或句子

  build() {
    Column() {
      /**
       * 直观：用户学习经历，使用的基本情况
       * */
      Row({ space: 25 }) {
        ForEach(this.basicInfos, (item: basicInfosType, index: number) => {
          Column({ space: 5 }) {
            Text(item.nums.toString())
              .fontSize(27)
              .fontWeight(900)
              .fontColor(ComponentsColor.AZURITE_DARK_5TH)

            Text(item.text)
              .fontSize(14)
              .fontColor(ComponentsColor.AZURITE_DARK_1ST)
          }
        })
      }

      /**
       * 心情
       * */
      // Text('+ 心情')
      //   .textAlign(TextAlign.Center)
      //   .backgroundColor(ComponentsColor.AZURITE_BRIGHT_5TH)
      //   .fontColor(ComponentsColor.AZURITE_DARK_5TH)
      //   .fontSize(10)
      //   .borderRadius(13)
      //   .height(25)
      //   .width(50)
      //   .margin({ top: 15 })
    }
    .alignItems(HorizontalAlign.Start)
    .margin({ left: 30, top: 50 })
  }
}