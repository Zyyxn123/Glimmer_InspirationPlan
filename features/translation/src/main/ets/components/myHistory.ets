import { ComponentsPictures } from "utils"
import { myHistoryItemType } from "../ViewModel/myHistoryViewModel"
import { JSON } from "@kit.ArkTS"
import { HTTPForEnglishWordToChineseType, translationsType } from "../HTTP/HTTPForEnglishWordToChinese"

@Component
export struct myHistoryItem {
  @State items: myHistoryItemType | undefined = undefined
  @State iPos: string = ''
  @State iTran: string = ''

  aboutToAppear(): void {
    let i = JSON.parse(this.items?.itext) as HTTPForEnglishWordToChineseType
    this.iPos = i.data.translations[0].pos
    this.iTran = i.data.translations[0].tran_cn
  }

  build() {
    Row() {
      Text(this.items?.ititle)
        .fontWeight(500)
        .fontSize(20)
        .margin({ left: 5, right: 10 })
      Text(this.iPos + '. ' + this.iTran)
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Image(!this.items?.iisCollection ? ComponentsPictures.ICON_COLLECTION : ComponentsPictures.ICON_COLLECTION_SELECTED)
        .margin({ right: 10, left: 10 })
        .width(22)
        .onClick(() => {
          this.items!.iisCollection = !this.items!.iisCollection
        })
    }
    .width('100%')
    .height(40)
  }
}