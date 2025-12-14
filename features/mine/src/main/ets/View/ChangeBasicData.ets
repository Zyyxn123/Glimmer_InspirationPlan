import { paramsType } from "./Setting"
import { JSON } from "@kit.ArkTS"
import { ComponentsColor, UserBasicMsgPreference } from "utils"

@Component
export struct ChangeBasicData {
  @Consume('mine_pageStack') pageInfos: NavPathStack
  @State para: paramsType | undefined = { title: 'title', text: 'text', limit: 'limit' }
  @State modMsg: string = ''
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  private userBasicMsgPreference: UserBasicMsgPreference = UserBasicMsgPreference.Instance()

  build() {
    NavDestination() {
      Column({ space: 10}) {
        TextInput({ placeholder: this.para!.text, text: $$this.modMsg })
          .height(40)
          .width('90%')
          .border({ width: 1, radius: 15, color: Color.Black})
          .placeholderColor('#ccc')

        Text(this.para!.limit)
          .fontSize(14)
          .fontColor('#ff8d8d8d')
          .margin({ left: 8 })

        Button('确定修改')
          .backgroundColor(ComponentsColor.AZURITE_BRIGHT_2ND)
          .width('80%')
          .height(40)
          .onClick(() => {
            if (this.modMsg) {
              this.modMsg = ''
              this.para = { title: 'title', text: 'text', limit: 'limit' }
              this.pageInfos.pop()
            } else {
              this.pageInfos.pop()
            }
          })
          .margin({ left: 30, top: 60 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 15, right: 15, top: 10 })
    }
    .title('修改' + this.para!.title)
    .padding({
      top: this.getUIContext().px2vp(this.topRectHeight),
    })
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
      this.para = context.pathInfo.param as paramsType
    })
    .onBackPressed(() => {
      this.modMsg = ''
      this.para = { title: 'title', text: 'text', limit: 'limit' }
      return false
    })
  }
}