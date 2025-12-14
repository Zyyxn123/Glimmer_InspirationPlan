import { relationalStore } from '@kit.ArkData'; // 导入模块
import { Context, UIAbility } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = '[UserMsgRDBStoreTag]'
const DOMAIN: number = 0x0000

export class UserMsgRDBStore {
  myRDBStoreIns: relationalStore.RdbStore | undefined = undefined
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
      (this.myRDBStoreIns as relationalStore.RdbStore).insert(this.TableName, VB, (err: BusinessError, rowId: number) => {
        if (err) {
          hilog.error(DOMAIN, TAG, `Insert is failed, code is ${err.code}, message is ${err.message}`)
          return;
        }
        hilog.info(DOMAIN, TAG, `Insert is successful, rowId = ${rowId}`)
      });
    }
  }

  upDateAge(age: string) {

  }

  deleteMsg_row(acc: string, msg: string) {
    let predicates1 = new relationalStore.RdbPredicates(this.TableName);
    predicates1.equalTo('ACC', acc)
      .and()
      .equalTo('MSG', msg)
    if (this.myRDBStoreIns !== undefined) {
      (this.myRDBStoreIns as relationalStore.RdbStore).delete(predicates1, (err: BusinessError, rows: number) => {
        if (err) {
          hilog.error(DOMAIN, TAG, `Failed to delete data, code is ${err.code},message is ${err.message}`)
          return;
        }
        hilog.info(DOMAIN, TAG, `Delete rows: ${rows}`)
      })
    }
  }

  queryMsg_row(acc: string) {
    let predicates2 = new relationalStore.RdbPredicates(this.TableName);
    predicates2.equalTo('ACC', acc);
    if (this.myRDBStoreIns !== undefined) {
      (this.myRDBStoreIns as relationalStore.RdbStore).query(predicates2, ['ACC', 'MSG'], (err: BusinessError, resultSet) => {
        if (err) {
          hilog.error(DOMAIN, TAG, `Failed to query data, code is ${err.code},message is ${err.message}`)
          return;
        }
        hilog.info(DOMAIN, TAG, `ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.columnCount}`)
        // resultSet是一个数据集合的游标，默认指向第-1个记录，有效的数据从0开始。
        try {
          while (resultSet.goToNextRow()) {
            const account = resultSet.getString(resultSet.getColumnIndex('ACC'));
            const message = resultSet.getString(resultSet.getColumnIndex('MSG'));
            const index = resultSet.rowIndex
            // console.info(`account=${account}, age=${age}, message=${message}`);
            hilog.info(DOMAIN, TAG, `account=${account}, message=${message}, index=${index}`)
          }
        } catch (error) {

        }
        // 释放数据集的内存
        try {
          resultSet.close();
        } catch (error) {

        }
      })
    }
  }
}








