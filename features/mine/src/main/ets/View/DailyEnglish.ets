import { HTTPForDailyEnglish, httpRequestForDailyEnglishType } from "../utils/HTTPForDailyEnglish";
import {
  HTTPForDailyEnglishWord,
  HTTPForDailyEnglishWordType,
  translationsType
} from "../utils/HTTPForDailyEnglishWord";

@Component
export struct DailyEnglish {
  /*@Consume('DailyEnglish')*/
  @State DE: httpRequestForDailyEnglishType | undefined = undefined
  /*@Consume('DailyEnglish')*/
  @State DEW: HTTPForDailyEnglishWordType | undefined = undefined
  @Consume('mine_pageStack') pageInfos: NavPathStack
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  private httpForDailyEnglish: HTTPForDailyEnglish = new HTTPForDailyEnglish()
  private httpForDailyEnglishWord: HTTPForDailyEnglishWord = new HTTPForDailyEnglishWord()

  aboutToAppear(): void {
    this.httpForDailyEnglish.httpRequestForDailyEnglish()
    this.DE = this.httpForDailyEnglish.DE
    this.httpForDailyEnglishWord.httpRequestForDailyEnglishWord()
    this.DEW = this.httpForDailyEnglishWord.DEW
  }

  build() {
    NavDestination() {
      Column({ space: 20 }) {
        /**
         * daily English Pic & sentence
         * */
        Column() {
          if (this.httpForDailyEnglish.DE?.code === 200) {
            Image(`${this.httpForDailyEnglish.DE.data.img}`)
              .objectFit(ImageFit.TOP)
              .height(260)
              .width('100%')
          } else {
            LoadingProgress()
              .width(50)
          }
        }
        .width('90%')
        .height(260)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#ffdddddd')
        .borderRadius(15)

        /**
         * daily English word
         * */
        Column() {
          Row() {
            Image($r('app.media.loadingDE'))
              .width(25)
              .margin({ right: 15, top: 10, bottom: 10 })
              .onClick(() => {
                this.httpForDailyEnglishWord.DEW = undefined
                this.httpForDailyEnglishWord.httpRequestForDailyEnglishWord()
                this.DEW = this.httpForDailyEnglishWord.DEW
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.End)

          Column({ space: 15 }) {
            List() {
              ListItem() {
                Column() {
                  if (this.httpForDailyEnglishWord.DEW?.code === 200) {
                    if (this.httpForDailyEnglishWord.DEW.data.word) {
                      List() {
                        ListItem() {
                          Text(this.httpForDailyEnglishWord.DEW.data.word)
                            .width('100%')
                            .textAlign(TextAlign.Center)
                            .fontSize(40)
                            .fontWeight(600)
                            .maxLines(1)
                        }
                      }
                      .height(48)
                      .listDirection(Axis.Horizontal)
                      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
                      .scrollBar(BarState.Off)
                    }

                    if (this.httpForDailyEnglishWord.DEW.data.ukphone) {
                      List() {
                        ListItem() {
                          Row({ space: 8 }) {

                            Text('英/\'' + this.httpForDailyEnglishWord.DEW.data.ukphone)
                            Text('美/\'' + this.httpForDailyEnglishWord.DEW.data.usphone)
                          }
                        }
                      }
                      .height(26)
                      .listDirection(Axis.Horizontal)
                      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
                      .scrollBar(BarState.Off)
                    }

                    Column({ space: 5 }) {
                      if (this.httpForDailyEnglishWord.DEW.data.translations.length > 0) {
                        ForEach(this.httpForDailyEnglishWord.DEW.data.translations,
                          (item: translationsType, index: number) => {
                            Row({ space: 20 }) {
                              Text() {
                                Span(item.pos + '.   ')
                                  .fontSize(18)
                                  .fontWeight(500)
                                Span(item.tran_cn)
                              }
                              .fontSize(16)
                              .fontWeight(300)
                            }
                            .padding({ left: 8, right: 12 })
                            .width('100%')
                          })
                      }

                      if (this.httpForDailyEnglishWord.DEW.data.sentences[0]?.s_content) {
                        // Row() {
                        Text() {
                          Span(this.httpForDailyEnglishWord.DEW.data.sentences[0]?.s_content + '\n')
                            .fontSize(18)
                          Span(this.httpForDailyEnglishWord.DEW.data.sentences[0]?.s_cn)
                            .fontSize(15)
                        }
                        // }
                        .width('100%')
                        .textAlign(TextAlign.Start)

                        // .justifyContent(FlexAlign.Center)
                      }
                    }
                    .width(260)
                  } else {
                    LoadingProgress()
                      .width(60)
                  }
                }
              }
            }
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          }
          .width(280)
          .height(280)
          .backgroundColor(Color.White)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Start)
          .borderRadius(15)
          .margin({ bottom: 15 })
        }
        .width('90%')
        .height(350)
        .backgroundColor('#ffdddddd')
        .borderRadius(15)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
    }
    .title('每日英语')
    .padding({
      top: this.getUIContext().px2vp(this.topRectHeight),
    })
    .onBackPressed(() => {
      AppStorage.set('TabsBarHeight_changeToCamera', false)
      return false
    })
  }
}