import { preferences } from '@kit.ArkData';
import { UIAbility } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { JSON } from '@kit.ArkTS';

const TAG: string = '[UserBasicMsgPreference]'
const DOMAIN: number = 0x0000
const ph: string = 'ph'
const userName: string = 'userName'
const acc: string = AppStorage.get('curAccount')!
const psw: string = 'psw'
const sign: string = 'sign'

export class UserBasicMsgPreference {
  private static userBasicMsgPreference: UserBasicMsgPreference | undefined = undefined
  myPreference: preferences.Preferences | null = null

  static Instance() {
    if (!UserBasicMsgPreference.userBasicMsgPreference) {
      UserBasicMsgPreference.userBasicMsgPreference = new UserBasicMsgPreference();
    }
    hilog.info(DOMAIN, TAG, 'UserBasicMsgPreference Instance create successfully')
    return UserBasicMsgPreference.userBasicMsgPreference;
  }

  initPre(context: Context) {
    let options: preferences.Options = { name: 'myUserBasicMsgPreference' };
    let dataPreferences: preferences.Preferences | null = null

    try {
      dataPreferences = preferences.getPreferencesSync(context, options);
      this.myPreference = dataPreferences
      hilog.info(DOMAIN, TAG, 'succeed in create myPreference')
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'failed in create myPreference')
      return
    }
  }

  isHasPh(): boolean {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return false
    }
    try {
      let bol = this.myPreference.hasSync(acc + ph)
      return bol
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference isHasPh check failed')
      return false
    }
  }

  isHasUserName(): boolean {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return false
    }
    try {
      let bol = this.myPreference.hasSync(acc + userName)
      return bol
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference isHasUserName check failed')
      return false
    }
  }

  isHasSignature(): boolean {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return false
    }
    try {
      let bol = this.myPreference.hasSync(acc + sign)
      return bol
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference isHasSignature check failed')
      return false
    }
  }

  getPh(): string {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return 'app.media.avatar_1th'
    }
    try {
      let strPh: string = this.myPreference.getSync(acc + ph, 'app.media.avatar_1th') as string
      hilog.info(DOMAIN, TAG, 'myPreference getPh: ' + strPh)
      return strPh
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference getPh failed')
      return 'app.media.avatar_1th'
    }
  }

  getUserName(): string {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return '默认用户名'
    }
    try {
      let strUserName: string = this.myPreference.getSync(acc + userName, '默认用户名') as string
      hilog.info(DOMAIN, TAG, 'myPreference getUserName: ' + strUserName)
      return strUserName
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference getUserName failed')
      return '默认用户名'
    }
  }

  getSignature(): string {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return '该用户还未设置签名'
    }
    try {
      let strSignature: string = this.myPreference.getSync(acc + sign, '该用户还未设置签名') as string
      hilog.info(DOMAIN, TAG, 'myPreference getSignature: ' + strSignature)
      return strSignature
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference getSignature failed')
      return '该用户还未设置签名'
    }
  }

  registerAcc(account: string, password: string) {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return
    }
    try {
      this.myPreference.putSync(account, password)
      this.myPreference.flush((err) => {
        if (err) {
          hilog.error(DOMAIN, TAG, 'myPreference registerAcc flush failed')
        }
        hilog.info(DOMAIN, TAG, 'myPreference registerAcc flush successfully')
      })
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference registerAcc putSync failed')
    }
  }

  setPh(uri: string) {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return
    }
    try {
      this.myPreference.putSync(acc + ph, uri)
      this.myPreference.flush((err) => {
        if (err) {
          hilog.error(DOMAIN, TAG, 'setPh flush failed')
        }
        hilog.info(DOMAIN, TAG, 'setPh flush successfully')
      })
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'setPh putSync failed')
    }
  }

  getAllAcc() {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return
    }
    try {
      let value: object = this.myPreference.getAllSync()
      let allKeys = getObjKeys(value)
      hilog.info(DOMAIN, TAG, 'getAll keys = ' + allKeys)
      hilog.info(DOMAIN, TAG, "getAll object = " + JSON.stringify(value))
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference getAllAcc failed')
    }
  }

  clearAllAcc() {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return
    }
    try {
      this.myPreference.clearSync()
      hilog.info(DOMAIN, TAG, 'myPreference clearSync successfully')
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference getAllAcc failed')
    }
  }
}

function getObjKeys(obj: Object): string[] {
  let keys = Object.keys(obj);
  return keys;
}