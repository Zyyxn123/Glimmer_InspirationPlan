import { dataType } from "../Model/SettingModel"
import { CPAViewModel } from "./CPAViewModel"


@ObservedV2
export class SettingViewModel {
  private static settingViewModel: SettingViewModel | undefined = undefined
  @Trace dataList: dataType[] = [
    {
      title: '头像',
      img: CPAViewModel.Instance().selImg,
      text: '',
      url: 'changePhotoAvatar',
      limit: ''
    },
    {
      title: '用户名',
      text: '用户名',
      url: 'changeBasicData',
      limit: ''
    },
    {
      title: '账号',
      text: '账号',
      url: 'changeBasicData',
      limit: '账号限制: 仅限a~z、A~Z、0~9'
    },
    {
      title: '密码',
      text: '密码',
      url: 'changeBasicData',
      limit: '密码限制: 仅限a~z、A~Z、0~9、*、_'
    },
    {
      title: '个性签名',
      text: '个性签名',
      url: 'changeBasicData',
      limit: '签名限制: 仅限50个字'
    },
  ]

  static Instance() {
    if (SettingViewModel.settingViewModel !== undefined) {
      return SettingViewModel.settingViewModel
    }
    SettingViewModel.settingViewModel = new SettingViewModel()
    return SettingViewModel.settingViewModel
  }
}