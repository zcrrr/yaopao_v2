/**
 * <pre>
 * UserInfoManager登录信息管理
 * PageManager页面功能管理
 * </pre>
 *
 * file:系统详细消息
 * author:ToT
 * date:2014-08-28
*/

var PageManager = function (obj){
	this.init.apply(this,arguments);
};


PageManager.prototype = {
	constructor:PageManager,
	iScrollY:null,
	httpId:null,
	//页面宽度
	bodyWidth:0,
	//消息数据
	messageData:null,
	init: function(){
		//$(window).onbind("load",this.pageLoad,this);
		$(window).onbind("touchmove",this.pageMove,this);
		this.bindEvent();
	},
	bindEvent:function(){
		//返回按钮事件
		$("#backBtn").onbind("touchstart",this.btnDown,this);
		$("#backBtn").onbind("touchend",this.pageBack,this);
	},
	pageLoad:function(){
		var w = $(window).width();
		var h = $(window).height();
		//this.ratio = window.devicePixelRatio || 1;
		this.bodyWidth = w;
		//this.bodyHeight = h;

		//获取本地用户数据
		this.localUserInfo = Base.getLocalDataInfo();

		//请求详细消息
		this.getMessageById();
	},
	pageBack:function(evt){
		Base.pageBack(-1);
	},
	pageMove:function(evt){
		evt.preventDefault();
		this.moved = true;
	},
	
	/**
	 * 隐藏dom 卸载资源
	*/
	pageHide:function(){
	},
	
	btnDown:function(evt){
		//按钮按下通用高亮效果
		this.moved = false;
		var ele = evt.currentTarget;
		$(ele).addClass("curr");
	},
	
	/**
	 * 根据ID请求详情消息
	*/
	getMessageById:function(){
		var local = this.localUserInfo;
		var user = local.userinfo || {};
		var device = local.deviceinfo || {};
		var annid = Base.offlineStore.get("messagedetail_id",true) || "";

		var options = {};
		//用户ID,
		options.uid = user.uid || "";
		//客户端唯一标识
		options["X-PID"] = device.deviceid || "";
		//消息ID
		options.annid = annid;
		
		var reqUrl = this.bulidSendUrl("/match/announcementview.htm",options);
		//console.log(reqUrl);
		
		$.ajaxJSONP({
			url:reqUrl,
			context:this,
			success:function(data){
				//console.log(data);
				var state = data.state.code - 0;
				if(state === 0){
					this.changeMessageHtml(data);
				}
				else{
					var msg = data.state.desc + "(" + state + ")";
					Base.alert(msg);
				}
			}
		});
		/**/
	},

	/**
	 * 修改消息内容
	*/
	changeMessageHtml:function(obj){
		var msg = obj.content || "";
		var time = obj.addtime || "";
		var html = [];
		html.push('<h3>' + msg + '</h3>');
		html.push('<p>' + time + '</p>');

		var messageDiv = $("#messageDiv");
		messageDiv.html(html.join(''));
		messageDiv.show();
	},

	/**
	 * 生成请求地址
	 * server请求服务
	 * options请求参数
	*/
	bulidSendUrl:function(server,options){
		var serverUrl = Base.offlineStore.get("local_server_url",true) + "chSports";
		var url = serverUrl + server;

		var data = {};
		/*
		//个人信息
		var myInfo = Trafficeye.getMyInfo();
		var data = {
			"ua":myInfo.ua,
			"pid":myInfo.pid,
			"uid":myInfo.uid,
			"lon":this.lon,
			"lat":this.lat
		};
		*/
		//添加服务参数
		for(var k in options){
			data[k] = options[k];
		}
		//格式化请求参数
		var reqParams = Base.httpData2Str(data);
		var reqUrl = url + reqParams;
		return reqUrl;
	},


	/**
	 * 关闭提示框
	*/
	closeTipBtnUp:function(evt){
		if(evt != null){
			evt.preventDefault();
			var ele = evt.currentTarget;
			$(ele).removeClass("curr");
			if(!this.moved){
				$("#servertip").hide();
				this.isTipShow = false;
			}
		}
		else{
			$("#servertip").hide();
			this.isTipShow = false;
		}
	},
	
	/**
	 * 重试
	*/
	retryBtnUp:function(evt){
		evt.preventDefault();
		var ele = evt.currentTarget;
		$(ele).removeClass("curr");
		if(!this.moved){
			$("#servertip").hide();
			this.isTipShow = false;
			this.getPoiDetail();
			/*
			if(this.retrytype == "getPoiDetail"){
				this.getPoiDetail();
				this.$shareBox.hide();
				$(this.meetBtn).hide();
			}else if(this.retrytype == "getAibangServerData"){
				this.getAibangServerData();
			}
			*/
		}
	},
	
	/**
	 * 关闭http提示框,中断http请求
	*/
	closeHttpTip:function(){
		this.httpTip.hide();
		this.pageHide();
		//如果是没有POI基础数据弹出的loading,返回到前一页
		if(this.isBack){
			frame.pageBack();
		}
	}
};

//页面初始化
$(function(){
	Base.page = new PageManager({});
});



