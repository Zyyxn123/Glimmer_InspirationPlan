import { ComponentsSize, ComponentsColor, ComponentsPictures } from 'utils'
import { HTTPForEnglishWordToChinese, HTTPForEnglishWordToChineseType } from '../HTTP/HTTPForEnglishWordToChinese'
import { HTTPForRandomPoetry } from '../HTTP/HTTPForRandomPoetry'

// import { SpeechToSpeech } from '../HTTP/HTTPForTranslation'

@Component
export struct MainFuc {
  @State WordOrSentence: string = ''
  @Prop lanFrom: string
  @Prop lanTo: string
  @State isShownTranslation: boolean = false
  @State msg: HTTPForEnglishWordToChineseType | undefined = undefined

  @Builder
  TranslationDialog() {
    if (this.msg) {
      Column() {
      }
      .width('100%')
      .height('100%')
      .backgroundColor(ComponentsColor.AZURITE_BRIGHT_7TH)
    } else {
      Column() {
        Text('查询出错')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(ComponentsColor.AZURITE_BRIGHT_7TH)
    }
  }

  build() {
    Row() {
      TextInput({ placeholder: '输入要查询的单词或句子', text: $$this.WordOrSentence })
        .fontSize(18)
        .fontWeight(500)
        .fontColor('#000')
        .backgroundColor(Color.Transparent)
        .width('85%')
        .height(65)
        .margin({ left: 10, top: 5 })

      Row() {
        Image(ComponentsPictures.ICON_SEARCH_FANGFAJING)
          .height(25)
          .width(25)
          .fillColor('#ff808080')
          .onClick(() => {
            if (this.lanFrom == 'en' && this.WordOrSentence.split(' ').length == 1) {
              HTTPForEnglishWordToChinese.HTTPForEnglishWordToChinese(this.WordOrSentence)
              this.msg = HTTPForEnglishWordToChinese.myData
              this.isShownTranslation = true
            }
            // else {
            //   this.getUIContext().showAlertDialog({
            //     message: '无输入或输入不合理'
            //   })
            // }
          })
          .bindSheet($$this.isShownTranslation, this.TranslationDialog, {
            height: SheetSize.MEDIUM,
            blurStyle: BlurStyle.Thin,
            borderWidth: { top: 2, right: 3, left: 3 },
            borderColor: ComponentsColor.AZURITE_DARK_1ST,
            // showClose: false,
            title: { title: '翻译内容' },
            onAppear: () => {
              this.isShownTranslation = true
            },
            onDisappear: () => {
              this.isShownTranslation = false
            }
          })
      }
      .height(40)
      .width(50)
      .padding({ left: 10 })
      .border({ width: { left: 2 }, color: '#ff838383' })
    }
    .border({ width: 2, color: '#ccc' })
    .borderRadius(15)
    .width('90%')
    .backgroundColor(Color.White)
  }
}