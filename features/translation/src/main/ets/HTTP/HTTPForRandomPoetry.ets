import { http } from '@kit.NetworkKit'
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { buffer, JSON } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

const POETRY_URL: string = 'https://v2.xxapi.cn/api/yiyan'

@ObservedV2
export class  HTTPForRandomPoetry {
  @Trace static  poetry: string = ''

  static httpRequestForPoetry() {
    let httpRequest = http.createHttp();
    httpRequest.on('headersReceive', (header) => {
      console.info('header: ' + JSON.stringify(header));
    });
    httpRequest.request(
      POETRY_URL + '?type=poetry',
      {
        method: http.RequestMethod.GET,
        // 开发者根据自身业务需要添加header字段。
        header: {
          'Content-Type': 'application/json'
        },
      }, (err: BusinessError, data: http.HttpResponse) => {
      if (!err) {
        // data.result为HTTP响应内容，可根据业务需要进行解析。
        console.info('Resultss:' + JSON.stringify(data.result));
        let poetry: httpRequestForPoetryType = JSON.parse(data.result.toString()) as httpRequestForPoetryType
        HTTPForRandomPoetry.poetry = poetry.data
        httpRequest.destroy();
      } else {
        console.error('error:' + JSON.stringify(err));
        httpRequest.off('headersReceive');
        httpRequest.destroy();
      }
    }
    );

  }
}

interface httpRequestForPoetryType {
  code: string
  data: string
  msg: string
}