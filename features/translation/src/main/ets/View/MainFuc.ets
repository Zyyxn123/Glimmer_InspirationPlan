import { ComponentsSize, ComponentsColor, ComponentsPictures } from 'utils'
import {
  HTTPForEnglishWordToChinese,
  HTTPForEnglishWordToChineseType,
  HwdsType,
  HwdsTypeAnother,
  phrasesType,
  relWordsType,
  sentencesType,
  synonymsType,
  translationsType
} from '../HTTP/HTTPForEnglishWordToChinese'
import { HTTPForRandomPoetry } from '../HTTP/HTTPForRandomPoetry'
import { HTTPForZhToEn } from '../HTTP/HTTPForZhToEn'
import hilog from '@ohos.hilog'

// import { SpeechToSpeech } from '../HTTP/HTTPForTranslation'

@Component
export struct MainFuc {
  @State WordOrSentence: string = ''
  @State isShownTranslation: boolean = false
  @State msg: HTTPForEnglishWordToChineseType | undefined = undefined
  @State msgStr: string = ''
  @State isOneWord: boolean = false
  @State intervalId_two: number | null = 0
  @State intervalId_three: number | null = 0
  @State Index: number = -1
  @State isUploading: boolean = true
  @Prop lanFrom: string = 'zh-Hans'
  @Prop lanTo: string = 'en'

  aboutToAppear(): void {
    this.lanFrom = 'zh-Hans'
    this.lanTo = 'en'
  }

  @Builder
  TranslationDialog() {
    // 请求到内容
    if (!this.isUploading) {
      // 详细信息 - 单词/汉语词
      if (this.Index == 0) {
        if (HTTPForEnglishWordToChinese.myData /*&&
          HTTPForEnglishWordToChinese.myData.data.word ==
            this.WordOrSentence[0].toLowerCase() + this.WordOrSentence.slice(1)*/) {
          Column({ space: 20 }) {
            // 标头
            Row() {
              Text('翻译内容')
                .fontSize(25)
                .fontColor(ComponentsColor.AZURITE_DARK_6TH)
                .fontWeight(900)

              Button('关闭')
                .borderRadius(10)
                .backgroundColor(ComponentsColor.AZURITE_BRIGHT_5TH)
                .fontColor(ComponentsColor.AZURITE_DARK_2ND)
                .padding(8)
                .onClick(() => {
                  this.isShownTranslation = false
                })
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('90%')
            .margin({ left: 40, right: 40, top: 20 })

            // 文本
            Text(HTTPForEnglishWordToChinese.myData.data.word)
              .width('90%')
              .padding({ bottom: 5 })
              .fontSize(30)
              .fontWeight(600)
              .border({
                width: { bottom: 1 },
                radius: { bottomLeft: 10, bottomRight: 10 },
                color: ComponentsColor.AZURITE_DARK_2ND
              })

            // if (this.isOneWord) {
            // 音标
            Row({ space: 10 }) {
              Row() {
                Text('英/\'' + HTTPForEnglishWordToChinese.myData.data.ukphone)

                Image(ComponentsPictures.ICON_PHONE_SOUND)
                  .width(15)
                  .margin({ left: 2 })
              }
              .padding(5)
              .borderRadius(5)
              .backgroundColor(ComponentsColor.AZURITE_BRIGHT_3RD)

              Row() {
                Text('美/\'' + HTTPForEnglishWordToChinese.myData.data.usphone)

                Image(ComponentsPictures.ICON_PHONE_SOUND)
                  .width(15)
                  .margin({ left: 2 })
              }
              .padding(5)
              .borderRadius(5)
              .backgroundColor(ComponentsColor.AZURITE_BRIGHT_3RD)
            }
            .width('90%')

            List({ space: 20 }) {
              // 翻译
              ListItem() {
                Column({ space: 10 }) {
                  Text('翻译')
                    .width('100%')
                    .fontSize(20)
                    .fontColor(ComponentsColor.AZURITE_DARK_2ND)
                    .textAlign(TextAlign.Center)

                  ForEach(HTTPForEnglishWordToChinese.myData.data.translations,
                    (item: translationsType, index: number) => {
                      Row({ space: 20 }) {
                        Text() {
                          Span(item.pos + '.   ')
                            .fontSize(20)
                            .fontWeight(500)
                          Span(item.tran_cn)
                        }
                        .fontSize(18)
                        .fontWeight(300)
                      }
                      .padding({ left: 8, right: 12 })
                      .width('100%')
                    })
                }
                .width('100%')
                .borderRadius(15)
                .backgroundColor('#ccffffff')
                .padding({ top: 5, bottom: 5 })
              }

              // 近义词
              ListItem() {
                Column({ space: 10 }) {
                  Text('近义词')
                    .width('100%')
                    .fontSize(20)
                    .fontColor(ComponentsColor.AZURITE_DARK_2ND)
                    .textAlign(TextAlign.Center)

                  ForEach(HTTPForEnglishWordToChinese.myData.data.synonyms, (item: synonymsType, index: number) => {
                    Row({ space: 20 }) {
                      Text() {
                        ForEach(item.Hwds as HwdsTypeAnother[], (i: HwdsTypeAnother, index: number) => {
                          Span(item.Hwds.length - 1 == index ? i.word + '.' : i.word + ', ')
                            .fontSize(18)
                            .fontWeight(400)
                        })

                        Span('\n' + item.pos + '.   ' + item.tran)
                          .margin({ top: 4 })
                      }
                      .fontSize(18)
                      .fontWeight(300)
                    }
                    .padding({ left: 8, right: 12 })
                    .width('100%')
                  })
                }
                .width('100%')
                .borderRadius(15)
                .backgroundColor('#ccffffff')
                .padding({ top: 5, bottom: 5 })
              }

              // 短语
              ListItem() {
                Column({ space: 10 }) {
                  Text('短语')
                    .width('100%')
                    .fontSize(20)
                    .fontColor(ComponentsColor.AZURITE_DARK_2ND)
                    .textAlign(TextAlign.Center)

                  ForEach(HTTPForEnglishWordToChinese.myData.data.phrases, (item: phrasesType, index: number) => {
                    Row({ space: 20 }) {
                      Text() {
                        Span(`${index + 1}. `)
                          .fontSize(18)
                          .fontWeight(400)
                        Span(item.p_content + '.  ')
                          .fontSize(20)
                          .fontWeight(500)
                        Span(item.p_cn)
                      }
                      .fontSize(18)
                      .fontWeight(300)
                    }
                    .width('90%')
                    .padding({ left: 8, right: 12 })
                    .justifyContent(FlexAlign.Start)
                  })
                }
                .width('100%')
                .borderRadius(15)
                .backgroundColor('#ccffffff')
                .padding({ top: 5, bottom: 5 })
              }

              // 例句
              ListItem() {
                Column({ space: 10 }) {
                  Text('例句')
                    .width('100%')
                    .fontSize(20)
                    .fontColor(ComponentsColor.AZURITE_DARK_2ND)
                    .textAlign(TextAlign.Center)

                  ForEach(HTTPForEnglishWordToChinese.myData.data.sentences, (item: sentencesType, index: number) => {
                    Row({ space: 20 }) {
                      Text() {
                        Span(`${index + 1}. ` + item.s_content)
                          .fontSize(18)
                          .fontWeight(400)
                        Span('\n  ' + item.s_cn)
                      }
                      .fontSize(18)
                      .fontWeight(300)
                    }
                    .padding({ left: 8, right: 12 })
                    .width('100%')
                  })
                }
                .width('100%')
                .borderRadius(15)
                .backgroundColor('#ccffffff')
                .padding({ top: 5, bottom: 5 })
              }

              // 同根词
              ListItem() {
                Column({ space: 10 }) {
                  Text('同根词')
                    .width('100%')
                    .fontSize(20)
                    .fontColor(ComponentsColor.AZURITE_DARK_2ND)
                    .textAlign(TextAlign.Center)

                  ForEach(HTTPForEnglishWordToChinese.myData.data.relWords, (item: relWordsType, index: number) => {
                    Row({ space: 20 }) {
                      Text() {
                        ForEach(item.Hwds as HwdsType[], (i: HwdsType, index: number) => {
                          Span(i.hwd)
                            .fontSize(18)
                            .fontWeight(400)
                          Span('\n' + item.Pos + '. ' + i.tran)
                            .margin({ top: 4 })
                        })


                      }
                      .fontSize(18)
                      .fontWeight(300)
                    }
                    .padding({ left: 8, right: 12 })
                    .width('100%')
                  })
                }
                .width('100%')
                .borderRadius(15)
                .backgroundColor('#ccffffff')
                .padding({ top: 5, bottom: 5 })
              }

              ListItem() {
              }
              .height(180)
              .width('100%')
            }
            .scrollBar(BarState.Off)
            .width('90%')
            .alignListItem(ListItemAlign.Start)
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          }
          .width('100%')
          .height('100%')
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [[ComponentsColor.AZURITE_BRIGHT_5TH, 0], [ComponentsColor.AZURITE_BRIGHT_7TH, 1]]
          })
        } else {
          Column() {
            Row() {
              Text('翻译内容')
                .fontSize(25)
                .fontColor(ComponentsColor.AZURITE_DARK_6TH)
                .fontWeight(900)

              Button('关闭')
                .borderRadius(10)
                .backgroundColor(ComponentsColor.AZURITE_BRIGHT_5TH)
                .fontColor(ComponentsColor.AZURITE_DARK_2ND)
                .padding(8)
                .onClick(() => {
                  this.isShownTranslation = false
                })
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('90%')
            .margin({ left: 40, right: 40, top: 20 })

            Text('查询单词出错')
              .margin({ top: 10 })
          }

          .width('100%')
          .height('100%')
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [[ComponentsColor.AZURITE_BRIGHT_5TH, 0], [ComponentsColor.AZURITE_BRIGHT_7TH, 1]]
          })
        }
      }
      // 仅仅翻译
      else if (this.Index == 1) {
        if (HTTPForZhToEn.myData_tran &&
          HTTPForZhToEn.currText == this.WordOrSentence) {
          Column({ space: 20 }) {
            // 标头
            Row() {
              Text('翻译内容')
                .fontSize(25)
                .fontColor(ComponentsColor.AZURITE_DARK_6TH)
                .fontWeight(900)

              Button('关闭')
                .borderRadius(10)
                .backgroundColor(ComponentsColor.AZURITE_BRIGHT_5TH)
                .fontColor(ComponentsColor.AZURITE_DARK_2ND)
                .padding(8)
                .onClick(() => {
                  this.isShownTranslation = false
                })
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('90%')
            .margin({ left: 40, right: 40, top: 20 })

            // 文本
            Text(HTTPForZhToEn.currText)
              .width('90%')
              .padding({ bottom: 5 })
              .fontSize(30)
              .fontWeight(600)
              .border({
                width: { bottom: 1 },
                radius: { bottomLeft: 10, bottomRight: 10 },
                color: ComponentsColor.AZURITE_DARK_2ND
              })

            // 翻译
            Text(HTTPForZhToEn.myData_tran)
              .width('90%')
              .padding({ bottom: 5 })
              .fontSize(30)
          }
          .width('100%')
          .height('100%')
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [[ComponentsColor.AZURITE_BRIGHT_5TH, 0], [ComponentsColor.AZURITE_BRIGHT_7TH, 1]]
          })
        } else {
          Column() {
            Row() {
              Text('翻译内容')
                .fontSize(25)
                .fontColor(ComponentsColor.AZURITE_DARK_6TH)
                .fontWeight(900)

              Button('关闭')
                .borderRadius(10)
                .backgroundColor(ComponentsColor.AZURITE_BRIGHT_5TH)
                .fontColor(ComponentsColor.AZURITE_DARK_2ND)
                .padding(8)
                .onClick(() => {
                  this.isShownTranslation = false
                })
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('90%')
            .margin({ left: 40, right: 40, top: 20 })

            Text('查询出错')
              .margin({ top: 10 })
          }

          .width('100%')
          .height('100%')
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [[ComponentsColor.AZURITE_BRIGHT_5TH, 0], [ComponentsColor.AZURITE_BRIGHT_7TH, 1]]
          })
        }
      }
      // else if (this.Index == 2) {
      // }
      // else if (this.Index == 3) {
      // }
    }
    // 没有请求到内容
    else {
      Column({ space: 20 }) {
        // 标头
        Row() {
          Text('翻译内容')
            .fontSize(25)
            .fontColor(ComponentsColor.AZURITE_DARK_6TH)
            .fontWeight(900)

          Button('关闭')
            .borderRadius(10)
            .backgroundColor(ComponentsColor.AZURITE_BRIGHT_5TH)
            .fontColor(ComponentsColor.AZURITE_DARK_2ND)
            .padding(8)
            .onClick(() => {
              this.isShownTranslation = false
            })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('90%')
        .margin({ left: 40, right: 40, top: 20 })

        // 加载
        LoadingProgress()
          .width(50)
          .margin({ top: 20})
      }
      .width('100%')
      .height('100%')
      .linearGradient({
        direction: GradientDirection.Right,
        colors: [[ComponentsColor.AZURITE_BRIGHT_5TH, 0], [ComponentsColor.AZURITE_BRIGHT_7TH, 1]]
      })
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
            if (this.WordOrSentence) {
              // 单词
              if (this.lanFrom == 'en' && this.WordOrSentence.split(' ').length == 1) {
                hilog.info(0x0000, '[publicMainFuncTag]', 'success1')
                HTTPForEnglishWordToChinese.HTTPForEnglishWordToChinese(this.WordOrSentence.trim())
                this.msg = HTTPForEnglishWordToChinese.myData
                this.isShownTranslation = true
                this.isOneWord = true
                this.Index = 0
                this.isUploading = true

                this.intervalId_two = setInterval(() => {
                  if (HTTPForEnglishWordToChinese.myData) {
                    this.isUploading = false
                    clearInterval(this.intervalId_two)
                    this.intervalId_two = null
                  }
                }, 600)
              }
              // 英语句子
              else if (this.lanFrom == 'en' && this.WordOrSentence.split(' ').length !== 1) {
                hilog.info(0x0000, '[publicMainFuncTag]', 'success2')
                HTTPForZhToEn.httpForZhToEn(this.WordOrSentence.trim(), this.lanTo)
                // hilog.info(0x0000, '[publicMainFuncTag]', 'success2' + HTTPForZhToEn.myData_tran)
                // hilog.info(0x0000, '[publicMainFuncTag]', 'success2')
                // hilog.info(0x0000, '[publicMainFuncTag]', 'success2')
                this.msgStr = HTTPForZhToEn.myData_tran
                this.isUploading = true
                this.isShownTranslation = true
                this.isOneWord = false
                this.Index = 1

                this.intervalId_two = setInterval(() => {
                  if (HTTPForZhToEn.myData_tran && HTTPForZhToEn.currText) {
                    this.isUploading = false
                    clearInterval(this.intervalId_two)
                    this.intervalId_two = null
                  }
                }, 600)
              }
              // 汉语
              else if (this.lanFrom == 'zh-Hans') {
                hilog.info(0x0000, '[publicMainFuncTag]', 'success3')
                HTTPForZhToEn.httpForZhToEn(this.WordOrSentence.trim(), this.lanTo)
                this.msgStr = HTTPForZhToEn.myData_tran
                this.isUploading = true
                this.isShownTranslation = true
                this.isOneWord = false
                this.Index = 1

                this.intervalId_two = setInterval(() => {
                  if (HTTPForZhToEn.myData_tran && HTTPForZhToEn.currText) {
                    clearInterval(this.intervalId_two)
                    this.intervalId_two = null
                    if (HTTPForZhToEn.myData_tran.trim().split(' ').length == 1) {
                      HTTPForEnglishWordToChinese.HTTPForEnglishWordToChinese(HTTPForZhToEn.myData_tran.trim())
                      this.msg = HTTPForEnglishWordToChinese.myData
                      this.isShownTranslation = true
                      this.isOneWord = true
                      this.Index = 0
                      this.isUploading = true

                      this.intervalId_three = setInterval(() => {
                        if (HTTPForEnglishWordToChinese.myData) {
                          hilog.info(0x0000, '[publicTranslationTag]', JSON.stringify(HTTPForEnglishWordToChinese.myData))
                          this.isUploading = false
                          clearInterval(this.intervalId_three)
                          this.intervalId_three = null
                        }
                      }, 600)
                    }
                    this.isUploading = false
                  }
                }, 600)
              }

              // else if () {}
            }
          })//
          .bindSheet($$this.isShownTranslation, this.TranslationDialog, {
            height: this.isOneWord ? SheetSize.LARGE : SheetSize.MEDIUM,
            blurStyle: BlurStyle.Thin,
            borderWidth: { top: 2, right: 3, left: 3 },
            borderColor: ComponentsColor.AZURITE_DARK_1ST,
            showClose: false,
            onDisappear: () => {
              this.isShownTranslation = false
              HTTPForZhToEn.myData_tran = ''
              HTTPForZhToEn.currText = ''
              HTTPForEnglishWordToChinese.myData = undefined
              clearInterval(this.intervalId_two)
              this.intervalId_two = null
              clearInterval(this.intervalId_three)
              this.intervalId_three = null
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