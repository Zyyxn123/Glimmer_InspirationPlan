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

import { camera } from '@kit.CameraKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from 'utils';
import OutputManager, { CreateOutputConfig } from './OutputManager';

const TAG = 'CameraManager';

// ✔ 初始化 CameraManager
// ✔ 打开指定相机（前/后摄）
// ✔ 创建 Input、Output（由 OutputManager 管理）
// ✔ 创建并启动相机 Session（PhotoSession 或 VideoSession）
// ✔ 支持对焦、曝光、缩放、闪光灯等操作
// ✔ 运行中动态替换输出（refreshOutput）
// ✔ 资源释放管理（release）
export class CameraManager {
  // cameraManager
  // 系统相机管理器，是 CameraKit 的核心入口。
  //
  // session
  // 一个相机会话（拍照或录像）。
  // Session 是 Input → Output 的实际执行者。
  //
  // cameraInput
  // 摄像头数据输入源（绑定设备）。
  //
  // outputManagers
  // 用于创建输出（Preview、Photo、Video）的工具。
  private cameraManager?: camera.CameraManager;
  session?: camera.PhotoSession | camera.VideoSession;
  private cameraInput?: camera.CameraInput;
  private outputManagers: OutputManager[] = [];

  // 获取系统全局 CameraManager
  //
  // 保留 output 管理器
  //
  // 注册摄像头状态监听器
  constructor(context: Context, outputManagers: OutputManager[]) {
    try {
      // [Start cameraManager]
      this.cameraManager = camera.getCameraManager(context);
      // [End cameraManager]
      this.outputManagers = outputManagers;
      this.addCameraStatusListener();
    } catch (exception) {
      Logger.error(TAG, `constructor failed, code is ${exception.code}, message is ${exception.message}`);
    }
  }

  // 用于监听：
  //
  // 摄像头被占用
  //
  // 摄像头被释放
  //
  // 摄像头断开、异常等
  //
  // 有助于做自动恢复。
  addCameraStatusListener() {
    this.cameraManager?.on('cameraStatus', (err: BusinessError, statusInfo: camera.CameraStatusInfo) => {
      if (err && err.message) {
        Logger.error(TAG, 'cameraStatus with errorMessage = ' + err.message);
        return;
      }
      Logger.info(TAG, `cameraStatusInfo: camera is ${statusInfo.camera.cameraId}, status is ${statusInfo.status}`);
    });
  }

  getCameraManager() {
    return this.cameraManager;
  }

  // 启动相机会话（核心）
  async start(
    xComponentSurfaceId: string,
    cameraPosition: camera.CameraPosition,
    sceneMode: camera.SceneMode,
    getProfile: (cameraOrientation: number) => camera.Profile
  ) {
    try {
      // 选择设备
      const device = this.getCameraDevice(cameraPosition);
      if (!device) {
        return;
      }
      // [Start cameraInput]
      // 创建 CameraInput
      // CameraInput 是相机的输入源
      //
      // open() 表示真正开启相机硬件
      this.cameraInput = this.cameraManager?.createCameraInput(device);
      await this.cameraInput?.open();
      // [End cameraInput]
      // [Start session]
      // 创建 Session
      // Session 是一个“图像处理管道”。
      //
      // sceneMode 可选：
      //
      // PHOTO
      //
      // VIDEO
      //
      // 还有其他如扫描等
      const session = this.cameraManager?.createSession(sceneMode);
      session?.beginConfig();
      session?.addInput(this.cameraInput);
      // [StartExclude session]
      const config: CreateOutputConfig = {
        cameraManager: this.cameraManager,
        device,
        sceneMode,
        profile: getProfile(device.cameraOrientation),
        surfaceId: xComponentSurfaceId
      };
      // [EndExclude session]
      // 支持多个输出，例如：
      //
      // 预览输出
      //
      // 拍照输出
      //
      // 录像输出
      for (const outputManager of this.outputManagers) {
        if (outputManager.isActive) {
          const output = await outputManager.createOutput(config);
          session?.addOutput(output);
        }
      }

      // 此处相机会真正开始：
      //
      // 自动对焦
      //
      // 自动曝光
      //
      // 开始流入帧数据
      await session?.commitConfig();
      await session?.start();
      // [End session]
      this.session = session as (camera.PhotoSession | camera.VideoSession);
      // 确保预览画面正常。
      this.setFocusMode(camera.FocusMode.FOCUS_MODE_AUTO);
      this.setExposureMode(camera.ExposureMode.EXPOSURE_MODE_AUTO);
    } catch (e) {
      Logger.error(TAG, `Failed to start camera session. Cause ${JSON.stringify(e)}`);
    }
  }

  // 动态替换输出
  //
  // 适用于例如切换照片分辨率、切换预览质量
  async refreshOutput(oldOutput: camera.CameraOutput, newOutput: camera.CameraOutput) {
    try {
      await this.session?.stop();
      this.session?.beginConfig();
      this.session?.removeOutput(oldOutput);
      this.session?.addOutput(newOutput);
      await this.session?.commitConfig();
      await this.session?.start();
    } catch (exception) {
      Logger.error(TAG, `refreshOutput failed, code is ${exception.code}, message is ${exception.message}`);
    }
  }

  // [Start release]
  // 完整释放资源
  // 释放顺序非常正确：
  //
  // 停止 Session
  //
  // 回收 output
  //
  // 关闭 camera input
  //
  // 释放 session
  async release() {
    try {
      await this.session?.stop();
      for (const outputManager of this.outputManagers) {
        if (outputManager.isActive) {
          await outputManager.release();
        }
      }
      await this.cameraInput?.close();
      await this.session?.release();
    } catch (exception) {
      Logger.error(TAG, `release failed, code is ${exception.code}, message is ${exception.message}`);
    }
  }

  // [End release]

  // [Start getCameraDevice]
  // 从系统查询设备
  getCameraDevice(cameraPosition: camera.CameraPosition) {
    const cameraDevices = this.cameraManager?.getSupportedCameras();
    if (!cameraDevices) {
      Logger.error(TAG, `Failed to get camera device. cameraPosition: ${cameraPosition}}`);
      return;
    }
    const device = cameraDevices?.find(device => device.cameraPosition === cameraPosition) || cameraDevices[0];
    if (!device) {
      Logger.error(TAG, `Failed to get camera device. cameraPosition: ${cameraPosition}}`);
    }
    return device;
  }

  // [End getCameraDevice]

  // [Start getZoomRange]
  // 返回一个 [min, max]
  getZoomRange() {
    try {
      return this.session!.getZoomRatioRange();
    } catch (exception) {
      Logger.error(TAG, `getZoomRange failed, code is ${exception.code}, message is ${exception.message}`);
      return [];
    }
  }

  // [End getZoomRange]

  // [Start setFocusMode]
  setFocusMode(focusMode: camera.FocusMode) {
    try {
      const isSupported = this.session?.isFocusModeSupported(focusMode);
      if (!isSupported) {
        Logger.error(TAG, `setFocusMode error: focus mode ${focusMode} is not supported`);
        return;
      }
      this.session?.setFocusMode(focusMode);
    } catch (e) {
      Logger.error(TAG, 'setFocusMode error ' + JSON.stringify(e));
    }
  }

  // [End setFocusMode]

  // [Start setFocusPoint]
  // 坐标通常是 (0 ~ 1) 的归一化区域。
  setFocusPoint(point: camera.Point) {
    try {
      this.session?.setFocusPoint(point);
    } catch (e) {
      Logger.error(TAG, 'setFocusPoint error ' + JSON.stringify(e));
    }
  }

  // [End setFocusPoint]

  // [Start setExposureMode]
  setExposureMode(exposureMode: camera.ExposureMode) {
    try {
      const isSupported = this.session?.isExposureModeSupported(exposureMode);
      if (!isSupported) {
        Logger.error(TAG, `setExposureMode error: focus mode ${exposureMode} is not supported`);
        return;
      }
      this.session?.setExposureMode(exposureMode);
    } catch (e) {
      Logger.error(TAG, 'setExposureMode error ' + JSON.stringify(e));
    }
  }

  // [End setExposureMode]

  // [Start setMeteringPoint]
  // 用于测光（曝光）。
  setMeteringPoint(point: camera.Point) {
    try {
      this.session?.setMeteringPoint(point);
    } catch (e) {
      Logger.error(TAG, 'setMeteringPoint error ' + JSON.stringify(e));
    }
  }

  // [End setMeteringPoint]

  // 普通缩放与平滑缩放。
  setZoomRatio(zoom: number) {
    try {
      this.session?.setZoomRatio(zoom);
    } catch (e) {
      Logger.error(TAG, 'setZoomRatio error ' + JSON.stringify(e));
    }
  }

  // [Start setSmoothZoom]
  setSmoothZoom(zoom: number) {
    try {
      this.session?.setSmoothZoom(zoom);
    } catch (e) {
      Logger.error(TAG, 'setSmoothZoom error ' + JSON.stringify(e));
    }
  }

  // [End setSmoothZoom]

  // [Start setFlashMode]
  // 自动判断闪光灯能力。
  setFlashMode(flashMode: camera.FlashMode) {
    try {
      const isSupported = this.session?.isFlashModeSupported(flashMode);
      if (!isSupported) {
        Logger.error(TAG, `setFlashMode error: flash mode ${flashMode} is not supported`);
        return;
      }
      this.session?.setFlashMode(flashMode);
    } catch (e) {
      Logger.error(TAG, 'setFlashMode error ' + JSON.stringify(e));
    }
  }

  // [End setFlashMode]
  // 摄像头防抖，仅 VideoSession 支持。
  setVideoStabilizationMode(stabilizationMode: camera.VideoStabilizationMode) {
    try {
      const session = this.session as camera.VideoSession;
      const isSupported: boolean = session.isVideoStabilizationModeSupported(stabilizationMode);
      if (isSupported) {
        session.setVideoStabilizationMode(stabilizationMode);
      } else {
        Logger.error(TAG, 'stabilizationMode is not supported: ' + JSON.stringify(stabilizationMode));
      }
    } catch (e) {
      Logger.error(TAG, 'setVideoStabilizationMode error ' + JSON.stringify(e));
    }
  }
}