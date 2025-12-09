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

import { CameraManager, PhotoManager, VideoManager } from 'camera';
import PreviewViewModel, { CameraMode } from '../viewmodels/PreviewViewModel';

export interface CameraModeButton {
  title: ResourceStr;
  mode: CameraMode;
  onClick?: () => void;
}

@Component
struct ModeButtonsView {
  private cameraModeButtons: CameraModeButton[] = [
    {
      title: $r('app.string.photo'),
      mode: CameraMode.PHOTO
    },
    {
      title: $r('app.string.video'),
      mode: CameraMode.VIDEO
    }
  ]
  @Link previewVM: PreviewViewModel; // Do not use @prop, otherwise deep copying, some underlying data will be lost.
  // 这些参数都是业务逻辑层：
  //
  // cameraManager → 控制 CameraKit 管线启动和关闭
  //
  // photoManager → 控制拍照
  //
  // videoManager → 控制视频录制
  //
  // syncButtonSettings → 切换模式后同步一些配置
  @Require cameraManager: CameraManager;
  @Require photoManager: PhotoManager;
  @Require videoManager: VideoManager;
  @Require syncButtonSettings: () => void;

  build() {
    Row() {
      ForEach(this.cameraModeButtons, (modeBtn: CameraModeButton) => {
        Text(modeBtn.title)
          .fontColor(Color.White)
          .fontSize(14)
          .fontWeight(this.previewVM.isCurrentCameraMode(modeBtn.mode) ? FontWeight.Bold : FontWeight.Normal)
          .onClick(async () => {
            if (modeBtn.onClick) {
              modeBtn.onClick();
            } else {
              if (this.previewVM.isCurrentCameraMode(modeBtn.mode)) {
                return;
              }
              this.previewVM.openPreviewBlur();
              this.previewVM.cameraMode = modeBtn.mode;
              // 切换模式值
              this.previewVM.setPreviewSize();
              // 获取新模式下的 sceneMode 和 cameraPosition
              const sceneMode = this.previewVM.getSceneMode();
              const cameraPosition = this.previewVM.getCameraPosition();
              // CameraKit 不允许不释放直接切换，否则：
              //
              // 会报错“pipeline already running”
              //
              // Surface 不释放导致资源泄漏
              //
              // Profile 无法更新
              //
              // 这一步是关键！
              await this.cameraManager.release();
              // 激活正确的 Output 管理器
              this.photoManager.setIsActive(this.previewVM.isPhotoMode() ? true : false);
              this.videoManager.setIsActive(this.previewVM.isPhotoMode() ? false : true);
              // 启动 Camera 管线（新的模式）
              await this.cameraManager.start(this.previewVM.surfaceId, cameraPosition, sceneMode, this.previewVM.getProfile);
              this.syncButtonSettings();
            }
          })
      }, (modeBtn: CameraModeButton) => modeBtn.mode.toString())
    }
    .id('modeButtonsView')
    .width('40%')
    .justifyContent(FlexAlign.SpaceAround)
    .alignRules({
      bottom: { anchor: 'operateButtonsView', align: VerticalAlign.Top },
      middle: { anchor: 'operateButtonsView', align: HorizontalAlign.Center }
    })
    .margin({ bottom: 40 })
  }
}

export default ModeButtonsView;
// 用户点击 Photo / Video 按钮
//         ↓
// 检查是否需要切换模式
//         ↓
// UI 添加模糊动画
//         ↓
// 修改 PreviewViewModel 的模式
//         ↓
// 重新设置预览尺寸
//         ↓
// 获得 sceneMode 和 cameraPosition
//         ↓
// 关闭 Camera 管线 (release)
//         ↓
// 激活 photoManager 或 videoManager
//         ↓
// 启动 Camera 管线 (start)
//         ↓
// 根据模式同步设置（帧率、LivePhoto 等）