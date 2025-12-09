/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { image } from '@kit.ImageKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AVRecorderState, CameraManager, PhotoManager, VideoManager } from 'camera';
import PreviewViewModel from '../viewmodels/PreviewViewModel';
import { Logger } from 'utils';

const TAG = 'OperateButtonsView';

// ⭐ 拍照按钮（支持倒计时）
// ⭐ 录制视频（开始、暂停、恢复、停止）
// ⭐ 缩略图按钮（进入相册）
// ⭐ 切换前后摄像头
// ⭐ 缩略图回调处理
// ⭐ 操作状态与按钮样式随状态变化更新
@Component
struct OperateButtonsView {
  // isDelayTakePhoto	Link	是否正在倒计时拍照
  // previewVM	Link	预览层 ViewModel，管理摄像头方向等
  // cameraManager	Require	负责开启/重启摄像头 session
  // videoManager	Link	视频录制管理器，状态变化实时更新 UI
  // photoManager	Require	拍照逻辑管理器
  // photoDelayTime	Prop	设置的倒计时时长（例如 3s, 5s）
  // photoRemainder	Link	剩余倒计时数值，UI 会显示
  // thumbnail	State	缩略图 pixelMap
  // thumbnailUrl	State	缩略图实际的保存地址
  // syncButtonSettings	Require	切换状态后同步 UI，例如切换摄像头
  // captureClickFlag	StorageLink	全局存储的拍照次数计数（用于外部监听）
  @Link isDelayTakePhoto: boolean;
  @Link previewVM: PreviewViewModel;
  @Require cameraManager: CameraManager;
  @Link videoManager: VideoManager; // Do not use @prop, otherwise deep copying, some underlying data will be lost.
  @Require photoManager: PhotoManager;
  @Prop @Require photoDelayTime: number;
  @Link photoRemainder: number;
  private photoDelayTimer: number = 0;
  @State thumbnail: image.PixelMap | string = '';
  @State thumbnailUrl: string = '';
  @Require syncButtonSettings: () => void;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private setThumbnail: (pixelMap: image.PixelMap, url: string) => void = (pixelMap: image.PixelMap, url: string) => {
    this.thumbnail = pixelMap
    this.thumbnailUrl = url
  }
  @StorageLink('captureClick') captureClickFlag: number = 0;

  // 注册 拍照/视频生成缩略图的回调：
  //
  // 拍照完成后触发
  //
  // 视频录制停止后触发
  aboutToAppear(): void {
    this.photoManager.setCallback(this.setThumbnail);
    this.videoManager.setVideoCallback(this.setThumbnail);
  }

  // 显示倒计时
  //
  // 倒计时结束自动拍照
  @Builder
  photoButton() {
    Column() {
      Column()
        .width(48)
        .height(48)
        .borderRadius('50%')
        .border({
          color: Color.White,
          width: 24
        })
    }
    .width(64)
    .height(64)
    .borderRadius('50%')
    .border({
      color: Color.White,
      width: 1
    })
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      if (this.photoDelayTime) {
        this.isDelayTakePhoto = true;
        this.photoRemainder = this.photoDelayTime;
        this.photoDelayTimer = setInterval(() => {
          this.photoRemainder--;
          if (this.photoRemainder === 0) {
            this.photoManager.capture(this.previewVM.isFront);
            this.captureClickFlag++;
            this.isDelayTakePhoto = false;
            clearTimeout(this.photoDelayTimer);
          }
        }, 1000)
      } else {
        this.photoManager.capture(this.previewVM.isFront);
        this.captureClickFlag++;
      }
    })
  }

  // 前置时开启镜像
  //
  // 根据方向传入旋转角
  //
  // 开始录制
  @Builder
  videoStartButton() {
    Column() {
      Column()
        .width(52)
        .height(52)
        .backgroundColor(Color.Red)
        .borderRadius('50%')
        .border({
          color: Color.White,
          width: 8
        })
    }
    .width(64)
    .height(64)
    .borderRadius('50%')
    .border({
      color: Color.White,
      width: 1
    })
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.videoManager.start(this.previewVM.isFront);
    })
  }

  @Builder
  videoStopButton() {
    Column() {
      Column()
        .width(28)
        .height(28)
        .borderRadius(10)
        .backgroundColor(Color.Red)
    }
    .width(64)
    .height(64)
    .borderRadius('50%')
    .border({
      color: Color.White,
      width: 1
    })
    .justifyContent(FlexAlign.Center)
    .onClick(async () => {
      // await this.videoManager.stop();       // 结束录制并生成缩略图
      // await this.cameraManager.release();   // 释放摄像头
      // await this.cameraManager.start(...);  // 恢复预览
      // this.syncButtonSettings();            // 重置按钮状态
      if (this.videoManager.state === AVRecorderState.STARTED || this.videoManager.state === AVRecorderState.PAUSED) {
        await this.videoManager.stop();
        await this.cameraManager.release();
        const cameraPosition = this.previewVM.getCameraPosition();
        const sceneMode = this.previewVM.getSceneMode();
        await this.cameraManager.start(this.previewVM.surfaceId, cameraPosition, sceneMode, this.previewVM.getProfile);
        this.syncButtonSettings();
      }
    })
  }

  // 录制状态：
  //
  // STARTED → 可暂停
  //
  // PAUSED → 可继续
  //
  // UI 根据状态自动切换按钮。
  @Builder
  videoPauseButton() {
    SymbolGlyph($r('sys.symbol.pause'))
      .fontColor([Color.White])
      .fontSize(22)
      .fontWeight(FontWeight.Bolder)
      .padding(11)
      .borderWidth(1)
      .borderColor(Color.White)
      .borderRadius('50%')
      .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), true)
      .onClick(async () => {
        this.videoManager.pause();
      })
  }

  @Builder
  videoResumeButton() {
    SymbolGlyph($r('sys.symbol.play'))
      .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
      .fontColor([Color.White])
      .fontSize(22)
      .padding(11)
      .borderWidth(1)
      .borderColor(Color.White)
      .borderRadius('50%')
      .onClick(async () => {
        this.videoManager.resume();
      })
  }

  // 缩略图按钮（打开系统相册查看）
  @Builder
  thumbnailButton() {
    Image(this.thumbnail)
      .width(48)
      .height(48)
      .borderRadius('50%')
      .borderWidth(this.thumbnail ? 1 : 0)
      .borderColor(Color.White)
      .clip(true)
      .onClick(() => {
        if (this.thumbnailUrl) {
          this.context.startAbility({
            parameters: { uri: this.thumbnailUrl },
            action: 'ohos.want.action.viewData',
            bundleName: 'com.huawei.hmos.photos',
            abilityName: 'com.huawei.hmos.photos.MainAbility'
          }).catch((err: BusinessError) => {
            Logger.error(TAG, `showToast failed, code is ${err.code}, message is ${err.message}`);
          });
        }
      })
  }

  // 倒计时取消按钮
  @Builder
  delayTakePhotoCancelButton() {
    SymbolGlyph($r('sys.symbol.pause'))
      .fontColor([Color.White])
      .fontSize(22)
      .fontWeight(FontWeight.Bolder)
      .padding(11)
      .borderWidth(1)
      .borderColor(Color.White)
      .borderRadius('50%')
      .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), true)
      .onClick(async () => {
        this.isDelayTakePhoto = false;
        clearTimeout(this.photoDelayTimer);
        this.photoRemainder = 0;
      })
  }

  // [Start toggleCameraPositionButton]
  // 切换摄像头按钮（前置 / 后置）
  @Builder
  toggleCameraPositionButton() {
    Image($r('app.media.toggle_position'))
      .width(48)
      .height(48)
      .onClick(async () => {
        // [StartExclude toggleCameraPositionButton]
        this.previewVM.openPreviewBlur();
        this.previewVM.rotatePreviewBlur();
        // [EndExclude toggleCameraPositionButton]
        this.previewVM.isFront = !this.previewVM.isFront;
        const cameraPosition = this.previewVM.getCameraPosition();
        const sceneMode = this.previewVM.getSceneMode();
        await this.cameraManager.release();
        await this.cameraManager.start(this.previewVM.surfaceId, cameraPosition, sceneMode, this.previewVM.getProfile);
        // [StartExclude toggleCameraPositionButton]
        this.syncButtonSettings();
        // [EndExclude toggleCameraPositionButton]
      })
  }

  // [End toggleCameraPositionButton]

  build() {
    Row() {
      this.thumbnailButton()
      if (this.previewVM.isPhotoMode()) {
        this.photoButton()
      } else {
        if (this.videoManager.isRecording()) {
          this.videoStopButton()
        } else {
          this.videoStartButton()
        }
      }
      if (!this.videoManager.isRecording()) {
        this.toggleCameraPositionButton()
      }
      if (this.previewVM.isVideoMode() && this.videoManager.state === AVRecorderState.STARTED) {
        this.videoPauseButton()
      } else if (this.previewVM.isVideoMode() && this.videoManager.state === AVRecorderState.PAUSED) {
        this.videoResumeButton()
      }
    }
    .justifyContent(FlexAlign.SpaceAround)
    .id('operateButtonsView')
    .alignRules({
      bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
      middle: { anchor: '__container__', align: HorizontalAlign.Center },
    })
    .margin({ bottom: 90 })
    .width('90%')
  }
}

export default OperateButtonsView;