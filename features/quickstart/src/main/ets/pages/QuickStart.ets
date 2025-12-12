import { LoginPage } from './LoginPage'
import { MainPage } from './MainPage';

AppStorage.setOrCreate('LoginState', false)
AppStorage.setOrCreate('curAccount', '')

@Component
export struct QuickStart {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageLink('LoginState') loginState: boolean = false
  @StorageLink('PageInfos') pageInfo: NavPathStack = new NavPathStack();

  aboutToAppear(): void {

  }

  build() {
      if (this.loginState) {
        MainPage()
      } else {
        LoginPage()
      }
  }
}