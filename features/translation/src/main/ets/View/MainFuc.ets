import { ComponentsSize, ComponentsColor, ComponentsPictures } from 'utils'
import { HTTPForRandomPoetry } from '../HTTP/HTTPForRandomPoetry'
import { SpeechToSpeech } from '../HTTP/HTTPForTranslation'

@Component
export struct MainFuc {
  @State WordOrSentence: string = ''


  build() {
    Row() {
      TextInput({ placeholder: '输入要查询的单词或句子', text: $$this.WordOrSentence})
        .fontSize(18)
        .fontWeight(500)
        .fontColor('#000')
        .backgroundColor(Color.Transparent)
        .width('85%')
        .height(65)
        .margin({ left: 10, top: 5 })
        .onClick(() => {
          // HTTPForRandomPoetry.httpRequestForPoetry()
        })

      Row() {
        Image(ComponentsPictures.ICON_SEARCH_FANGFAJING)
          .height(25)
          .width(25)
          .fillColor('#ff808080')
      }
      .height(40)
      .width(50)
      .padding({ left: 10})
      .border({ width: { left: 2}, color: '#ff838383'})
    }
    .border({ width: 2, color: '#ccc' })
    .borderRadius(15)
    .width('90%')
    .backgroundColor(Color.White)
  }
}