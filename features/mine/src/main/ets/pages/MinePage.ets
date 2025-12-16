import { ComponentsSize, ComponentsColor, ComponentsPictures } from 'utils'
import { BasicCard } from '../View/BasicCard';
import { BasicData } from '../View/BasicData';
import { ChangePhotoAvatar } from '../View/ChangePhotoAvatar';
import { Setting } from '../View/Setting';
import { FunctionItems } from '../View/FunctionItems';
import { FunctionSet } from '../View/FunctionSet';
import { NameAndSign } from '../View/NameAndSign';
import { PhotoAvatar } from '../View/PhotoAvatar';
import { CPAViewModel } from '../ViewModel/CPAViewModel';
import { ChangeBasicData } from '../View/ChangeBasicData';
import { MyCollection } from '../View/MyCollection';
import { BasicDataViewModel } from '../ViewModel/BasicDataViewModel';
import { DailyEnglish } from '../View/DailyEnglish';
import { HTTPForDailyEnglish, httpRequestForDailyEnglishType } from '../utils/HTTPForDailyEnglish';

// import { CommonCharts } from 'module_line_chart';

@Component
export struct MinePage {
  @StorageLink('PageInfos') pageStack: NavPathStack = new NavPathStack();
  @Provide('mine_pageStack') pageInfos: NavPathStack = new NavPathStack()
  private basicDataViewModel: BasicDataViewModel = BasicDataViewModel.Instance()
  // private httpForDailyEnglish: HTTPForDailyEnglish = new HTTPForDailyEnglish()
  // @Provide('DailyEnglish') DE: httpRequestForDailyEnglishType | undefined = undefined
  aboutToAppear(): void {
    if (CPAViewModel.Instance().pa.length == 0) {
      CPAViewModel.Instance().init()
    }
    this.basicDataViewModel.getAllCollectionMsg()

    // this.httpForDailyEnglish.httpRequestForDailyEnglish()
    // this.DE = this.httpForDailyEnglish.DE
  }
  onPageShow(): void {

  }

  @Builder
  pageMaps(name: string) {
    if (name === 'changePhotoAvatar') {
      ChangePhotoAvatar()
    } else if (name === 'changeSetting') {
      Setting()
    } else if (name === 'changeBasicData') {
      ChangeBasicData()
    } else if (name === 'myCollection') {
      MyCollection()
    } else if (name === 'dailyEnglish') {
      DailyEnglish()
    }
  }

  build() {
    Navigation(this.pageInfos) {
      Stack({ alignContent: Alignment.Bottom }) {
        // 头像 + 基本信息
        Column() {
          Row() {
            PhotoAvatar()

            BasicData()
          }

          NameAndSign()
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Top,
          colors: [[ComponentsColor.AZURITE_DARK_3RD, 0],
            [ComponentsColor.AZURITE_DARK_2ND, 0.1],
            [ComponentsColor.AZURITE_BRIGHT_2ND, 0.2],
            [ComponentsColor.AZURITE_BRIGHT_4TH, 0.4],
            [ComponentsColor.AZURITE_BRIGHT_6TH, 0.6],
            [ComponentsColor.AZURITE_BRIGHT_7TH, 0.8],
            [ComponentsColor.AZURITE_DARK_1ST, 1]]
        })

        // 个人主要信息
        Column({ space: 10 }) {
          BasicCard()

          FunctionSet()

          FunctionItems()
        }
        // .border({ width: { top: 2, left: 2, right: 2}, color: ComponentsColor.AZURITE_BRIGHT_1ST})
        .width('100%')
        .height('70%')
        .backgroundColor('#ffffff')
        .borderRadius({ topLeft: 25, topRight: 25 })

        // .radialGradient({
        //   center: ['50%', '50%'],
        //   radius: 180,
        //   colors: [
        //     [ComponentsColor.AZURITE_BRIGHT_4TH, 0.0],
        //     [ComponentsColor.AZURITE_BRIGHT_3RD, 0.2],
        //     [ComponentsColor.AZURITE_BRIGHT_2ND, 0.4],
        //     [ComponentsColor.AZURITE_BRIGHT_1ST, 0.6],
        //     [ComponentsColor.AZURITE_DARK_1ST, 0.8],
        //     [ComponentsColor.AZURITE_DARK_2ND, 1.0],
        //     // [ComponentsColor.AZURITE_DARK_3RD, 1]
        //     // [ComponentsColor.AZURITE_DARK_4TH, 0.7],
        //     // [ComponentsColor.AZURITE_DARK_5TH, 0.8],
        //     // [ComponentsColor.AZURITE_DARK_6TH, 0.9],
        //     // [ComponentsColor.AZURITE_DARK_7TH, 1.0]
        //   ]
        // })
      }
      .width('100%')
      .height('100%')
    }
    .navDestination(this.pageMaps)

  }
}

// .padding({
//   top: this.getUIContext().px2vp(this.topRectHeight),
//   bottom: this.getUIContext().px2vp(this.bottomRectHeight)
// })
