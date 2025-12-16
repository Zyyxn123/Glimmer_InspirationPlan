import { ComponentsPictures } from "utils"
import { myHistoryItemType, myHistoryViewModel } from "../ViewModel/myHistoryViewModel"
import { JSON } from "@kit.ArkTS"
import { HTTPForEnglishWordToChineseType, translationsType } from "../HTTP/HTTPForEnglishWordToChinese"

@Component
export struct myHistoryItem {
  @State items: myHistoryItemType = {
    ilanFrom: 'k',
    ilanTo: 'k',
    ititle: 'title',
    itext: '"code":200,"msg":"数据请求成功","data":{"bookId":"BEC_2","phrases":[{"p_cn":"例如","p_content":"for example"},{"p_cn":"例如；作为一个例子","p_content":"as an example"},{"p_cn":"例证；…的例子；…的榜样","p_content":"example of"},{"p_cn":"树立榜样","p_content":"set an example"},{"p_cn":"数值例；数例","p_content":"numerical example"},{"p_cn":"举例","p_content":"give an example"},{"p_cn":"为某人树立榜样","p_content":"set an example for"},{"p_cn":"代码示例","p_content":"example code"},{"p_cn":"以…为榜样；以…借鉴","p_content":"take example by"},{"p_cn":"以…为例","p_content":"take for example"},{"p_cn":"反例","p_content":"counter example"},{"p_cn":"举例；引用一个例子","p_content":"cite an example"},{"p_cn":"没有先例","p_content":"without example"},{"p_cn":"没有先例，空前","p_content":"beyond example"},{"p_cn":"惩罚...以警戒他人","p_content":"make an example of"},{"p_cn":"案例","p_content":"example of case"}],"relWords":[],"sentences":[{"s_cn":"父母应该为孩子树立榜样。","s_content":"Parents should set an example for their children."}],"synonyms":[{"Hwds":[{"word":"mirror"},{"word":"lead"},{"word":"sample"}],"pos":"n","tran":"例子；榜样"},{"Hwds":[{"word":"illustrate"}],"pos":"vi","tran":"举例"}],"translations":[{"pos":"n","tran_cn":"例子；榜样"},{"pos":"vt","tran_cn":"作为…的例子；为…做出榜样"},{"pos":"vi","tran_cn":"举例"}],"ukphone":"ɪg\'zɑːmp(ə)l; eg-","ukspeech":"https://dict.youdao.com/dictvoice?audio=example&type=1","usphone":"ɪg\'zæmpl","usspeech":"https://dict.youdao.com/dictvoice?audio=example&type=2","word":"example"},"request_id":"0707878eb4b96a340610c567"',
    iisCollection: false
  }
  @State iPos: string = 'n'
  @State iTran: string = 'example'
  private myHistoryVM: myHistoryViewModel = myHistoryViewModel.Instance()

  aboutToAppear(): void {
    if (this.items.itext !== 'example' && this.items.itext) {
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
      Image(!(this.items?.iisCollection) ? ComponentsPictures.ICON_COLLECTION :
        ComponentsPictures.ICON_COLLECTION_SELECTED)
        .margin({ right: 10, left: 10 })
        .width(22)
        .onClick(() => {
          if (this.items.ilanFrom !== 'k') {
            // let tmp = this.items
            // tmp.iisCollection = !bool
            // console.log('传输过去的值: ' + JSON.stringify(this.items))
            // console.log('传输过去的值: ' + JSON.stringify(tmp.iisCollection))
            // console.log('传输过去的值: ' + JSON.stringify(bool))
            this.myHistoryVM.upDateCollectionState(this.items)
          }
          let bool: boolean = !(this.items!.iisCollection)
          // console.log('传输的值: ' + JSON.stringify(bool))
          this.items!.iisCollection = bool
          // console.log('传输的值: ' + JSON.stringify(this.items!.iisCollection))

        })
    }
    .width('100%')
    .height(40)
  }
}

// "code":200,"msg":"数据请求成功","data":{"bookId":"BEC_2","phrases":[{"p_cn":"例如","p_content":"for example"},{"p_cn":"例如；作为一个例子","p_content":"as an example"},{"p_cn":"例证；…的例子；…的榜样","p_content":"example of"},{"p_cn":"树立榜样","p_content":"set an example"},{"p_cn":"数值例；数例","p_content":"numerical example"},{"p_cn":"举例","p_content":"give an example"},{"p_cn":"为某人树立榜样","p_content":"set an example for"},{"p_cn":"代码示例","p_content":"example code"},{"p_cn":"以…为榜样；以…借鉴","p_content":"take example by"},{"p_cn":"以…为例","p_content":"take for example"},{"p_cn":"反例","p_content":"counter example"},{"p_cn":"举例；引用一个例子","p_content":"cite an example"},{"p_cn":"没有先例","p_content":"without example"},{"p_cn":"没有先例，空前","p_content":"beyond example"},{"p_cn":"惩罚...以警戒他人","p_content":"make an example of"},{"p_cn":"案例","p_content":"example of case"}],"relWords":[],"sentences":[{"s_cn":"父母应该为孩子树立榜样。","s_content":"Parents should set an example for their children."}],"synonyms":[{"Hwds":[{"word":"mirror"},{"word":"lead"},{"word":"sample"}],"pos":"n","tran":"例子；榜样"},{"Hwds":[{"word":"illustrate"}],"pos":"vi","tran":"举例"}],"translations":[{"pos":"n","tran_cn":"例子；榜样"},{"pos":"vt","tran_cn":"作为…的例子；为…做出榜样"},{"pos":"vi","tran_cn":"举例"}],"ukphone":"ɪg'zɑːmp(ə)l; eg-","ukspeech":"https://dict.youdao.com/dictvoice?audio=example&type=1","usphone":"ɪg'zæmpl","usspeech":"https://dict.youdao.com/dictvoice?audio=example&type=2","word":"example"},"request_id":"0707878eb4b96a340610c567"