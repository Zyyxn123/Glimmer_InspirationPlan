import { JSON } from "@kit.ArkTS";
import { hilog } from "@kit.PerformanceAnalysisKit";
import { textRecognition } from '@kit.CoreVisionKit'
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { LengthMetrics } from '@kit.ArkUI';
import { paramType } from "./OperateButtonsView";
import { smartFormatSpacing } from "../utils/FormatText";
import { HTTPForZhToEn } from "../utils/HTTPForZhToEn";


const DOMAIN = 0x0000;

@Component
export default struct photo_translation {
  private imageSource: image.ImageSource | undefined = undefined;
  @State chooseImage: PixelMap | null = null;
  @State dataValues: string = '';
  @State maxLines: number = 2
  @State dataResultValues: string = '';
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @Consume('pathStack') pathInfos: NavPathStack;
  pageParam: PixelMap | null = null;
  context = this.getUIContext().getHostContext();

  async aboutToAppear(): Promise<void> {
    const initResult = await textRecognition.init();
    hilog.info(0x0000, 'OCRDemo', `OCR service initialization result:${initResult}`);
  }

  async aboutToDisappear(): Promise<void> {
    await textRecognition.release();
    hilog.info(0x0000, 'OCRDemo', 'OCR service released successfully');
  }

  private async selectImage() {
    let uri = await this.openPhoto();
    if (uri === undefined) {
      hilog.error(0x0000, 'OCRDemo', "Failed to get uri.");
      return;
    }
    this.loadImage(uri);
  }

  private openPhoto(): Promise<string> {
    return new Promise<string>((resolve, reject) => {
      let photoPicker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker();
      photoPicker.select({
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      }).then((res: photoAccessHelper.PhotoSelectResult) => {
        resolve(res.photoUris[0]);
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'OCRDemo', `Failed to get photo image uri. code：${err.code}，message：${err.message}`);
        reject('');
      })
    })
  }

  private loadImage(name: string) {
    setTimeout(async () => {
      try {
        let fileSource = await fileIo.open(name, fileIo.OpenMode.READ_ONLY);
        this.imageSource = image.createImageSource(fileSource.fd);
        this.chooseImage = await this.imageSource.createPixelMap();
      } catch (error) {
        hilog.error(0x0000, 'OCRDemo', "fileIo.open error: " + JSON.stringify(error));
      }
    }, 100)
  }

  build() {
    NavDestination() {
      List() {
        ListItem() {
          Column() {
            if ( HTTPForZhToEn.myData_tran) {
              Row() {
                Text(this.dataValues)
                  .margin({ bottom: 5})
                  .maxLines(this.maxLines)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .copyOption(CopyOptions.LocalDevice)
              }
              .width('100%')
              .padding(15)
              .border({width: {bottom: 1}, color: Color.Black, radius: { bottomLeft: 15, bottomRight: 15}})
              .onClick(() => {
                this.maxLines = this.maxLines == 2 ? -1 : 2
              })

              Text(HTTPForZhToEn.myData_tran)
                .margin({ top: 15})
                .copyOption(CopyOptions.LocalDevice)
                .padding(15)
            } else {
              LoadingProgress()
                .width(50)
                .height(50)
                .margin({ top: 5})
            }

            Column() {}
            .width('100%')
            .height(100)
          }
          .margin({left: 10, right: 10})
          .width('90%')
        }
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .width('100%')
    }
    // .padding({
    //   top: this.getUIContext().px2vp(this.topRectHeight),
    // })
    .onWillDisappear(() => {
      this.dataValues = ''
      this.dataResultValues = ''
    })
    .title('翻译界面')
    .onReady(async (context: NavDestinationContext) => {
      this.pathInfos = context.pathStack;
      this.pageParam = context.pathInfo.param as PixelMap;
      hilog.info(0x0000, '[TextFucTag]', 'success00')
      hilog.info(0x0000, '[TextFucTag]', JSON.stringify(this.pageParam))
      if (this.pageParam !== null) {
        this.chooseImage = this.pageParam
        hilog.info(0x0000, '[TextFucTag]', 'success01')
        this.textRecognitionTest()
          .then(async () => {
            hilog.info(0x0000, '[TextFucTag]', 'success02:' + this.dataValues)
            this.dataValues = smartFormatSpacing(this.dataValues)
            hilog.info(0x0000, '[TextFucTag]', 'success03:' + this.dataValues)
            await HTTPForZhToEn.httpForZhToEn(this.dataValues, AppStorage.get('lanTo')!)
            // this.dataResultValues = HTTPForZhToEn.myData_tran
            hilog.info(0x0000, '[TextFucTag]', 'success04:' +  HTTPForZhToEn.myData_tran)
        })

      }
    })
    .onBackPressed(() => {
      const popDestinationInfo = this.pathInfos.pop();
      this.dataValues = ''
      HTTPForZhToEn.myData_tran = ''
      return true;
    })
  }

  private async textRecognitionTest() {
    if (!this.chooseImage) {
      return;
    }
    let visionInfo: textRecognition.VisionInfo = {
      pixelMap: this.chooseImage
    };
    let textConfiguration: textRecognition.TextRecognitionConfiguration = {
      isDirectionDetectionSupported: false
    };
    // Call the OCR API.
    try {
      let recognitionResult = await textRecognition.recognizeText(visionInfo, textConfiguration);
      let recognitionString = recognitionResult.value;
      this.dataValues = recognitionString;
      hilog.info(0x0000, 'OCRDemo', `Succeeded in recognizing text：${recognitionString}`);
    } catch (error) {
      hilog.error(0x0000, 'OCRDemo', "recognizeText error: " + JSON.stringify(error));
    }

    if(this.chooseImage && this.imageSource) {
      this.chooseImage.release();
      this.imageSource.release();
    }
  }
}