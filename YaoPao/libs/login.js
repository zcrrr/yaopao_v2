/**
 *
 * file:保存个人登录数据
 * des:社区页面全部迁移到个人里面,登录
 * author:ToT
 * date:2014-08-02
*/
//页面初始化

(function(window){
	//初始化页面函数
	window.callbackInit = function(userinfo,playinfo,deviceinfo,serverurl,picurl){
		var obj = {};
		if(userinfo != ""){
			userinfo = Base.str2Json(userinfo);
		}
		if(playinfo != ""){
			playinfo = Base.str2Json(playinfo);
		}
		if(deviceinfo != ""){
			deviceinfo = Base.str2Json(deviceinfo);
		}
		obj.userinfo = userinfo;
		obj.playinfo = playinfo;
		obj.deviceinfo = deviceinfo;
		var dataStr = Base.json2Str(obj);
		//保存数据到本地
		Base.offlineStore.set("_localuserinfo",dataStr);
		//保存请求地址到本地
		Base.offlineStore.set("local_server_url",serverurl,true);
		//调用页面初始化方法
		//保存图片URL
		Base.offlineStore.set("local_picserver_url",picurl,true);
		initPage();
	};

	//回调计数,超过10次就不回调了
	var i = 0;
	function initPage(){
		if(Base.page != null){
			if(typeof Base.page.initPageManager == "function"){
				Base.page.initPageManager();
			}
			else{
				if(i < 10){
					i++;
					setTimeout(function(){
						initPage();
					},100);
				}
			}
		}
		else{
			setTimeout(function(){
				initPage();
			},100);
		}
	}

	//刷新页面,ios返回不会刷新
	window.pageLoad = function(){
		initLoadPage();
	};

	//回调计数,超过10次就不回调了
	var j = 0;
	function initLoadPage(){
		if(Base.page != null){
			if(typeof Base.page.pageLoad == "function"){
				Base.page.pageLoad();
			}
			else{
				if(j < 10){
					j++;
					setTimeout(function(){
						initLoadPage();
					},100);
				}
			}
		}
		else{
			setTimeout(function(){
				initLoadPage();
			},100);
		}
	}
}(window));

/*
$(function(){
	//测试数据
	var userinfo = {};
	userinfo.uid = "";
	userinfo.bid = "1";
	userinfo.gid = "1";
	userinfo.username = "";
	userinfo.nikename = "没啥意思a";
	userinfo.groupname = "爱玩跑队";
	userinfo.isleader = "1";
	userinfo.isbaton = "1";
	var playinfo = {};
	playinfo.mid = 1;
	var deviceinfo = {};
	deviceinfo.deviceid = "99000314911470";
	deviceinfo.platform = "android";
	//window.callbackInit(Base.json2Str(userinfo),Base.json2Str(playinfo),Base.json2Str(deviceinfo),"http://182.92.97.144:8080/");
	//window.callbackInit('{"bid":1,"gid":3,"groupname":"CCC","isbaton":"0","isleader":"0","nickname":"13122233308","uid":"","username":"","userphoto":"/image/20140916/120_EBFA23903D7E11E4A6869FF80F14043D.jpg"}','{"etime":"","mid":"1","stime":""}','{"deviceid":"99000314911470","platform":"android"}','http://182.92.97.144:8080/')
	//window.callbackInit('{"bid":"1","gid":"1","groupname":"CCC","isbaton":"0","isleader":"1","nickname":"13122233302","uid":"3","username":"","userphoto":"/image/20140916/120_EBFA23903D7E11E4A6869FF80F14043D.jpg"}','{"etime":"","mid":"1","stime":""}','{"deviceid":"99000314911470","platform":"android"}','http://182.92.97.144:8080/')
	//window.callbackInit('{"bid":"1","gid":"2","groupname":"BBBB","isbaton":"1","isleader":"0","nickname":"13122233306","uid":"6","username":"","userphoto":"/image/20140916/120_EBFA23903D7E11E4A6869FF80F14043D.jpg"}','{"etime":"","mid":"1","stime":""}','{"deviceid":"99000314911470","platform":"android"}','http://182.92.97.144:8080/')
	//window.callbackInit('{"bid":"","gid":"","groupname":"BBBB","isbaton":"1","isleader":"0","nickname":"13122233306","uid":"","username":"","userphoto":"/image/20140916/120_EBFA23903D7E11E4A6869FF80F14043D.jpg"}','{"etime":"","mid":"1","stime":""}','{"deviceid":"99000314911470","platform":"android"}','http://182.92.97.144:8080/')
	//window.callbackInit('{"bid":"1","gid":"2","groupname":"CCC","isbaton":"0","isleader":"1","nickname":"13122233305","uid":"5","username":"","userphoto":"/image/20140916/120_EBFA23903D7E11E4A6869FF80F14043D.jpg"}','{"etime":"","mid":"1","stime":""}','{"deviceid":"99000314911470","platform":"android"}','http://182.92.97.144:8080/')
	//window.callbackInit('{"bid":"","gid":"","groupname":"","isbaton":"0","isleader":"0","nickname":"","uid":"","username":"","userphoto":""}','{"etime":"","mid":1,"stime":""}','{"deviceid":"99000314911470","platform":"android"}','http://182.92.97.144:8080/')
	//window.callbackInit('{"bid":"1","gid":"2","groupname":"要跑一队","isbaton":"0","isleader":"1","nickname":"13122233305","uid":5,"username":"","userphoto":"/image/20140916/120_EBFA23903D7E11E4A6869FF80F14043D.jpg"}','{"etime":"","mid":1,"stime":""}','{"deviceid":"99000314911470","platform":"android"}','http://182.92.97.144:8080/','http://yaopaotest.oss-cn-beijing.aliyuncs.com')
	//window.callbackInit('{\"uid\":\"3\",\"bid\":\"1\",\"gid\":\"1\",\"username\":\"\",\"nickname\":\"13122233303\",\"groupname\":\"AAA\",\"userphoto\":\"/image/20140916/120_EBFA23903D7E11E4A6869FF80F14043D.jpg\",\"isleader\":\"1\",\"isbaton\":\"1\"}','{\"mid\":\"1\",\"stime\":\"\",\"etime\":\"\"}','{\"deviceid\":\"1CF4A942-04BC-4579-832A-CB27F6BBF206\",\"platform\":\"ios\"}','http://182.92.97.144:8080/','http://yaopaotest.oss-cn-beijing.aliyuncs.com')
	//window.callbackInit('{"bid":"1","gid":"2","groupname":"要跑一队","isbaton":"0","isleader":"1","nickname":"13122233305","uid":5,"username":"","userphoto":"/image/20140916/120_EBFA23903D7E11E4A6869FF80F14043D.jpg"}','{"etime":"","mid":1,"stime":""}','{"deviceid":"99000314911470","platform":"android"}','http://182.92.97.144:8080/','http://yaopaotest.oss-cn-beijing.aliyuncs.com')
	window.callbackInit('{"bid":"1","gid":"1","groupname":"要跑一队","isbaton":"0","nickname":"15810880522","uid":11,"username":""}','{"etime":"","mid":1,"stime":""}','{"deviceid":"99000314911470","platform":"android"}','http://182.92.97.144:8080/','http://yaopaotest.oss-cn-beijing.aliyuncs.com')

});
*/


