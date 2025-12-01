import { MinePage } from 'mine'
import { ComponentsPictures, ComponentsSize, ComponentsColor } from 'utils'
import {
  HdsTabs,
  HdsTabsAttribute,
  HdsTabsController,
  DividerMode,
  HdsTabsBackgroundStyle,
  bleedIconStyle
} from '@kit.UIDesignKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Translation } from 'translation'

@Builder
export function MainPageBuilder() {
  MainPage();
}

@Component
export struct MainPage {
  @State currentIndex: number = 0;
  @State currentInnerIndex: number = 0;
  @State selectedIndex: number = 0;
  @State angle: number = 1;
  @StorageLink('PageInfos') pageInfo: NavPathStack = new NavPathStack();
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  private controller: HdsTabsController = new HdsTabsController();
  private uiContext: UIContext | undefined = undefined;

  aboutToAppear() {
    this.uiContext = this.getUIContext?.();
  }

  @Builder
  myTabsBar(pic: ResourceStr, text: string, targetIndex: number) {
    Column() {
      Image(pic)
        .width(30)
        .margin({ bottom: 5 })
      Text(text)
        .fontColor(this.currentIndex == targetIndex ? ComponentsColor.AZURITE_DARK_4TH :
          ComponentsColor.AZURITE_BRIGHT_1ST)
        .textAlign(TextAlign.Center)
        .fontSize(16)
        .width(60)
        .height(30)
        .padding(6)
        .borderRadius(15)
        .backgroundColor(this.currentIndex == targetIndex ? ComponentsColor.AZURITE_BRIGHT_1ST : Color.Transparent)
    }
  }

  @Builder
  tabBuilder(targetIndex: number) {
    Stack({ alignContent: Alignment.Center }) {
      Image($r('app.media.icon_tabs_pics'))
        .width(80)
        .height(80)
        .borderRadius(40)
        .backgroundColor(this.currentIndex == targetIndex ? ComponentsColor.AZURITE_DARK_2ND :
          ComponentsColor.AZURITE_BRIGHT_2ND)
        .rotate({
          x: 0,
          y: 0,
          z: 1,
          centerX: '50%',
          centerY: '50%',
          angle: this.angle
        })
    }
    .margin({ bottom: 30 })
  }

  @Builder
  innerTabsBuilder(targetIndex: number, text: string, img: ResourceStr) {
    Stack({ alignContent: Alignment.Bottom}) {
      Row({ space: 5 }) {
        Image(img)
          .width(this.currentInnerIndex == targetIndex ? 40 : 30)
          .fillColor(this.currentInnerIndex == targetIndex ? targetIndex == 0 ? ComponentsColor.AZURITE_DARK_1ST : ComponentsColor.ROUGE_DARK_1ST : '#ccc')
        Text(text)
          .fontSize(this.currentInnerIndex == targetIndex ? 30 : 20)
          .fontColor(this.currentInnerIndex == targetIndex ? targetIndex == 0 ? ComponentsColor.ROUGE_DARK_7TH : ComponentsColor.ROUGE_DARK_7TH : '#ccc')
      }
      .width('100%')
      .borderRadius(15)
      .margin({ left: 10})
    }
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight)})
  }

  build() {
    NavDestination() {
      HdsTabs({ barPosition: BarPosition.End, controller: this.controller }) {
        TabContent() {
          Tabs() {
            TabContent() {
              Translation()
            }
            .tabBar(this.innerTabsBuilder(0, '翻译', ComponentsPictures.ICON_TABS_TRANSLATION))

            TabContent() {
              Button('return')
                .onClick(() => {
                  AppStorage.set('LoginState', false)
                })
            }
            .tabBar(this.innerTabsBuilder(1, '单词', ComponentsPictures.ICON_TABS_WORD))
          }
          // .padding({ bottom: 20})
          .linearGradient({
            direction: GradientDirection.Right,
            colors: this.currentInnerIndex == 0
              ? [[ComponentsColor.AZURITE_BRIGHT_7TH, 0], [ComponentsColor.ROUGE_BRIGHT_7TH, 1]]
              : [[ComponentsColor.ROUGE_BRIGHT_7TH, 0], [ComponentsColor.AZURITE_BRIGHT_7TH, 1]]
          })
          // .barBackgroundColor(this.currentInnerIndex == 0 ? ComponentsColor.AZURITE_BRIGHT_7TH : ComponentsColor.ROUGE_BRIGHT_7TH)
          .onChange((index: number) => {
            this.currentInnerIndex = index
          })
          .onAnimationStart((index: number) => {
            this.currentInnerIndex = index
          })
          .animationDuration(100)
          .barHeight(80)
          .animationCurve(Curve.Linear)
          .barPosition(BarPosition.Start)
          // .barMode(BarMode.Scrollable, { margin: '20%' })
          .width('100%')
          // .edgeEffect(EdgeEffect.Fade)
          // .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
          // .margin({ top: this.getUIContext().px2vp(this.topRectHeight) })
        }
        .tabBar(this.myTabsBar(ComponentsPictures.ICON_TABS_MAIN, '首页', 0))

        TabContent() {
        }
        .tabBar(bleedIconStyle(() => {
          this.tabBuilder(1)
        }))

        TabContent() {
          MinePage()
        }.tabBar(this.myTabsBar(ComponentsPictures.ICON_TABS_MINE, '我的', 2))

      }
      .animationDuration(100)
      .scrollable(false)
      .barOverlap(true)
      .barBackgroundBlurStyle(BlurStyle.Thin, { policy: BlurStyleActivePolicy.ALWAYS_ACTIVE })
      .barBackgroundStyle({ maskColor: ComponentsColor.AZURITE_BRIGHT_3RD, maskHeight: 70 })
      .barHeight(65)
      .onChange((index: number) => {
        this.currentIndex = index
        if (this.currentIndex == 1) {
          if (!this.uiContext) {
            return;
          }
          this.uiContext.keyframeAnimateTo({ iterations: 2 }, [
            {
              duration: 150,
              curve: Curve.Linear,
              event: () => {
                this.angle = -10
              }
            },
            {
              duration: 150,
              curve: Curve.Linear,
              event: () => {
                this.angle = 0
              }
            },
            {
              duration: 150,
              curve: Curve.Linear,
              event: () => {
                this.angle = 20
              }
            },
            {
              duration: 150,
              curve: Curve.Linear,
              event: () => {
                this.angle = 0
              }
            },
          ])
        }
      })
    }
    .onReady((context: NavDestinationContext) => {
      this.pageInfo = context.pathStack;
    })
  }
}

// .padding({
//   top: this.getUIContext().px2vp(this.topRectHeight),
//   bottom: this.getUIContext().px2vp(this.bottomRectHeight)
// })