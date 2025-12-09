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
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { sensor } from '@kit.SensorServiceKit';
import { Decimal } from '@kit.ArkTS';
import { image } from '@kit.ImageKit';
import { colorSpaceManager } from '@kit.ArkGraphics2D';
import { geoLocationManager } from '@kit.LocationKit';
import { Logger } from 'utils';
import OutputManager, { CreateOutputConfig } from './OutputManager';
import CameraConstant from '../constants/CameraConstants';

const TAG_LOG = 'PhotoManager';

// 根据 camera 管理器与 profile 创建 PhotoOutput（createOutput / createPhotoOutput）。
//
// 为 PhotoOutput 注册回调（两种模式：single / double），收到照片后保存到媒体库并把 PixelMap 回传给 UI。
//
// 在拍照前为 PhotoSession 配置闪光灯、对焦点、色彩空间、缩放等
// （preparePhoto、setPhotoFlash、setPhotoFocus、setPhotoZoomRatio、setColorSpaceBeforeCommitConfig）。
//
// 通过传感器计算设备朝向以决定照片旋转
// （capture → getPhotoDegree → calculateDeviceDegree → getPhotoRotation）。
//
// 查询并控制“moving photo”等相机能力（isMovingPhotoSupported、enableMovingPhoto）。
//
// 负责释放输出资源（release）。
//
// 它是 OutputManager 的实现（用于管理相机输出的一种策略类），把相机输出与媒体库保存、图像转换串成一条完整流水线。
export class PhotoManager implements OutputManager {
  // isSingle：决定回调模式：
  //
  // true：使用 photoAvailable（直接返回 camera.Photo 对象），
  // 代码中使用 setPhotoOutputCbSingle。
  //
  // false：使用 photoAssetAvailable（返回 PhotoAsset，通常代表已保存到媒体库的资源），
  // 代码中使用 setPhotoOutputCbDouble。
  //
  // context：用于访问媒体库（PhotoAccessHelper）、传感器、文件读写等，
  // 需要有对应权限（存储/媒体、定位若嵌入 metadata）。
  output?: camera.PhotoOutput;            // 当前 PhotoOutput 实例
  isActive: boolean = true;               // PhotoManager 是否启用
  context: Context;                       // Ability/AbilityContext，供媒体库、传感器等使用
  isSingle: boolean = false;              // 使用单回调(photoAvailable)还是双回调(photoAssetAvailable)
  location: geoLocationManager.Location | null = null; // 可选的位置信息，用于 metadata（当前未使用）
  private callback: (pixelMap: image.PixelMap, url: string) => void = () => {}; // UI 回调：当 PixelMap 可用时调用


  constructor(context: Context, isActive = true, isSingle: boolean) {
    this.context = context;
    this.isActive = isActive;
    this.isSingle = isSingle;
  }

  setIsActive(isActive: boolean) {
    this.isActive = isActive;
  }

  setCallback(callback: (pixelMap: image.PixelMap, url: string) => void) {
    this.callback = callback;
  }


  // createOutput(config) 会调用 createPhotoOutput(cameraManager, device, profile)
  // 返回 camera.PhotoOutput。
  //
  // 如果成功，保存到 this.output 并调用 setPhotoOutputCallback(this.isSingle) 注册回调。
  //
  // createPhotoOutput 关键逻辑：
  //
  // 通过 cameraManager.getSupportedOutputCapability
  // (cameraDevice, camera.SceneMode.NORMAL_PHOTO) 获取设备对 photo 输出的能力对象（包含可用的 photoProfiles）。
  //
  // 根据传入 profile（通常来自 preview 的 profile）计算 displayRatio 与
  // profileWidth，从 photoProfilesArray 中：
  //
  // 先按与目标 width 的差值排序（选择最接近的宽度）。
  //
  // 再 .find(pf => Math.abs(pfDisplayRatio - displayRatio) <= CameraConstant.PROFILE_DIFFERENCE &&
  // pf.format === camera.CameraFormat.CAMERA_FORMAT_JPEG) 选择格式为 JPEG 且比例接近的 profile。
  //
  // 选到合适 photoProfile 后调用 cameraManager.createPhotoOutput(photoProfile) 创建实际输出。
  async createOutput(config: CreateOutputConfig) {
    let cameraPhotoOutput: camera.PhotoOutput | undefined = undefined;
    cameraPhotoOutput = this.createPhotoOutput(config.cameraManager, config.device, config.profile);
    if (cameraPhotoOutput) {
      this.output = cameraPhotoOutput;
      this.setPhotoOutputCallback(this.isSingle);
    }
    return cameraPhotoOutput;
  }

  // [Start create_photo_output]
  // Create photo output
  public createPhotoOutput(cameraManager: camera.CameraManager|undefined, cameraDevice: camera.CameraDevice,
    profile: camera.Profile) {
    let cameraPhotoOutput: camera.PhotoOutput | undefined = undefined;
    const cameraOutputCapability =
      cameraManager?.getSupportedOutputCapability(cameraDevice, camera.SceneMode.NORMAL_PHOTO);
    let photoProfilesArray: camera.Profile[] | undefined = cameraOutputCapability?.photoProfiles;
    if (photoProfilesArray?.length) {
      try {
        const displayRatio = profile.size.width / profile.size.height;
        const profileWidth = profile.size.width;
        const photoProfile = photoProfilesArray
          .sort((a, b) => Math.abs(a.size.width - profileWidth) - Math.abs(b.size.width - profileWidth))
          .find(pf => {
            const pfDisplayRatio = pf.size.width / pf.size.height;
            return Math.abs(pfDisplayRatio - displayRatio) <= CameraConstant.PROFILE_DIFFERENCE &&
              pf.format === camera.CameraFormat.CAMERA_FORMAT_JPEG;
          });
        if (!photoProfile) {
          Logger.error(TAG_LOG, 'Failed to get photo profile');
          return;
        }
        cameraPhotoOutput = cameraManager?.createPhotoOutput(photoProfile);
      } catch (error) {
        Logger.error(TAG_LOG, `Failed to createPhotoOutput. error: ${JSON.stringify(error)}`);
      }
    }
    this.output = cameraPhotoOutput;
    return cameraPhotoOutput;
  }

  // [End create_photo_output]

  // [Start set_photo_cb_double]
  // Save camera photo
  async mediaLibSavePhoto(photoAsset: photoAccessHelper.PhotoAsset,
    phAccessHelper: photoAccessHelper.PhotoAccessHelper): Promise<void> {
    try {
      let assetChangeRequest: photoAccessHelper.MediaAssetChangeRequest =
        new photoAccessHelper.MediaAssetChangeRequest(photoAsset);
      assetChangeRequest.saveCameraPhoto();
      await phAccessHelper.applyChanges(assetChangeRequest);
      phAccessHelper.release();
    } catch (error) {
      Logger.error(TAG_LOG, `apply saveCameraPhoto failed with error: ${error.code}, ${error.message}`);
    }
  }

  async mediaLibRequestBuffer(photoAsset: photoAccessHelper.PhotoAsset, context: Context,
    callback: (pixelMap: image.PixelMap, url: string) => void) {
    class MediaDataHandler implements photoAccessHelper.MediaAssetDataHandler<ArrayBuffer> {
      onDataPrepared(data: ArrayBuffer) {
        if (data === undefined) {
          Logger.error(TAG_LOG, 'Error occurred when preparing data');
          return;
        }
        let imageSource = image.createImageSource(data);
        imageSource.createPixelMap().then((pixelMap: image.PixelMap) => {
          callback(pixelMap, photoAsset.uri);
        }).catch((err: BusinessError) => {
          Logger.error(TAG_LOG, `createPixelMap err:${err.code}`);
        })
      }
    }

    let requestOptions: photoAccessHelper.RequestOptions = {
      deliveryMode: photoAccessHelper.DeliveryMode.FAST_MODE,
    }
    const handler = new MediaDataHandler();
    try {
      await photoAccessHelper.MediaAssetManager.requestImageData(context, photoAsset, requestOptions, handler);
    } catch (exception) {
      Logger.error(TAG_LOG, `requestImageData failed, code is ${exception.code}, message is ${exception.message}`);
    }
  }

  // setPhotoOutputCbDouble(cameraPhotoOutput)：
  //
  // 监听 photoAssetAvailable 事件，回调签名 (err, photoAsset)。
  //
  // 在回调中：
  //
  // accessHelper = photoAccessHelper.getPhotoAccessHelper(this.context) 获取媒体库 helper。
  //
  // this.mediaLibSavePhoto(photoAsset, accessHelper)：调用保存（内部使用 assetChangeRequest.saveCameraPhoto() → applyChanges）。
  //
  // this.mediaLibRequestBuffer(photoAsset, this.context, this.callback)：请求图片数据，再把 PixelMap 和 photoAsset.uri 传给 this.callback（UI 层）。
  //
  // mediaLibRequestBuffer 细节：
  //
  // 实现了 MediaAssetDataHandler 的 onDataPrepared(data: ArrayBuffer)，把 ArrayBuffer 用 image.createImageSource(data)，再 createPixelMap() 得到异步 PixelMap，最后 callback(pixelMap, uri)。
  //
  // 使用 DeliveryMode.FAST_MODE 请求数据（优先快速回传），如果需要高质量可使用不同模式。
  public setPhotoOutputCbDouble(cameraPhotoOutput: camera.PhotoOutput) {
    cameraPhotoOutput.on('photoAssetAvailable',
      async (_err: BusinessError, photoAsset: photoAccessHelper.PhotoAsset): Promise<void> => {
        let accessHelper: photoAccessHelper.PhotoAccessHelper =
          photoAccessHelper.getPhotoAccessHelper(this.context);
        this.mediaLibSavePhoto(photoAsset, accessHelper);
        this.mediaLibRequestBuffer(photoAsset, this.context, this.callback);
      });
  }

  // [End set_photo_cb_double]

  // [Start set_photo_cb_single]
  // Set photo callback single
  // setPhotoOutputCbSingle(photoOutput, context)：
  //
  // 监听 photoAvailable 事件，回调 (errCode, photo)。
  //
  // 若获取到 photo，调用 mediaLibSavePhotoSingle(context, photo.main) 将 photo.main（image.Image）转为 jpeg buffer 并保存到媒体库，然后 this.callback(pixelmap, uri)。
  //
  // mediaLibSavePhotoSingle 实现要点：
  //
  // 使用 imageObj.getComponent(image.ComponentType.JPEG, (errCode, component) => { const buffer = component.byteBuffer; ... } ) 获取 JPEG bytes。
  //
  // 使用 photoAccessHelper.MediaAssetChangeRequest.createAssetRequest(context, photoType, extension, options) 创建 asset 请求，addResource 添加 buffer，saveCameraPhoto() 并 applyChanges。
  //
  // 保存完成后用 image.createImageSource(buffer).createPixelMapSync() 直接同步得到 PixelMap（注意：createPixelMapSync 可能阻塞，需保证在非 UI 关键路径或改用异步）。
  setPhotoOutputCbSingle(photoOutput: camera.PhotoOutput, context: Context) {
    photoOutput.on('photoAvailable', (errCode: BusinessError, photo: camera.Photo): void => {
      if (errCode || photo === undefined) {
        Logger.error(TAG_LOG, 'getPhoto failed');
        return;
      }
      this.mediaLibSavePhotoSingle(context, photo.main)
    });
  }

  // [End set_photo_cb_single]

  // [Start save_photo_single]
  // Save photo single
  mediaLibSavePhotoSingle(context: Context, imageObj: image.Image) {
    imageObj.getComponent(image.ComponentType.JPEG, async (errCode: BusinessError, component: image.Component) => {
      if (errCode || component === undefined) {
        Logger.error(TAG_LOG, 'getComponent failed');
        return;
      }
      const buffer: ArrayBuffer = component.byteBuffer;
      if (!buffer) {
        Logger.error(TAG_LOG, 'byteBuffer is null');
        return;
      }
      let photoType: photoAccessHelper.PhotoType = photoAccessHelper.PhotoType.IMAGE;
      let extension: string = 'jpg';
      let options: photoAccessHelper.CreateOptions = {
        title: 'testPhoto'
      }
      try {
        let assetChangeRequest: photoAccessHelper.MediaAssetChangeRequest =
          photoAccessHelper.MediaAssetChangeRequest.createAssetRequest(context, photoType, extension, options);
        assetChangeRequest.addResource(photoAccessHelper.ResourceType.IMAGE_RESOURCE, buffer)
        assetChangeRequest.saveCameraPhoto();
        let accessHelper: photoAccessHelper.PhotoAccessHelper =
          photoAccessHelper.getPhotoAccessHelper(context);
        await accessHelper.applyChanges(assetChangeRequest);
        let imageSource = image.createImageSource(buffer);
        let pixelmap = imageSource.createPixelMapSync();
        this.callback(pixelmap, assetChangeRequest.getAsset().uri);
        accessHelper.release();
        imageObj.release();
      } catch (exception) {
        Logger.error(TAG_LOG,
          `mediaLibSavePhotoSingle failed, code is ${exception.code}, message is ${exception.message}`);
      }
    });
  }

  // [End save_photo_single]

  setPhotoOutputCallback(isSingle: boolean) {
    if (!this.output) {
      return;
    }
    if (isSingle) {
      this.output?.off('photoAssetAvailable');
      this.setPhotoOutputCbSingle(this.output, this.context);
    } else {
      this.output?.off('photoAvailable');
      this.setPhotoOutputCbDouble(this.output);
    }
  }

  preparePhoto(session: camera.Session, zoomRatio?: number, flashMode?: camera.FlashMode,
    focusMode?: camera.FocusMode) {
    const photoSession = session as camera.PhotoSession;
    this.setPhotoFlash(photoSession, flashMode);
    this.setPhotoFocus(photoSession, focusMode);
    this.setPhotoZoomRatio(photoSession, zoomRatio || 0);
  }

  // [Start set_color_space]
  // Set color space
  setColorSpaceBeforeCommitConfig(session: camera.PhotoSession, isHdr: boolean): void {
    // The isHdr flag indicates whether HDR mode is enabled, with true representing the use of the DISPLAY_P3 color space.
    let colorSpace: colorSpaceManager.ColorSpace =
      isHdr ? colorSpaceManager.ColorSpace.DISPLAY_P3 : colorSpaceManager.ColorSpace.SRGB;
    let colorSpaces: Array<colorSpaceManager.ColorSpace> = [];
    try {
      colorSpaces = session.getSupportedColorSpaces();
    } catch (error) {
      Logger.error(TAG_LOG, `The getSupportedColorSpaces call failed. error code: ${error.code}`);
    }
    if (!colorSpaces.includes(colorSpace)) {
      Logger.info(TAG_LOG, `colorSpace: ${colorSpace} is not support`);
      return;
    }
    try {
      Logger.info(TAG_LOG, `setColorSpace: ${colorSpace}`);
      session.setColorSpace(colorSpace);
    } catch (exception) {
      Logger.error(TAG_LOG, `setColorSpace failed, code is ${exception.code}, message is ${exception.message}`);
    }
    try {
      let activeColorSpace: colorSpaceManager.ColorSpace = session.getActiveColorSpace();
      Logger.info(TAG_LOG, `activeColorSpace: ${activeColorSpace}`);
    } catch (error) {
      Logger.error(TAG_LOG, `getActiveColorSpace Faild: ${error.message}`);
    }
  }

  // [End set_color_space]

  public checkFlash(photoSession: camera.PhotoSession) {
    let flashModeStatus: boolean = false;
    try {
      if (photoSession.hasFlash()) {
        flashModeStatus = photoSession.isFlashModeSupported(camera.FlashMode.FLASH_MODE_AUTO);
      }
    } catch (exception) {
      Logger.error(TAG_LOG, `checkFlash failed, code is ${exception.code}, message is ${exception.message}`);
    }
    return flashModeStatus;
  }

  public setPhotoFlash(photoSession: camera.PhotoSession, flashMode?: camera.FlashMode) {
    try {
      if (this.checkFlash(photoSession)) {
        photoSession.setFlashMode(flashMode || camera.FlashMode.FLASH_MODE_CLOSE);
      }
    } catch (error) {
      Logger.error(TAG_LOG, `Failed to hasFlash. error: ${JSON.stringify(error)}`);
    }
  }

  public setPhotoFocus(photoSession: camera.PhotoSession, focusMode?: camera.FocusMode) {
    const defaultMode = camera.FocusMode.FOCUS_MODE_CONTINUOUS_AUTO;
    try {
      let focusModeStatus: boolean = photoSession.isFocusModeSupported(focusMode || defaultMode);
      if (focusModeStatus) {
        photoSession.setFocusMode(focusMode || defaultMode);
      }
    } catch (error) {
      Logger.error(TAG_LOG,
        `Failed to check whether the focus mode is supported. error: ${JSON.stringify(error)}`);
    }
  }

  public setFocusPoint(photoSession: camera.PhotoSession, focusPoint: camera.Point): void {
    try {
      photoSession.setFocusPoint(focusPoint);
    } catch (error) {
      Logger.error(TAG_LOG, `The setFocusPoint call failed. error code: ${error.code}`);
    }
  }

  public setPhotoZoomRatio(photoSession: camera.PhotoSession, zoomRatio?: number) {
    let photoZoomRatio = 0;
    if (!zoomRatio) {
      try {
        let zoomRatioRange: number[] = photoSession.getZoomRatioRange();
        if (zoomRatioRange?.length) {
          photoZoomRatio = zoomRatioRange[0];
        }
      } catch (error) {
        Logger.error(TAG_LOG, `Failed to get the zoom ratio range. error: ${JSON.stringify(error)}`);
      }
    }
    try {
      photoSession.setZoomRatio(zoomRatio || photoZoomRatio);
    } catch (exception) {
      Logger.error(TAG_LOG, `setZoomRatio failed, code is ${exception.code}, message is ${exception.message}`);
    }
  }

  getSupportedColorSpaces(session: camera.PhotoSession): Array<colorSpaceManager.ColorSpace> {
    let colorSpaces: Array<colorSpaceManager.ColorSpace> = [];
    try {
      colorSpaces = session.getSupportedColorSpaces();
    } catch (error) {
      Logger.error(TAG_LOG, `The getSupportedColorSpaces call failed. error code: ${error.code}`);
    }
    return colorSpaces;
  }

  // [Start get_photo_rotation]
  // Get photo rotation
  getPhotoRotation(photoOutput: camera.PhotoOutput, deviceDegree: number): camera.ImageRotation {
    let photoRotation: camera.ImageRotation = camera.ImageRotation.ROTATION_0;
    try {
      photoRotation = photoOutput.getPhotoRotation(deviceDegree);
    } catch (error) {
      Logger.error(TAG_LOG, `The photoOutput.getPhotoRotation call failed. error code: ${error.code}`);
    }
    return photoRotation;
  }

  // [End get_photo_rotation]

  // [Start capture_photo]
  // Capture photo
  public async capture(isFront: boolean) {
    const degree = await this.getPhotoDegree();
    const rotation = this.getPhotoRotation(this.output!, degree);
    let settings: camera.PhotoCaptureSetting = {
      quality: camera.QualityLevel.QUALITY_LEVEL_HIGH,
      rotation,
      mirror: isFront
    };
    this.output?.capture(settings, (err: BusinessError) => {
      if (err) {
        Logger.error(TAG_LOG, `Failed to capture the photo. error: ${JSON.stringify(err)}`);
        return;
      }
      Logger.info(TAG_LOG, 'Callback invoked to indicate the photo capture request success.');
    });
  }

  // [End capture_photo]

  private calculateDeviceDegree(x: number, y: number, z: number): number {
    let deviceDegree: number = 0;
    // Determine if the device is approaching a vertical position (perpendicular to the ground)
    if ((x * x + y * y) * 3 < z * z) {
      return deviceDegree;
    } else {
      try {
        // Calculate the inverse tangent value
        let sd: Decimal = Decimal.atan2(y, -x)
        // Convert radian values to angle values;
        let sc: Decimal = Decimal.round(Number(sd) / Math.PI * 180);
        // Adjust angle to be relative to vertical orientation
        deviceDegree = 90 - Number(sc);
        // Normalize angle to 0-360 degrees range
        deviceDegree = deviceDegree >= 0 ? deviceDegree % 360 : deviceDegree % 360 + 360;
      } catch (exception) {
        Logger.error(TAG_LOG,
          `calculateDeviceDegree failed, code is ${exception.code}, message is ${exception.message}`);
      }
    }
    return deviceDegree;
  }

  private getPhotoDegree() {
    const promise: Promise<number> = new Promise(resolve => {
      try {
        sensor.once(sensor.SensorId.ACCELEROMETER, (data: sensor.AccelerometerResponse) => {
          let degree = this.calculateDeviceDegree(data.x, data.y, data.z);
          resolve(degree);
        });
      } catch (exception) {
        Logger.error(TAG_LOG, `getPhotoDegree failed, code is ${exception.code}, message is ${exception.message}`);
      }
    })
    return promise;
  }

  // [Start is_moving_photo]
  // Check whether support moving photo or not
  public isMovingPhotoSupported(photoOutput: camera.PhotoOutput): boolean {
    let isSupported: boolean = false;
    try {
      isSupported = photoOutput.isMovingPhotoSupported();
    } catch (error) {
      Logger.error(TAG_LOG, `The isMovingPhotoSupported call failed. error code: ${error.code}`);
    }
    return isSupported;
  }

  // [End is_moving_photo]

  // [Start enable_moving_photo]
  // Enable moving photo
  public enableMovingPhoto(enabled: boolean): void {
    try {
      this.output?.enableMovingPhoto(enabled);
    } catch (error) {
      Logger.error(TAG_LOG, `The enableMovingPhoto call failed. error code: ${error.code}`);
    }
  }

  // [End enable_moving_photo]

  // [Start photo_release]
  // Release photo
  async release() {
    try {
      await this.output?.release();
    } catch (exception) {
      Logger.error(TAG_LOG, `release failed, code is ${exception.code}, message is ${exception.message}`);
    }
    if (this.isSingle) {
      this.output?.off('photoAvailable');
    } else {
      this.output?.off('photoAssetAvailable');
    }
    this.output = undefined;
  }

  // [End photo_release]
}
// preparePhoto(session, zoomRatio?, flashMode?, focusMode?)
//
// 将 session 强转为 PhotoSession 并调用：
//
// setPhotoFlash(photoSession, flashMode)：若设备支持闪光（checkFlash），设置闪光模式（或默认关闭）。
//
// setPhotoFocus(photoSession, focusMode)：若支持该 focus mode，就设置（默认 CONTINUOUS_AUTO）。
//
// setPhotoZoomRatio(photoSession, zoomRatio || 0)：如果传入 zoomRatio 则设置，否则取 getZoomRatioRange() 的首个值（最小值）。
//
// 注意：
//
// setPhotoZoomRatio 里若没有 zoomRatio，会尝试从 photoSession.getZoomRatioRange() 取得合适值；若取不到则设置为 0。
//
// 所有对 session 的操作都有 try/catch 包裹并记录错误，这是良好实践。
//
// setColorSpaceBeforeCommitConfig(session, isHdr)
//
// 根据 isHdr 选择 DISPLAY_P3（HDR）或 SRGB。
//
// 查询 session.getSupportedColorSpaces()，若包含目标 color space 则 session.setColorSpace(colorSpace)，并记录当前 getActiveColorSpace()。
//
// try/catch 保护每一步，记录失败信息。
//
// 注意：
//
// 色彩空间只在支持时设置，避免不必要错误。
//
// 若需要 HDR 模式，还需保证拍照 profile 与输出格式支持，并在 UI 上提示用户 HDR 可用性。
//
// 六、拍照旋转与设备朝向（calculateDeviceDegree / getPhotoDegree / getPhotoRotation / capture）
//
// 流程：
//
// capture(isFront) 被调用：
//
// 先 degree = await this.getPhotoDegree()：通过一次性监听传感器 sensor.once(sensor.SensorId.ACCELEROMETER, handler) 得到重力加速度向量 (x,y,z)，再 calculateDeviceDegree 算出 0..359 的设备角度。
//
// rotation = this.getPhotoRotation(this.output!, degree)：根据 output.getPhotoRotation(deviceDegree) 得到平台需要的 camera.ImageRotation（内置 API 习惯）。
//
// 构造 settings: { quality, rotation, mirror: isFront } 并 this.output?.capture(settings, callback) 发起拍照。
//
// calculateDeviceDegree(x,y,z) 说明：
//
// 先用 (x*x + y*y)*3 < z*z 判定设备是否近似“垂直”（如果垂直返回 0）。
//
// 否则使用 atan2(y, -x)，把弧度转角度并做若干变换得到相对垂直方向的度数（deviceDegree = 90 - sc），并 normalize 到 0-360。
//
// 使用了 Decimal（高精度数学库）来计算 atan2 与 round，防止精度问题或平台差异。
//
// 注意：
//
// sensor.once() 可能超时或没有数据（sensor 不可用），当前实现没有超时 fallback；建议在 getPhotoDegree() 中增加超时（例如 200ms）后 resolve 默认角度，以免拍照阻塞。
//
// capture 的 callback 仅记录错误或成功日志，若失败应把错误反馈至 UI（提示用户拍照失败原因）。
//
// 七、相机能力接口（isMovingPhotoSupported / enableMovingPhoto）
//
// isMovingPhotoSupported(photoOutput)：检查当前 PhotoOutput 是否支持 moving photo。
//
// enableMovingPhoto(enabled)：调用 this.output?.enableMovingPhoto(enabled) 启用/禁用该特性（包装 try/catch）。
//
// 注意：
//
// 在启用某些高级特性前推荐调用 isMovingPhotoSupported 检查，避免无效调用。
//
// 若启用 moving photo，存储/回调逻辑可能需要调整以保存视频/动图等资源。
//
// 八、释放资源（release）
//
// await this.output?.release()：释放 native 资源，try/catch 捕获异常。
//
// 根据 isSingle 删除对应事件监听：this.output?.off('photoAvailable') 或 this.output?.off('photoAssetAvailable')。
//
// 最后把 this.output = undefined.
//
// 注意：
//
// 在释放之前应确保没有挂起的保存/处理任务（例如 mediaLibRequestBuffer 正在运行），否则可能造成竞态（对象已释放但回调仍然访问它）。
//
// 建议在释放前主动取消或等待所有未完成的异步任务（使用 AbortController 或内部标志）。