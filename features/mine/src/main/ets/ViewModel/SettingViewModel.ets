import { dataType } from "../Model/SettingModel"
import { CPAViewModel } from "./CPAViewModel"
import { ComponentsColor, LogOrRegPreference, UserBasicMsgPreference } from "utils"

@ObservedV2
export class SettingViewModel {
  private static settingViewModel: SettingViewModel | undefined = undefined
  private  logOrRegPreference: LogOrRegPreference = LogOrRegPreference.Instance()
  private userBasicMsgPreference: UserBasicMsgPreference = UserBasicMsgPreference.Instance()
  @Trace ph: string = 'app.media.avatar_1th'
  @Trace account: string = ''
  @Trace userName: string = '默认用户名'
  @Trace password: string = ''
  @Trace signature: string = '该用户还未设置签名'
  @Trace dataList: dataType[] = [
    {
      title: '头像',
      img: '',
      text: '',
      url: 'changePhotoAvatar',
      limit: ''
    },
    {
      title: '用户名',
      text: '默认用户名',
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
      text: '该用户还未设置签名',
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

  setCurACC() {
    if (AppStorage.get('curAccount') !== undefined) {
      this.dataList[2].text = AppStorage.get('curAccount')!
      this.account = AppStorage.get('curAccount')!
    }
  }

  setPsw() {
    if (AppStorage.get('curAccount') !== undefined) {
      this.dataList[3].text = this.logOrRegPreference.getPsw(AppStorage.get('curAccount')!)
      this.password = this.logOrRegPreference.getPsw(AppStorage.get('curAccount')!)

      console.log('要修改的密码是setPsw：' + this.password)
    }
  }

  setPh() {
    if (this.userBasicMsgPreference.isHasPh()) {
      this.dataList[0].img = this.userBasicMsgPreference.getPh()
      this.ph = this.userBasicMsgPreference.getPh()
    } else {
      this.dataList[0].img = 'app.media.avatar_1th'
      this.ph = 'app.media.avatar_1th'
    }
  }

  setUserName() {
    if (this.userBasicMsgPreference.isHasUserName()) {
      this.dataList[1].text = this.userBasicMsgPreference.getUserName()
      this.userName = this.userBasicMsgPreference.getUserName()
      console.log('nodwdwadawd: ', this.dataList[1].text)
    } else {
      this.dataList[1].text = '默认用户名'
      this.userName = '默认用户名'
    }
  }

  setSignature() {
    if (this.userBasicMsgPreference.isHasSignature()) {
      this.dataList[4].text = this.userBasicMsgPreference.getSignature()
      this.signature = this.userBasicMsgPreference.getSignature()
    } else {
      this.dataList[4].text = '该用户还未设置签名'
      this.signature = '该用户还未设置签名'
    }
  }
}