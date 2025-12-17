import { preferences } from '@kit.ArkData';
import { UIAbility } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { JSON } from '@kit.ArkTS';

const TAG: string = '[LogOrRegPreferenceTag]'
const DOMAIN: number = 0x0000

export class LogOrRegPreference {
  private static logOrRegPreference: LogOrRegPreference | undefined = undefined
  myPreference: preferences.Preferences | null = null

  static Instance() {
    if (!LogOrRegPreference.logOrRegPreference) {
      LogOrRegPreference.logOrRegPreference = new LogOrRegPreference();
    }
    hilog.info(DOMAIN, TAG, 'LogOrRegPreference Instance create successfully')
    return LogOrRegPreference.logOrRegPreference;
  }

  initPre(context: Context) {
    let options: preferences.Options = { name: 'myLogOrRegPreference' };
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

  setLoginState(bool: boolean) {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return
    }
    try {
      this.myPreference.putSync('LoginState', bool)
      this.myPreference.flush((err) => {
        if (err) {
          hilog.error(DOMAIN, TAG, 'myPreference setLoginState flush failed')
        }
        hilog.info(DOMAIN, TAG, 'myPreference setLoginState flush successfully')
      })
      hilog.info(DOMAIN, TAG, 'myPreference getLoginState: ' + `${bool}`)
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference setLoginState check failed')
    }
  }

  getLoginState() {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return false
    }
    try {
      let bol = this.myPreference.getSync('LoginState', false) as boolean
      hilog.info(DOMAIN, TAG, 'myPreference getLoginState: ' + `${bol}`)
      return bol
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference getLoginState check failed')
      return false
    }
  }

  setCurAcc(acc: string) {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return
    }
    try {
      this.myPreference.putSync('curAccount', acc)
      this.myPreference.flush((err) => {
        if (err) {
          hilog.error(DOMAIN, TAG, 'myPreference setCurAcc flush failed')
        }
        hilog.info(DOMAIN, TAG, 'myPreference setCurAcc flush successfully')
      })
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference setCurAcc check failed')
    }
  }

  getCurAcc() {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return 'default'
    }
    try {
      let strAcc: string = this.myPreference.getSync('curAccount', 'default') as string
      hilog.info(DOMAIN, TAG, 'myPreference getCurAcc: ' + strAcc)
      return strAcc
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference getCurAcc check failed')
      return 'default'
    }
  }

  isHasAcc(account: string): boolean {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return false
    }
    try {
      let bol = this.myPreference.hasSync(account)
      return bol
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference account check failed')
      return false
    }
  }

  getPsw(account: string): string {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return ''
    }
    try {
      let strPsw: string = this.myPreference.getSync(account, '') as string
      hilog.info(DOMAIN, TAG, 'myPreference getPsw: ' + strPsw)
      return strPsw
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference account check failed')
      return ''
    }
  }

  registerAcc(account: string, password: string) {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return
    }
    try {
      this.myPreference.putSync(account, password)
      console.log('要修改的密码是registerAcc：' + account + ';' + password)
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

  deleteAcc(account: string) {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return
    }
    try {
      this.myPreference.deleteSync(account)
      this.myPreference.flush((err) => {
        if (err) {
          hilog.error(DOMAIN, TAG, 'myPreference deleteAcc flush failed')
        }
        hilog.info(DOMAIN, TAG, 'myPreference deleteAcc flush successfully')
      })
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference deleteAcc failed: ' + JSON.stringify(error))
    }
  }

  deleteMsg() {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return
    }
    try {
      this.myPreference.deleteSync(AppStorage.get('curAccount') + 'totalSearchNum')
      this.myPreference.deleteSync(AppStorage.get('curAccount') + 'totalStudyNum')
      this.myPreference.deleteSync(AppStorage.get('curAccount') + 'totalLivenessPer')
      this.myPreference.deleteSync(AppStorage.get('curAccount') + 'curDate')
      this.myPreference.deleteSync(AppStorage.get('curAccount') + 'curAccSignInDateCount')
      this.myPreference.deleteSync(AppStorage.get('curAccount') + 'IsFirstSignToday')
      // this.myPreference.deleteSync(AppStorage.get('curAccount') + 'curDate')
      this.myPreference.flush((err) => {
        if (err) {
          hilog.error(DOMAIN, TAG, 'myPreference deleteMsg flush failed')
        }
        hilog.info(DOMAIN, TAG, 'myPreference deleteMsg flush successfully')
      })
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference deleteMsg failed: ' + JSON.stringify(error))
    }
  }

  setCurAccTotalSearchNum(num: number) {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return
    }
    try {
      this.myPreference.putSync(AppStorage.get('curAccount') + 'totalSearchNum', num)
      this.myPreference.flush((err) => {
        if (err) {
          hilog.error(DOMAIN, TAG, 'myPreference setCurAccTotalSearchNum flush failed')
        }
        hilog.info(DOMAIN, TAG, 'myPreference setCurAccTotalSearchNum flush successfully: ' + num.toString())
      })
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference setCurAccTotalSearchNum putSync failed')
    }
  }

  setCurAccTotalStudyNum(num: number) {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return
    }
    try {
      this.myPreference.putSync(AppStorage.get('curAccount') + 'totalStudyNum', num)
      this.myPreference.flush((err) => {
        if (err) {
          hilog.error(DOMAIN, TAG, 'myPreference setCurAccTotalStudyNum flush failed')
        }
        hilog.info(DOMAIN, TAG, 'myPreference setCurAccTotalStudyNum flush successfully: ' + num.toString())
      })
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference setCurAccTotalStudyNum putSync failed')
    }
  }

  setCurAccTotalLivenessPer(num: number) {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return
    }
    try {
      this.myPreference.putSync(AppStorage.get('curAccount') + 'totalLivenessPer', num)
      this.myPreference.flush((err) => {
        if (err) {
          hilog.error(DOMAIN, TAG, 'myPreference setCurAccTotalLivenessPer flush failed')
        }
        hilog.info(DOMAIN, TAG, 'myPreference setCurAccTotalLivenessPer flush successfully: ' + num.toString())
      })
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference setCurAccTotalLivenessPer putSync failed')
    }
  }

  getCurAccTotalLivenessPer() {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return 0
    }
    try {
      let strPsw: number = this.myPreference.getSync(AppStorage.get('curAccount') + 'totalLivenessPer', 0) as number
      hilog.info(DOMAIN, TAG, 'myPreference getCurAccTotalLivenessPer: ' + strPsw)
      return strPsw
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference account check failed')
      return 0
    }
  }

  getCurAccTotalStudyNum() {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return 0
    }
    try {
      let strPsw: number = this.myPreference.getSync(AppStorage.get('curAccount') + 'totalStudyNum', 0) as number
      hilog.info(DOMAIN, TAG, 'myPreference getCurAccTotalStudyNum: ' + strPsw)
      return strPsw
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference account check failed')
      return 0
    }
  }

  getCurAccTotalSearchNum() {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return 0
    }
    try {
      let strPsw: number = this.myPreference.getSync(AppStorage.get('curAccount') + 'totalSearchNum', 0) as number
      hilog.info(DOMAIN, TAG, 'myPreference getCurAccTotalSearchNum: ' + strPsw)
      return strPsw
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference account check failed')
      return 0
    }
  }

  setCurAccDate() {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return
    }
    try {
      let date = new Date()
      this.myPreference.putSync(AppStorage.get('curAccount') + 'curDate', date.toISOString().split('T')[0].toString())
      this.myPreference.flush((err) => {
        if (err) {
          hilog.error(DOMAIN, TAG, 'myPreference setCurAccDate flush failed')
        }
        hilog.info(DOMAIN, TAG, 'myPreference setCurAccDate flush successfully: ' + date.toISOString().split('T')[0].toString())
      })
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference setCurAccDate putSync failed')
    }
  }

  getCurAccDate() {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return '2025-12-17'
    }
    try {
      let strPsw: string = this.myPreference.getSync(AppStorage.get('curAccount') + 'curDate', '2025-12-17') as string
      hilog.info(DOMAIN, TAG, 'myPreference getCurAccDate: ' + strPsw)
      return strPsw
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference getCurAccDate check failed')
      return '2025-12-17'
    }
  }

  /**
   * return '0 0':
   *  first zero: sign in total counts
   *  second zero: sign in consistent days counts
   * */
  getCurAccSignInDateCount() {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return '0 0'
    }
    try {
      let strPsw: string = this.myPreference.getSync(AppStorage.get('curAccount') + 'curAccSignInDateCount', '0 0') as string
      hilog.info(DOMAIN, TAG, 'myPreference getCurAccSignInDateCount: ' + strPsw)
      return strPsw
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference getCurAccSignInDateCount check failed')
      return '0 0'
    }
  }

  setCurAccSignInDateCount(str: string) {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return
    }
    try {
      this.myPreference.putSync(AppStorage.get('curAccount') + 'curAccSignInDateCount', str)
      this.myPreference.flush((err) => {
        if (err) {
          hilog.error(DOMAIN, TAG, 'myPreference setCurAccSignInDateCount flush failed')
        }
        hilog.info(DOMAIN, TAG, 'myPreference setCurAccSignInDateCount flush successfully: ' + str)
      })
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference setCurAccSignInDateCount putSync failed')
    }
  }

  getIsFirstSignToday() {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return true
    }
    try {
      let strPsw: boolean = this.myPreference.getSync(AppStorage.get('curAccount') + 'IsFirstSignToday', true) as boolean
      hilog.info(DOMAIN, TAG, 'myPreference getIsFirstSignToday: ' + strPsw)
      return strPsw
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference getIsFirstSignToday check failed')
      return true
    }
  }

  setIsFirstSignState(bool: boolean) {
    if (!this.myPreference) {
      hilog.info(DOMAIN, TAG, 'myPreference create failed')
      return
    }
    try {
      this.myPreference.putSync(AppStorage.get('curAccount') + 'IsFirstSignToday', bool)
      this.myPreference.flush((err) => {
        if (err) {
          hilog.error(DOMAIN, TAG, 'myPreference setIsFirstSignState flush failed')
        }
        hilog.info(DOMAIN, TAG, 'myPreference setIsFirstSignState flush successfully: ' + bool)
      })
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'myPreference setIsFirstSignState putSync failed')
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