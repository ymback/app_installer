import {
  AbilityAware,
  AbilityPluginBinding,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import { common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

/** AppInstallerPlugin **/
export default class AppInstallerPlugin implements FlutterPlugin, MethodCallHandler, AbilityAware {
  private channel: MethodChannel | null = null;
  private context: common.UIAbilityContext | null = null;

  constructor() {
  }

  getUniqueClassName(): string {
    return "AppInstallerPlugin"
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.context = binding.getAbility().context
  }

  onDetachedFromAbility(): void {
    this.context = null
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "app_installer");
    this.channel.setMethodCallHandler(this)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method == "goStore") {
      let args: Map<string, ESObject> = call.args;
      let appId: string = args.get('ohosAppId')
      if (appId == null || appId.length == 0) {
        result.success(false)
        return
      }
      if (this.context != null) {
        this.openMarket(this.context, appId)
      }
      result.success(true)
    } else {
      result.notImplemented()
    }
  }


  async openMarket(context: common.UIAbilityContext, appId: string) {
    let want: Want = {
      action: 'ohos.want.action.appdetail',
      uri: 'store://appgallery.huawei.com/app/detail?id=C' + appId, //appId为需要打开应用详情的应用的appId
    };
    await context.startAbility(want)
      .then(() => {
      })
      .catch((err: BusinessError) => {
      });
  }
}