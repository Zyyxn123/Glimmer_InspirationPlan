import { hilog } from '@kit.PerformanceAnalysisKit'
import { UserMsgRDBStore, resSetType } from 'utils'
import { JSON } from '@kit.ArkTS'

const DOMAIN: number = 0x0000
const TAG: string = '[BasicDataViewModelTag]'

@ObservedV2
export class BasicDataViewModel {
  @Trace itemLists: myBasicDataItemType[] = [
    {
      ilanFrom: 'k',
      ilanTo: 'k',
      ititle: '示例',
      itext: 'example',
      iisCollection: false
    }
  ]
  private static basicDataVM: BasicDataViewModel | undefined = undefined
  private userMsgRDBStore: UserMsgRDBStore = UserMsgRDBStore.Instance()
  private curACCount: string = AppStorage.get('curAccount')!

  static Instance() {
    if (!BasicDataViewModel.basicDataVM) {
      BasicDataViewModel.basicDataVM = new BasicDataViewModel()
    }
    hilog.info(DOMAIN, TAG, 'Instance get successful')
    return BasicDataViewModel.basicDataVM
  }

  collectionCtr() {

  }

  getAllCollectionMsg() {
    // this.userMsgRDBStore.queryMsg_row(this.curACCount)
    let msg: resSetType[] = this.userMsgRDBStore.MsgLists as resSetType[]
    console.log(TAG, msg.length.toString())
    console.log(TAG, this.userMsgRDBStore.MsgLists.length.toString())
    for (let i = 0; i < msg.length; i++) {
      let itemStr = msg[i].msg
      console.log(TAG, itemStr)
      let item = JSON.parse(itemStr) as myBasicDataItemType
      console.log('列表值没有的和有的收藏: ', this.itemLists[i].itext)
      if (item.iisCollection) {
        this.itemLists.push(item)
        console.log('列表值收藏: ', this.itemLists[i].itext)
      }
    }
  }
}

export interface myBasicDataItemType {
  ilanFrom: string
  ilanTo: string
  ititle: string
  itext: string
  iisCollection: boolean
}