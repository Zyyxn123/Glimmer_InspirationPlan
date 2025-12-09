import { ComponentsSize, ComponentsColor, ComponentsPictures } from 'utils'

@Component
export struct ChangeLanguage {
  @State isShowChangeLanguage: boolean = false
  @State languageFrom: string = '中文'
  @State languageTo: string = '英语'
  @State currentClassify: number = 0;
  @Link lanFrom: string
  @Link lanTo: string

  // private classifyList: Array<ClassifyAlphaListModel> = [];
  // private classifyScroller: Scroller = new Scroller();
  // private scroller: Scroller = new Scroller();
  // private alphabetList: string[] = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');

  aboutToAppear(): void {
    // this.classifyList = classifyViewModel.getLinkData()
    //
    // for (let indexs = 0; indexs < this.classifyList.length; indexs++) {
    //   let k = indexs
    //   hilog.info(0x0000, '[publicAlphaList]', k.toString() )
    //   hilog.info(0x0000, '[publicAlphaList]', this.classifyList.length.toString() )
    //   for (let index = 0; index < this.classifyList[k].regionList.length; index++) {
    //     hilog.info(0x0000, '[publicAlphaList]', JSON.stringify(this.classifyList[k].regionList[index]))
    //   }
    // }
  }

  // classifyChangeAction(index: number, isClassify: boolean): void {
  //   if (this.currentClassify !== index) {
  //     // change the classify status.
  //     this.currentClassify = index;
  //     if (isClassify) {
  //       // scroll the course scroll.
  //       this.scroller.scrollToIndex(index);
  //     } else {
  //       // scroll the classify scroll.
  //       this.classifyScroller.scrollToIndex(index);
  //     }
  //   }
  // }

  // @Builder
  // ChangeLanguage() {
  //   Column({ space: 20 }) {
  //     Row() {
  //       Text('更改语言')
  //         .fontSize(25)
  //         .fontColor(ComponentsColor.ROUGE_DARK_6TH)
  //         .fontWeight(900)
  //
  //       Button('关闭')
  //         .borderRadius(10)
  //         .backgroundColor(ComponentsColor.ROUGE_BRIGHT_7TH)
  //         .fontColor(ComponentsColor.ROUGE_DARK_2ND)
  //         .padding(8)
  //         .onClick(() => {
  //           this.isShowChangeLanguage = false
  //         })
  //     }
  //     .justifyContent(FlexAlign.SpaceBetween)
  //     .width('100%')
  //
  //     Row() {
  //       List({ scroller: this.scroller }) {
  //         ForEach(this.classifyList, (classifyItem: ClassifyAlphaListModel) => {
  //           ListItemGroup({
  //             header: this.ClassifyHeader(classifyItem.classifyName),
  //             space: 5
  //           }) {
  //             ForEach(classifyItem.regionList, (RegionItem: RegionListModel) => {
  //               ListItem() {
  //                 regionItem({ RegionItemStr: JSON.stringify(RegionItem) })
  //               }
  //             }/*, (courseItem: RegionListModel) => `${courseItem.classifyId}`*/)
  //           }
  //         }/*, (item: ClassifyAlphaListModel) => `${item.classifyId}`*/)
  //       }
  //       .sticky(StickyStyle.Header)
  //       .edgeEffect(EdgeEffect.None)
  //       .onScrollIndex((start: number) => this.classifyChangeAction(start, false))
  //
  //       // List({ scroller: this.classifyScroller }) {
  //       //   ForEach(this.classifyList, (item: ClassifyAlphaListModel, index?: number) => {
  //       //     ListItem() {
  //       //       ClassifyItem({
  //       //         classifyName: item.classifyName,
  //       //         isSelected: this.currentClassify === index,
  //       //         onClickAction: () => {
  //       //           if (index !== undefined) {
  //       //             this.classifyChangeAction(index, true);
  //       //           }
  //       //         }
  //       //       })
  //       //     }
  //       //   }, (item: ClassifyAlphaListModel) => item.classifyName.toString() + this.currentClassify)
  //       // }
  //       // .scrollBar(BarState.Off)
  //     }
  //   }
  //   .margin({ left: 15, right: 20, top: 20 })
  // }

  // @Builder
  // ClassifyHeader(classifyName: string) {
  //   Row() {
  //     Text(classifyName)
  //     // .fontSize($r('app.float.header_font_size'))
  //     // .fontColor($r('app.color.base_font_color'))
  //     // .fontFamily($r('app.string.hei_ti_medium'))
  //     // .fontWeight(Constants.TITLE_FONT_WEIGHT)
  //   }
  //
  //   // .padding({ left: $r('app.float.item_padding_left') })
  //   // .height($r('app.float.classify_item_height'))
  //   // .width(Constants.FULL_PERCENT)
  //   // .backgroundColor($r('app.color.base_background'))
  // }

  build() {
    Row({ space: 8 }) {
      Text(this.languageFrom)
        .fontSize(20)
        .fontWeight(500)
        .fontColor(Color.White)
      Image(ComponentsPictures.ICON_LANGUAGE_TRANSFORM)
        .width(25)
        .fillColor(Color.White)
        .onClick(() => {
          this.isShowChangeLanguage = false
          let tmp: string = this.languageFrom
          this.languageFrom = this.languageTo
          this.languageTo = tmp
          if (this.languageFrom == '中文') {
            this.lanFrom = 'zh-Hans'
            this.lanTo = 'en'
          } else {
            this.lanFrom = 'en'
            this.lanTo = 'zh-Hans'
          }
        })

      Text(this.languageTo)
        .fontSize(20)       .fontColor(Color.White)
        .fontWeight(500)
        // .bindSheet($$this.isShowChangeLanguage, this.ChangeLanguage, {
        //   height: 650,
        //   showClose: false,
        //   blurStyle: BlurStyle.Thin,
        //   borderWidth: { top: 2, right: 3, left: 3 },
        //   borderColor: ComponentsColor.AZURITE_DARK_1ST,
        //   onDisappear: () => {
        //     this.isShowChangeLanguage = false
        //   },
        // })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height(40)
    .onClick(() => {
      this.isShowChangeLanguage = true
    })
  }
}

