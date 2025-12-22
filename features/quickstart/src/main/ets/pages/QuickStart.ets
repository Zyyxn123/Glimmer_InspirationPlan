import { LogOrRegPreference, UserMsgRDBStore } from 'utils';
import { LoginPage } from './LoginPage'
import { MainPage } from './MainPage';
import { common } from '@kit.AbilityKit';

AppStorage.setOrCreate('LoginState', false)

@Component
export struct QuickStart {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageLink('LoginState') loginState: boolean = false
  @StorageLink('PageInfos') pageInfo: NavPathStack = new NavPathStack();
  private userMsgRDBStore: UserMsgRDBStore = UserMsgRDBStore.Instance()
  private context: common.Context = this.getUIContext().getHostContext() as common.Context
  private logOrRegPreference: LogOrRegPreference = LogOrRegPreference.Instance()

  aboutToAppear(): void {
    this.userMsgRDBStore.getInit(this.context)

    AppStorage.set('curAccount', this.logOrRegPreference.getCurAcc())
  }

  build() {
      if (this.loginState) {
        MainPage()
      } else {
        LoginPage()
      }
  }
}