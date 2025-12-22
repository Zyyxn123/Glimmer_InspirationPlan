import { media } from '@kit.MediaKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';


const PFP_TAG: string = '[PFP_TAG]'
const PFP_DOMAIN = 0x0000

export class PlayerForPronunciation {
  private static playerForPronunciation: PlayerForPronunciation;
  private avPlayer: media.AVPlayer | undefined = undefined

  constructor() {
  }

  static Instance() {
    if (!PlayerForPronunciation.playerForPronunciation) {
      PlayerForPronunciation.playerForPronunciation = new PlayerForPronunciation();
    }
    hilog.info(PFP_DOMAIN, PFP_TAG, 'Instance get successfully')
    return PlayerForPronunciation.playerForPronunciation;
  }

  async getInit(){
    try {
      if (this.avPlayer == undefined) {
        let AvPlayer = await media.createAVPlayer();
        this.avPlayer = AvPlayer
      }

      this.avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
        switch (state) {
          case 'idle':
            console.info('state idle called');
            break;
          case 'initialized':
            console.info('initialized prepared called')
            this.avPlayer?.prepare((err: BusinessError) => {
              if (err) {
                hilog.info(PFP_DOMAIN, PFP_TAG, 'Failed to prepare, error message is :' + err.message)
              } else {
                hilog.info(PFP_DOMAIN, PFP_TAG, 'Succeeded in preparing')
              }
            })
            break
          case 'prepared':
            console.info('state prepared called')
            this.avPlayer?.play((err: BusinessError) => {
              if (err) {
                hilog.info(PFP_DOMAIN, PFP_TAG, 'Failed to play, error message is :' + err.message)
              } else {
                hilog.info(PFP_DOMAIN, PFP_TAG, 'Succeeded in play')
              }
            })
            break;
          case 'playing':
            console.info('state playing called');
            break;
          case 'paused':
            console.info('state paused called');
            break;
          case 'completed':
            console.info('state completed called')
            this.avPlayer?.stop((err: BusinessError) => {
              if (err) {
                hilog.info(PFP_DOMAIN, PFP_TAG, 'Failed to stop, error message is :' + err.message)
              } else {
                // this.avPlayer?.reset((err: BusinessError) => {
                //   if (err) {
                //     hilog.info(PFP_DOMAIN, PFP_TAG, 'Failed to reset, error message is :' + err.message)
                //   } else {
                //     hilog.info(PFP_DOMAIN, PFP_TAG, 'Succeeded in reset')
                //   }
                // })
                hilog.info(PFP_DOMAIN, PFP_TAG, 'Succeeded in stop')
              }
            })
            break;
          case 'stopped':
            console.info('state stopped called');
            break;
          case 'released':
            console.info('state released called');
            break;
          case 'error':
            console.info('state error called');
            break;
          default:
            console.info('unknown state :' + state);
            break;
        }
      })
    } catch (error) {
      hilog.info(PFP_DOMAIN, PFP_TAG, 'create avPlayer failed')
    }
  }


  // 播放操作。
  play(urls: string) {
    if (this.avPlayer == undefined) {
      hilog.info(PFP_DOMAIN, PFP_TAG, 'avPlayer is undefined')
      return
    }
    let url = urls
    this.avPlayer.url = url;
  }
}