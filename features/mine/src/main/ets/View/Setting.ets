import { ComponentsColor } from "utils"
import { dataType } from "../Model/SettingModel"
import { CPAViewModel } from "../ViewModel/CPAViewModel"
import { SettingViewModel } from "../ViewModel/SettingViewModel"

export interface paramsType {
  title: string
  text: string
  limit: string
}

@Component
export struct Setting {
  @Consume('mine_pageStack') pageInfos: NavPathStack
  @State settingLists: dataType[] = []
  @StorageLink('TabsBarHeight_changeToCamera') TabsBarHeight_changeToCameraBol: boolean = false
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  private settingVM: SettingViewModel = SettingViewModel.Instance()


  aboutToAppear(): void {
    this.settingLists = this.settingVM.dataList
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          ForEach(this.settingLists, (item: dataType, index: number) => {
            if (item.img) {
              Row() {
                Text(item.title)
                  .fontSize(18)
                  .fontWeight(600)
                  .margin({ left: 10 })

                Row() {
                  Image($r(CPAViewModel.Instance().selImg))
                    .alt($r('app.media.avatar_1th'))
                    .width(60)
                    .height(60)
                    .borderRadius(30)

                  Text('>')
                    .fontSize(30)
                    .margin({ left: 8, right: 10, bottom: 5 })
                }
                .onClick(() => {
                  this.pageInfos.pushPath({ name: item.url})
                })
              }
              .width('100%')
              .height(100)
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.SpaceBetween)
              .border({ width: { bottom: 1 }, color: Color.Black })
            } else {
              Row() {
                Text(item.title)
                  .fontSize(18)
                  .fontWeight(500)
                  .margin({ left: 10 })

                Row() {
                  Text(item.text)

                  Text('>')
                    .fontSize(20)
                    .margin({ left: 8, right: 10, bottom: 5 })
                }
                .onClick(() => {
                  const params: paramsType = {
                    title: item.title,
                    text: item.text,
                    limit: item.limit
                  }
                  this.pageInfos.pushPath({ name: item.url, param: params})
                })
              }
              .width('100%')
              .height(50)
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.SpaceBetween)
              .border({ width: { bottom: 1 }, color: Color.Black })
            }
          })
        }

        Button('退出登录')
          .width('80%')
          .height(40)
          .backgroundColor(ComponentsColor.ROUGE_BRIGHT_2ND)
          .margin({
            bottom: this.getUIContext().px2vp(this.bottomRectHeight + 180),
          })
          .onClick(() => {
            AppStorage.set('TabsBarHeight_changeToCamera', false)
            AppStorage.set('LoginState', false)
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .title('设置')
    .padding({
      top: this.getUIContext().px2vp(this.topRectHeight),
    })
    .onBackPressed(() => {
      AppStorage.set('TabsBarHeight_changeToCamera', false)
      return false
    })
  }
}