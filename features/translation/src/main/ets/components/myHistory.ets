import { ComponentsPictures } from "utils"
import { myHistoryItemType } from "../ViewModel/myHistoryViewModel"
import { JSON } from "@kit.ArkTS"
import { HTTPForEnglishWordToChineseType, translationsType } from "../HTTP/HTTPForEnglishWordToChinese"

@Component
export struct myHistoryItem {
  @State items: myHistoryItemType = { ilanFrom: 'k', ilanTo: 'k', ititle: '示例', itext: 'example', iisCollection: false}
  @State iPos: string = 'n'
  @State iTran: string = 'example'

  aboutToAppear(): void {
    if (this.items.itext !== 'example') {
      let i = JSON.parse(this.items!.itext) as HTTPForEnglishWordToChineseType
        if (this.items?.ilanTo == 'en') {
          this.iPos = i.data.synonyms[0].pos
          let tmp: string = ''
          for (let j = 0; j < i.data.synonyms[0].Hwds.length; j++) {
            const element = i.data.synonyms[0].Hwds[j].word;
            if (j !== i.data.synonyms[0].Hwds.length - 1) {
              tmp += element + ', '
            } else {
              tmp += element + '.'
            }
          }
          this.iTran = tmp
        } else {
      this.iPos = i.data.translations[0].pos
      this.iTran = i.data.translations[0].tran_cn
        }
    }
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