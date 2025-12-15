import { hilog } from '@kit.PerformanceAnalysisKit'
import { UserMsgRDBStore, resSetType } from 'utils'
import { JSON } from '@kit.ArkTS'

const DOMAIN: number = 0x0000
const TAG: string = '[myHistoryViewModelTag]'

@ObservedV2
export class myHistoryViewModel {
  @Trace itemLists: myHistoryItemType[] = [
    {
      ilanFrom: 'k',
      ilanTo: 'k',
      ititle: '示例',
      itext: 'example',
      iisCollection: false
    }
  ]
  private static myHisVM: myHistoryViewModel | undefined = undefined
  private userMsgRDBStore: UserMsgRDBStore = UserMsgRDBStore.Instance()
  private inputMsg: myHistoryItemType | undefined = undefined
  private curACCount: string = AppStorage.get('curAccount')!

  static Instance() {
    if (!myHistoryViewModel.myHisVM) {
      myHistoryViewModel.myHisVM = new myHistoryViewModel()
    }
    hilog.info(DOMAIN, TAG, 'Instance get successful')
    return myHistoryViewModel.myHisVM
  }

  getAllHistoryMsg() {
    // this.userMsgRDBStore.queryMsg_row(this.curACCount)
    let msg: resSetType[] = this.userMsgRDBStore.MsgLists as resSetType[]
    console.log('awfawfawfawfawf: length', msg.length.toString())
    console.log('awfawfawfawfawf: lengths', this.userMsgRDBStore.MsgLists.length.toString())
    for (let i = 0; i < msg.length; i++) {
      let itemStr = msg[i].msg
      console.log('awfawfawfawfawf', itemStr)
      let item = JSON.parse(itemStr) as myHistoryItemType
      this.itemLists.push(item)
      console.log('列表值: ', this.itemLists[i].itext)
    }
  }

  putMsgItem(lanFrom: string, lanTo: string, title: string, text: string, isCollection: boolean) {
    this.inputMsg = {
      ilanFrom: lanFrom,
      ilanTo: lanTo,
      ititle: title,
      itext: text,
      iisCollection: isCollection
    }
    console.log('awfawfawfawfawfs', JSON.stringify(this.inputMsg))
    if (title == this.itemLists[0].ititle) {

    } else {
      this.itemLists.unshift(this.inputMsg)
      this.userMsgRDBStore.InsertMsg_row(this.curACCount, JSON.stringify(this.inputMsg))
    }
  }
}

export interface myHistoryItemType {
  ilanFrom: string
  ilanTo: string
  ititle: string
  itext: string
  iisCollection: boolean
}