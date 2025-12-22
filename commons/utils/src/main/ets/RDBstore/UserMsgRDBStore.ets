import { relationalStore } from '@kit.ArkData'; // 导入模块
import { Context, UIAbility } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { JSON } from '@kit.ArkTS';

const TAG: string = '[UserMsgRDBStoreTag]'
const DOMAIN: number = 0x0000

export class UserMsgRDBStore {
  myRDBStoreIns: relationalStore.RdbStore | undefined = undefined
  MsgLists: resSetType[] = []
  private static userMsgRDBStore: UserMsgRDBStore | undefined = undefined
  private storeConfig: relationalStore.StoreConfig = {
    name: 'RdbTest.db',
    securityLevel: relationalStore.SecurityLevel.S1
  }
  private TableName: string = 'userMsgTable'
  // 一个SQL语句，创建一个关系型数据库的表‘myTest’，id为数字且自增， acc为字符串且不为空，msg为字符串，age为数字
  private sqlCreateTable: string = `CREATE TABLE IF NOT EXISTS ${this.TableName} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ACC TEXT NOT NULL,
    MSG TEXT
    );`

  static Instance() {
    if (!UserMsgRDBStore.userMsgRDBStore) {
      UserMsgRDBStore.userMsgRDBStore = new UserMsgRDBStore()
    }
    hilog.info(DOMAIN, TAG, 'Instance get successful')
    return UserMsgRDBStore.userMsgRDBStore
  }

  getInit(context: Context) {
    relationalStore.getRdbStore(context, this.storeConfig, async (err, store: relationalStore.RdbStore) => {
      if (err) {
        hilog.error(DOMAIN, TAG, `Failed to get RdbStore. Code:${err.code}, message:${err.message}`)
        return
      }
      hilog.info(DOMAIN, TAG, 'Succeeded in getting RdbStore.')
      try {
        await store.execute(this.sqlCreateTable)
      } catch (error) {
        hilog.error(DOMAIN, TAG, `Failed to get Table. ${error}`)
      }
      hilog.info(DOMAIN, TAG, 'Succeeded in getting Table.')
      this.myRDBStoreIns = store
    })
  }

  InsertMsg_row(acc: string, msg: string) {
    const VB: relationalStore.ValuesBucket = {
      ACC: acc,
      MSG: msg
    }
    if (this.myRDBStoreIns != undefined) {
      (this.myRDBStoreIns as relationalStore.RdbStore).insert(this.TableName, VB,
        (err: BusinessError, rowId: number) => {
          if (err) {
            hilog.error(DOMAIN, TAG, `Insert is failed, code is ${err.code}, message is ${err.message}`)
            return;
          }
          hilog.info(DOMAIN, TAG, `Insert is successful, rowId = ${rowId}`)
        });
    } else {
      hilog.error(DOMAIN, TAG, 'InsertMsg_row myRDBStoreIns is undefined')
    }
  }

  upDateCollectionState(acc: string, oldMsg: string /*, newMsg: string*/) {
    let predicates1 = new relationalStore.RdbPredicates(this.TableName);
    predicates1.equalTo('MSG', oldMsg)
      .and()
      .equalTo('ACC', acc)

    let newMsg = oldMsg
    if (newMsg.slice(-6, -1) == 'false') {
      let tmp = (JSON.parse(newMsg) as myHistoryItemType)
      tmp.iisCollection = true
      newMsg = JSON.stringify(tmp)
      // newMsg
      hilog.info(DOMAIN, TAG, 'newMsg.slice(-6, -1) == \'false\':' + JSON.stringify(JSON.parse(newMsg)))
      hilog.info(DOMAIN, TAG, 'newMsg.slice(-6, -1) == \'false\':' + JSON.stringify(tmp))
    } else if (newMsg.slice(-5, -1) == 'true') {
      let tmp = (JSON.parse(newMsg) as myHistoryItemType)
      tmp.iisCollection = false
      newMsg = JSON.stringify(tmp)
    }
    let VB: relationalStore.ValuesBucket = {
      ACC: acc,
      MSG: newMsg
    }
    // hilog.info(DOMAIN, TAG, `update rows: ${oldMsg == newMsg}`)
    hilog.info(DOMAIN, TAG, `oldMsg length: ${oldMsg.length}`);
    // hilog.info(DOMAIN, TAG, `newMsg length: ${newMsg.length}`);
    if (this.myRDBStoreIns !== undefined) {
      (this.myRDBStoreIns as relationalStore.RdbStore).update(VB, predicates1, (err: BusinessError, rows: number) => {
        if (err) {
          hilog.error(DOMAIN, TAG, `Failed to update data, code is ${err.code},message is ${err.message}`)
          return;
        }
        hilog.info(DOMAIN, TAG, `update rows: ${rows}`)
        // hilog.info(DOMAIN, TAG, `account=${acc}, message=${newMsg}`)
      })
    }  else {
      hilog.error(DOMAIN, TAG, 'upDateCollectionState myRDBStoreIns is undefined')
    }
  }

  deleteMsg_row(acc: string/*, msg: string*/) {
    let predicates1 = new relationalStore.RdbPredicates(this.TableName);
    predicates1.equalTo('ACC', acc)
      // .and()
      // .equalTo('MSG', msg)
    if (this.myRDBStoreIns !== undefined) {
      (this.myRDBStoreIns as relationalStore.RdbStore).delete(predicates1, (err: BusinessError, rows: number) => {
        if (err) {
          hilog.error(DOMAIN, TAG, `Failed to delete data, code is ${err.code},message is ${err.message}`)
          return;
        }
        hilog.info(DOMAIN, TAG, `Delete rows: ${rows}`)
      })
    } else {
      hilog.error(DOMAIN, TAG, 'deleteMsg_row myRDBStoreIns is undefined')
    }
  }

  async queryMsg_row(acc: string) {
    let resSet: resSetType[] = []
    let predicates2 = new relationalStore.RdbPredicates(this.TableName);
    predicates2.equalTo('ACC', acc);
    if (this.myRDBStoreIns !== undefined) {
      (this.myRDBStoreIns as relationalStore.RdbStore).query(predicates2, ['ACC', 'MSG'], (err: BusinessError, resultSet) => {
          if (err) {
            hilog.error(DOMAIN, TAG, `Failed to query data, code is ${err.code},message is ${err.message}`)
            return;
          }
          hilog.info(DOMAIN, TAG, `ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.columnCount}`)
          try {
            while (resultSet.goToNextRow()) {
              const account = resultSet.getString(resultSet.getColumnIndex('ACC'));
              const message = resultSet.getString(resultSet.getColumnIndex('MSG'));
              const index = resultSet.rowIndex
              resSet.unshift({ acc: account, msg: message })
              // hilog.info(DOMAIN, TAG, 'resT' + JSON.stringify(resSet[0]))
              // console.info(`account=${account}, age=${age}, message=${message}`);
              hilog.info(DOMAIN, TAG, `account=${account}, message=${message}, index=${index}`)
            }
            this.MsgLists = resSet
          } catch (error) {}
          // 释放数据集的内存
          try {
            resultSet.close();
          } catch (error) {}
        })
    } else {
      hilog.error(DOMAIN, TAG, 'queryMsg_row myRDBStoreIns is undefined')
    }
  }
}

export interface resSetType {
  acc: string
  msg: string
}

export interface myHistoryItemType {
  ilanFrom: string
  ilanTo: string
  ititle: string
  itext: string
  iisCollection: boolean
}