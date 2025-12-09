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

import { curves, display } from '@kit.ArkUI';
import { camera } from '@kit.CameraKit';
import WindowUtil from '../utils/WindowUtil';
import CameraConstant from '../constants/Constants';
import { Logger } from 'utils';

export enum CameraMode {
  PHOTO,
  VIDEO
}

const TAG = 'PreviewViewModel';

/**
 * States and methods related to preview.
 */
// 管理预览尺寸 / 模式（照片/视频）/ 前后摄切换等状态；
//
// 提供用于 UI（XComponent）布局的宽高、top margin、旋转/模糊等值；
//
// 提供相机预览需要的 camera.Profile（分辨率/格式）；
//
// 封装了打开/关闭/旋转模糊效果的动画逻辑。
class PreviewViewModel {
  // uiContext: UIContext：保存 UI 上下文实例（通常用于 px/vp 转换等 UI 布局相关计算）。
  //
  // isFront: boolean：当前摄像头是否为前置（true 表示前置）。
  //
  // cameraMode: CameraMode：当前是拍照（PHOTO）还是录像（VIDEO）。
  //
  // xComponentController: XComponentController：控制 XComponent（native surface）的控制器，
  // 供外部获取 surfaceId、设置 surface rect、锁旋转等。
  //
  // surfaceId: string：XComponent 提供的 surface id，摄像头渲染会绑定到该 surface。
  //
  // previewSize: Size：当前预览的像素尺寸（宽高），初始值取自 WindowUtil.getMaxDisplaySize(RATIO_PHOTO)。
  //
  // rates?: number[]：可选的帧率或速率数组（命名上可表示相机支持的 FPS 或录像速率）。
  //
  // currentRate: number：当前选中的帧率索引或实际速率值（视项目约定）。
  //
  // blurRadius: number：用于 UI 上的模糊半径（用于变换效果）。
  //
  // blurRotation: RotateOptions：模糊图层的旋转（对象形如 { y: 0.5, angle: 0 }），用于动画视觉效果。
  private uiContext: UIContext;
  // [Start isFront]
  isFront: boolean = false;
  // [StartExclude isFront]
  cameraMode: CameraMode = CameraMode.PHOTO;
  xComponentController: XComponentController = new XComponentController();
  surfaceId: string = '';
  previewSize: Size = WindowUtil.getMaxDisplaySize(CameraConstant.RATIO_PHOTO);
  rates?: number[] = [];
  currentRate: number = 0;
  blurRadius: number = 0;
  blurRotation: RotateOptions = { y: 0.5, angle: 0 };

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext;
  }

  // [EndExclude isFront]
  // 返回 camera API 所需的枚举，表示前/后摄像头位置。
  getCameraPosition() {
    return this.isFront
      ? camera.CameraPosition.CAMERA_POSITION_FRONT
      : camera.CameraPosition.CAMERA_POSITION_BACK;
  }

  // [End isFront]
  // 根据当前模式返回预览长宽比（用于计算 preview size）。
  getPreviewRatio() {
    return this.cameraMode === CameraMode.PHOTO
      ? CameraConstant.RATIO_PHOTO
      : CameraConstant.RATIO_VIDEO;
  }

  // 返回 CameraKit 所期望的场景模式（拍照/录像）
  getSceneMode() {
    return this.cameraMode === CameraMode.PHOTO
      ? camera.SceneMode.NORMAL_PHOTO
      : camera.SceneMode.NORMAL_VIDEO;
  }

  // [Start getProfile]
  // 该方法根据 cameraOrientation（相机报告的方向）以及设备屏幕的 display.rotation（以 0..3 表示的旋转，
  // 乘 90 得到度数）来判断是否需要“反转”（isRevert）。
  //
  // isRevert 用来决定在 camera.Profile.size 中把 width 和 height 互换，
  // 这对于横竖屏与相机传感器方向对齐很关键。
  //
  // format 固定为 CAMERA_FORMAT_YUV_420_SP（YUV420 半平面格式），
  // 是常见的相机预览格式，供 CameraKit 输出。
  //
  // size 使用 WindowUtil.getMaxDisplaySize（基于当前预览比率）计算的 displaySize，
  // 如果 isRevert 则高/宽互换。
  //
  // try/catch：对 display.getDefaultDisplaySync() 做保护，避免在某些环境下抛异常导致整个方法崩溃；
  // 如果出错，记录日志并退回 rotation = 0。
  getProfile: (cameraOrientation: number) => camera.Profile = cameraOrientation => {
    const displaySize: Size = WindowUtil.getMaxDisplaySize(this.getPreviewRatio());
    let displayDefault: display.Display | null = null;
    try {
      // 获取当前默认的Display对象。
      displayDefault = display.getDefaultDisplaySync();
    } catch (exception) {
      Logger.error(TAG, `getDefaultDisplaySync failed, code is ${exception.code}, message is ${exception.message}`);
    }
    const displayRotation = (displayDefault?.rotation ?? 0) * 90;
    const isRevert = (cameraOrientation + displayRotation) % 180 !== 0;
    return {
      format: camera.CameraFormat.CAMERA_FORMAT_YUV_420_SP,
      size: {
        height: isRevert ? displaySize.width : displaySize.height,
        width: isRevert ? displaySize.height : displaySize.width
      }
    };
  }

  // [End getProfile]

  // [Start setPreviewSize]
  // 重新计算 previewSize（像素）并把尺寸通过 xComponentController.setXComponentSurfaceRect() 通知 XComponent，
  // 这样 native surface 的渲染尺寸与 UI 保持一致。
  //
  // 需要在设备旋转或模式变化（photo/video）时调用。
  setPreviewSize() {
    const displaySize: Size = WindowUtil.getMaxDisplaySize(this.getPreviewRatio());
    this.previewSize = displaySize;
    this.xComponentController.setXComponentSurfaceRect({
      surfaceWidth: displaySize.width,
      surfaceHeight: displaySize.height
    });
  }

  // [End setPreviewSize]
  // 根据窗口宽高比与预览比对比决定 top margin（若窗口相对更宽，预览可能垂直居中并留出顶部避让区，值为 85，否则 0）。
  // 85 是像素/VP值（项目约定），用于适配状态栏或工具栏。
  getPreviewTop() {
    const previewRatio = this.getPreviewRatio();
    return WindowUtil.getWindowRatio() > previewRatio ? 85 : 0;
  }

  // 将内部 previewSize（像素）转换为 UI 所需的 VP（视口单位），用于 Stack().width(...) / height(...) 设置。
  getPreviewWidth() {
    return this.uiContext.px2vp(this.previewSize.width);
  }

  getPreviewHeight() {
    return this.uiContext.px2vp(this.previewSize.height);
  }

  // 简单布尔封装，便于 UI 层或控制逻辑读取当前模式。
  isPhotoMode() {
    return this.cameraMode === CameraMode.PHOTO;
  }

  isVideoMode() {
    return this.cameraMode === CameraMode.VIDEO;
  }

  isCurrentCameraMode(mode: CameraMode) {
    return this.cameraMode === mode;
  }

  // 立即启动动画（200ms），把模糊半径设置为 150，产生明显的模糊层（用于进入某些页面转场、切换等场景）。
  openPreviewBlur() {
    animateToImmediately({
      duration: 200,
      curve: Curve.Friction
    }, () => {
      this.blurRadius = 150;
    });
  }

  // 分两阶段做旋转动画：先设置 angle 到 90°（并在完成时调用第二段），
  // 第二段首先直接把角度置为 270°（可能是为了视觉上的“瞬移”效果），
  // 然后再做 200ms 动画回到 360°（随后在 onFinish 重置为 angle: 0），形成平滑的旋转循环或回退效果。
  //
  // y: 0.5 可能表示旋转轴在垂直中间（关于 RotateOptions 的含义需参照 ArkUI 文档）。
  rotatePreviewBlur() {
    animateToImmediately({
      delay: 50,
      duration: 200,
      curve: curves.cubicBezierCurve(0.2, 0, 0.83, 1),
      onFinish: () => {
        this.rotatePreviewBlurSecond();
      }
    }, () => {
      this.blurRotation = { y: 0.5, angle: 90 };
    });
  }

  rotatePreviewBlurSecond() {
    this.blurRotation = { y: 0.5, angle: 270 };
    animateToImmediately({
      duration: 200,
      curve: curves.cubicBezierCurve(0.17, 0, 0.2, 1),
      onFinish: () => {
        this.blurRotation = { y: 0.5, angle: 0 };
      }
    }, () => {
      this.blurRotation = { y: 0.5, angle: 360 };
    });
  }

  // 将模糊半径动画回到 0，移除模糊效果。
  closePreviewBlur() {
    animateToImmediately({
      duration: 200,
      curve: Curve.FastOutSlowIn
    }, () => {
      this.blurRadius = 0;
    });
  }
}

export default PreviewViewModel;