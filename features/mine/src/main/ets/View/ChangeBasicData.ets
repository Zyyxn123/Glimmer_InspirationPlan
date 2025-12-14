import { paramsType } from "./Setting"
import { JSON } from "@kit.ArkTS"
import { ComponentsColor, ComponentsPictures, LogOrRegPreference, UserBasicMsgPreference } from "utils"
import { SettingViewModel } from "../ViewModel/SettingViewModel"

@Component
export struct ChangeBasicData {
  @Consume('mine_pageStack') pageInfos: NavPathStack
  @State para: paramsType | undefined = { title: 'title', text: 'text', limit: 'limit' }
  @State modMsg: string = ''
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  private userBasicMsgPreference: UserBasicMsgPreference = UserBasicMsgPreference.Instance()
  private settingViewModel: SettingViewModel = SettingViewModel.Instance()
  private logOrRegPreference: LogOrRegPreference = LogOrRegPreference.Instance()

  private selFucToStore() {
    if (this.para!.title == '用户名') {
      this.userBasicMsgPreference.setUserName(this.modMsg)
      this.settingViewModel.setUserName()
    } else if (this.para!.title == '个性签名') {
      this.userBasicMsgPreference.setSignature(this.modMsg)
      this.settingViewModel.setSignature()
    } else if (this.para!.text == '密码') {
      this.logOrRegPreference.registerAcc(AppStorage.get('curAccount')!, this.modMsg)
      this.settingViewModel.setPsw()
    }
  }

  build() {
    NavDestination() {
      Column({ space: 10}) {
        Row() {
          TextInput({ placeholder: this.para!.text, text: $$this.modMsg})
            .height(40)
            .width('85%')
            .border({ width: 1, radius: 15, color: Color.Black})
            .placeholderColor('#ccc')

          Image(ComponentsPictures.ICON_TRANSLATION_DELETE)
            .width(35)
            .height(35)
            .margin({ left: 15, right: 15 })
            .onClick(() => {
              this.modMsg = ''
            })
            .borderRadius(17)
            .fillColor('#ff6e6e6e')
            .backgroundColor('#ffe0e0e0')
            .padding(5)
        }

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
              this.selFucToStore()
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
      this.modMsg = this.para!.text
    })
    .onBackPressed(() => {
      this.modMsg = ''
      this.para = { title: 'title', text: 'text', limit: 'limit' }
      return false
    })
  }
}