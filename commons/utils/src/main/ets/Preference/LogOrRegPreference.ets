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