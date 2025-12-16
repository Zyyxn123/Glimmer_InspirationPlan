import { ComponentsColor, LogOrRegPreference, UserBasicMsgPreference } from "utils"
import { dataType } from "../Model/SettingModel"
import { CPAViewModel } from "../ViewModel/CPAViewModel"
import { SettingViewModel } from "../ViewModel/SettingViewModel"
import { promptAction } from "@kit.ArkUI"

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
  private logOrRegPreference: LogOrRegPreference = LogOrRegPreference.Instance()
  private userBasicMsgPreference: UserBasicMsgPreference = UserBasicMsgPreference.Instance()
  private context: Context = this.getUIContext().getHostContext() as Context

  aboutToAppear(): void {
    this.settingLists = this.settingVM.dataList
  }

  build() {
    NavDestination() {
      Column() {
        /**
         * basic data
         * */
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
                  this.pageInfos.pushPath({ name: item.url })
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
                    .width(150)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis})
                    .textAlign(TextAlign.End)

                  Text('>')
                    .fontSize(20)
                    .margin({ left: 8, right: 10, bottom: 5 })
                }
                .onClick(() => {
                  if (item.title == '账号') {
                    this.getUIContext().getPromptAction().showToast({
                      message: '账号不可修改',
                      duration: 2000,
                      showMode: promptAction.ToastShowMode.DEFAULT,
                      bottom: 80
                    })
                  } else {
                    const params: paramsType = {
                      title: item.title,
                      text: item.text,
                      limit: item.limit
                    }
                    this.pageInfos.pushPath({ name: item.url, param: params })
                  }
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

        /**
         * delete account or log out
         * */
        Column() {
          // Button('获取当前所有账号')
          //   .onClick(() => {
          //     this.logOrRegPreference.getAllAcc()
          //   })
          // Button('清空账号')
          //   .onClick(() => {
          //     this.logOrRegPreference.clearAllAcc()
          //   })
          Button('注销账号')
            .width('80%')
            .height(40)
            .backgroundColor(ComponentsColor.ROUGE_DARK_1ST)
            .margin({
              bottom: 20
            })
            .onClick(() => {
              this.getUIContext().showAlertDialog(
                {
                  title: '账号管理',
                  message: '是否确定要注销账号，这将会失去您的本账号的一切信息。',
                  autoCancel: true,
                  alignment: DialogAlignment.Center,
                  offset: { dx: 0, dy: -20 },
                  gridCount: 3,
                  buttons: [{
                    value: '取消',
                    action: () => {
                    }
                  },
                    {
                      enabled: true,
                      defaultFocus: true,
                      style: DialogButtonStyle.HIGHLIGHT,
                      value: '确定',
                      action: () => {
                        this.getUIContext().getPromptAction().showToast({
                          message: '注销成功',
                          duration: 2000,
                          showMode: promptAction.ToastShowMode.DEFAULT,
                          bottom: 80
                        })
                        let acc: string = AppStorage.get('curAccount')
                        this.logOrRegPreference.deleteAcc(acc)
                        AppStorage.set('curAccount', '')
                        AppStorage.set('TabsBarHeight_changeToCamera', false)
                        AppStorage.set('LoginState', false)

                        this.userBasicMsgPreference.setPh('app.media.avatar_1th')
                        this.userBasicMsgPreference.setUserName('默认用户名')
                        this.userBasicMsgPreference.setSignature('该用户还未设置签名')
                        this.logOrRegPreference.setLoginState(false)
                        this.logOrRegPreference.setCurAcc('')
                      }
                    }],
                }
              )

            })

          Button('退出登录')
            .width('80%')
            .height(40)
            .backgroundColor(ComponentsColor.ROUGE_BRIGHT_1ST)
            .margin({
              bottom: this.getUIContext().px2vp(this.bottomRectHeight + 180),
            })
            .onClick(() => {
              AppStorage.set('curAccount', '')
              AppStorage.set('TabsBarHeight_changeToCamera', false)
              AppStorage.set('LoginState', false)
              this.logOrRegPreference.setLoginState(false)
              this.logOrRegPreference.setCurAcc('')
            })
        }
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