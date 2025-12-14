// import { SpeechToSpeech } from "../HTTP/HTTPForTranslation";
import { hilog } from "@kit.PerformanceAnalysisKit";
import { MainFuc } from "../View/MainFuc";
import { ComponentsSize, ComponentsColor, ComponentsPictures, UserMsgRDBStore } from 'utils'
import { ChangeLanguage } from "../View/ChangeLanguage";
import classifyViewModel from "../ViewModel/ClassifyListViewModel";
import ClassifyAlphaListModel from "../Model/ClassifyAlphaListModel";
import { JSON } from "@kit.ArkTS";
import { PlayerForPronunciation } from "../AVplayer/PlayerForPronunciation";
import { myHistoryItem } from "../components/myHistory";
import { myHistoryItemType, myHistoryViewModel } from "../ViewModel/myHistoryViewModel";
import { common } from "@kit.AbilityKit";

@Component
export struct Translation {
  @State lanFrom: string = 'ch-Hans'
  @State lanTo: string = 'en'
  private myHistoryVM: myHistoryViewModel = myHistoryViewModel.Instance()
  private userMsgRDBStore: UserMsgRDBStore = UserMsgRDBStore.Instance()
  private context: common.Context = this.getUIContext().getHostContext() as common.Context

  aboutToAppear(): void {
    // this.userMsgRDBStore.getInit(this.context)
    this.myHistoryVM.getAllHistoryMsg()
    // PlayerForPronunciation.Instance().getInit()
  }


  build() {
    Column({ space: 10 }) {
      ChangeLanguage({ lanFrom: this.lanFrom, lanTo: this.lanTo})

      MainFuc({ lanFrom: this.lanFrom, lanTo: this.lanTo})

      Text('历史记录')
        .width('100%')
        .fontSize(15)
        .fontColor('#ff999999')
        .textAlign(TextAlign.Center)

      Column() {
        // 历史记录
        List({ space: 5 }) {
          ForEach(this.myHistoryVM.itemLists.slice(0, 25), (item: myHistoryItemType, index: number) => {
            ListItem() {
              Row() {
                myHistoryItem({ items: item })
              }
              .width('90%')
              .height(40)
              // .backgroundColor(Color.Pink)
            }
            .border({ width: { bottom: 1}, color: '#000'})
          })
        }
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .padding({ top: 10})
        .width('100%')
        .alignListItem(ListItemAlign.Center)
        .backgroundColor(Color.White)
        .border({ width: 1, radius: { topLeft: 15, topRight: 15 }, color: Color.White })
      }
      .height('100%')
      .width('100%')
      .backgroundColor(Color.White)
      .border({ width: 1, radius: { topLeft: 15, topRight: 15 }, color: Color.White })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(ComponentsColor.AZURITE_BRIGHT_7TH)
    .linearGradient({
      direction: GradientDirection.Right,
      colors: [
        [ComponentsColor.AZURITE_BRIGHT_7TH, 0],
        [ComponentsColor.ROUGE_BRIGHT_7TH, 1]]
    })
  }
}