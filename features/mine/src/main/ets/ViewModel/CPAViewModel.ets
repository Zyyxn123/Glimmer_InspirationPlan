import { DEFAULT } from '@ohos/hypium'
import hilog from '@ohos.hilog'
import { UserBasicMsgPreference } from 'utils'

const TAG: string = '[CPAViewModelTag]'
const DOMAIN: number = 0x0000

@ObservedV2
export class CPAViewModel {
  private static cpaViewModel: CPAViewModel | undefined = undefined
  private userBasicMsgPreference: UserBasicMsgPreference = UserBasicMsgPreference.Instance()
  @Trace pa: string[] = []
  @Trace selImg: string = ''

  static Instance() {
    if (CPAViewModel.cpaViewModel !== undefined) {
      return CPAViewModel.cpaViewModel
    }
    CPAViewModel.cpaViewModel = new CPAViewModel()
    return CPAViewModel.cpaViewModel
  }

  init() {
    if (this.selImg == '') {
      this.selImg ='app.media.avatar_1th'
    }

    for (let i = 1; i <= 9; i++) {
      let str: string = 'app.media.avatar_' + i + 'th'
      this.pa.push(str)
      hilog.info(DOMAIN, TAG, 'push:' + str + '; now length:' + this.pa.length)
      hilog.info(DOMAIN, TAG, 'push:' + str + '; now str:' + this.pa[i-1].toString())
      hilog.info(DOMAIN, TAG, 'push:' + str + '; now str:' + this.pa[i-1].toString().substring(17, 18))
    }
  }

  getCurPh() {
    this.selImg = this.userBasicMsgPreference.getPh()
  }
}