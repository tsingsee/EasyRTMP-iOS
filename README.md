# EasyRTMP-iOS #

EasyRTMP是[TSINGSEE青犀开放平台](http://open.tsingsee.com "TSINGSEE青犀开放平台")开发的一个RTMP流媒体音/视频直播推送产品组件，全平台支持(包括Windows/Linux(32 & 64)，ARM各平台，Android、iOS)，通过EasyRTMP我们就可以避免接触到稍显复杂的RTMP/FLV打包推送流程，只需要调用EasyRTMP的几个API接口，就能轻松、稳定地把流媒体音视频数据推送给RTMP流媒体服务器进行转发和分发，尤其是与[EasyDSS流媒体服务器](http://www.easydss.com "EasyDSS")、[EasyPlayer-RTMP播放器](https://github.com/EasyDSS/EasyPlayer-RTMP "EasyPlayer-RTMP")、[EasyPlayerPro播放器](https://github.com/EasyDSS/EasyPlayerPro "EasyPlayerPro")可以无缝衔接，EasyRTMP从16年开始发展和迭代，经过长时间的企业用户和项目检验，稳定性非常高;

EasyRTMP is a simple, robust, low latency RTMP video&audio&screen stream pusher and recorder on iOS. 精炼、稳定、高效的iOS前/后摄像头/手机桌面屏幕采集、编码、RTMP直播推送工具，充分秉承了RTMP在即时通信领域中的技术特点，网络条件满足的情况下，延时控制在300ms~500ms，非常适合于互联网直播、应急指挥、4G执法、远程遥控与视频直播等行业领域；


## 功能点支持 ##

- [x] 多分辨率选择；
- [x] `音视频`推送<!--、`纯音频`推送、`纯视频`推送-->；
<!--- [x] 支持`边采集、边录像`；-->
- [x] 稳定的录像、推流分离模式;<!--**支持推流过程中随时开启录像，录像过程中，随时推流；**-->
- [x] 采集过程中，前后摄像头切换；
<!--- [x] android完美支持`文字水印、实时时间水印`；-->
<!--- [x] 支持`推送端实时静音/取消静音`；-->
- [x] 支持软硬编码设置；
<!--- [x] android支持后台service推送摄像头或屏幕(推送屏幕需要5.0+版本)；-->
<!--- [x] 支持gop间隔、帧率、bierate、android编码profile和编码速度设置；-->
- [x] [音频]iOS支持噪音抑制功能；
- [x] [音频]iOS支持自动增益控制；
- [x] 配套EasyDSS流媒体服务器无缝衔接；

## 工作流程 ##

![EasyPusher Work Flow](http://www.easydarwin.org/github/images/easypusher/easypusher_android_workfolw.png)

## 版本下载 ##

- EasyRTMP iOS：支持前/后摄像头直播

	[https://itunes.apple.com/us/app/easyrtmp/id1222410811?mt=8](https://itunes.apple.com/us/app/easyrtmp/id1222410811?mt=8 "EasyRTMP_iOS")

	![EasyRTMP_iOS](http://www.easydarwin.org/github/images/app/2020/easyrtmp_iOS.png)



- EasyRTMP Android：支持前/后摄像头直播、安卓屏幕直播

	[http://d.firim.info/easyrtmp](http://d.firim.info/easyrtmp "http://d.firim.info/easyrtmp")

	![EasyRTMP Android](http://www.easydarwin.org/github/images/app/2020/easyrtmp_android.png)

## 调用过程 ##
![EasyRTMP](http://www.easydarwin.org/skin/easydarwin/images/easyrtmp20161101.png)


## 技术支持 ##

- 邮件：[support@tsingsee.com](mailto:support@tsingsee.com) 

- QQ交流群：<a href="https://jq.qq.com/?_wv=1027&k=5dkmdix" title="EasyRTMP" target="_blank">**587254841**</a>

<br/>

### ✈ 更多视频解决方案资源汇总

- 流媒体技术：<br/>
© EasyDarwin开源流媒体服务器：<a href="http://www.easydarwin.org" target="_blank" title="EasyDarwin开源流媒体服务器">http://www.easydarwin.org</a><br/>
© TSINGSEE视频开放平台：<a href="http://open.tsingsee.com" target="_blank" title="TSINGSEE青犀视频开放平台">http://open.tsingsee.com</a><br/>

- 视频云服务：<br/>
© EasyDSS互联网视频云服务：<a href="http://www.easydss.com" target="_blank" title="EasyDSS互联网视频云服务">http://www.easydss.com</a><br/>
© EasyCVR安防视频云服务：<a href="http://www.easycvr.com" target="_blank" title="EasyCVR安防视频云服务">http://www.easycvr.com</a><br/>
© EasyGBS国标视频云服务：<a href="http://www.easygbs.com" target="_blank" title="EasyGBS国标视频云服务">http://www.easygbs.com</a><br/>
© EasyRTC在线视频会议平台：<a href="http://www.easyrtc.cn" target="_blank" title="EasyRTC在线视频会议平台">http://www.easyrtc.cn</a><br/>
© EasyRTS即时通信云服务：<a href="http://www.easyrts.com" target="_blank" title="EasyRTS即时通信云服务">http://www.easyrts.com</a><br/>

- 边缘计算：<br/>
© EasyNVR视频边缘计算网关：<a href="http://www.easynvr.com" target="_blank" title="EasyNVR视频边缘计算网关">http://www.easynvr.com</a><br/>
© EasyNTS上云网关：<a href="http://www.easynts.com" target="_blank" title="EasyNTS上云网关">http://www.easynts.com</a><br/>

© TSINGSEE Team：<a href="http://www.tsingsee.com" target="_blank" title="青犀TSINGSEE">http://www.tsingsee.com</a><br/>

![青犀TSINGSEE](http://www.easydarwin.org/public/images/tsingsee_qrcode_160.jpg)

