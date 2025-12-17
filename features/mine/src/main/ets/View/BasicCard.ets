import { ComponentsSize, ComponentsColor, ComponentsPictures, LogOrRegPreference } from 'utils'
import { hilog } from '@kit.PerformanceAnalysisKit'

@Component
export struct BasicCard {
  private logOrRegPreference: LogOrRegPreference = LogOrRegPreference.Instance()
  @State msg: string = ''
  @State basicCardsMsg: basicCardsMsgType[] =
    [{ title: '签到天数', text: (AppStorage.get('curAccSignInDateCount')! as string).split(' ')[0] },
      { title: '累计学习', text: AppStorage.get('totalStudyNum')! }, // 每日英语打卡总共次数
      { title: '累计查询', text: AppStorage.get('totalSearchNum')! },
      { title: '坚持天数', text: (AppStorage.get('curAccSignInDateCount')! as string).split(' ')[1] },]

  aboutToAppear(): void {
    this.logOrRegPreference.initPre(this.getUIContext().getHostContext() as Context)
    this.msg = this.logOrRegPreference.getCurAccSignInDateCount()
    hilog.info(0x0000, '[publicIndexTagaaaa]', 'isConsecutiveDays this.msg: ' + this.msg)
    hilog.info(0x0000, '[publicIndexTagaaaa]', 'isConsecutiveDays this.msg: ' + this.msg.split(' ')[0])
    hilog.info(0x0000, '[publicIndexTagaaaa]', 'isConsecutiveDays this.msg: ' + this.msg.split(' ')[1])
  }

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
  text: string | number
  title: string
}