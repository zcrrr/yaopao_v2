/**
 * <pre>
 * UserInfoManager登录信息管理
 * PageManager页面功能管理
 * </pre>
 *
 * file:跑队设置
 * des:跑队包含未报名,已报名,加入跑队,比赛开始前1小时,比赛开始,比赛结束
 * author:ToT
 * date:2014-08-17
*/

var PageManager = function (obj){
	//继承父类 公用事件
	//TirosBase.apply(this,arguments);
	//继承父类 公用函数
	//TirosTools.apply(this,arguments);
	this.init.apply(this,arguments);
};


PageManager.prototype = {
	constructor:PageManager,
	iScrollX:null,
	httpId:null,
	//页面宽度
	bodyWidth:0,
	//当前用户状态,未注册,未报名,未组队,已组队,0,1,2,3
	userStatus:0,
	//当前比赛状态,报名阶段 - 组队阶段 - 设置第一棒阶段(赛前一小时) - 1小时倒计时进入比赛 - 比赛阶段 - 赛后阶段
	//0-5
	playStatus:0,
	//用户数据
	localUserInfo:{},
	//比赛明细数据
	playData:{},
	init: function(){
		this.httpTip = new HttpTip({scope:this});
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
		var w = $(window).width() || 320;
		//图片按9:5缩放
		var h = parseInt(5/9 * w);
		$("#viewport").css({"height":h + "px"});
	},
	pageBack:function(evt){
		if(!this.moved){
			//Base.pageBack(-1);
			if (Base.mobilePlatform.android){
				window.JSAndroidBridge.gotoPrePage();
			}
			else if(Base.mobilePlatform.iphone || Base.mobilePlatform.ipad){
				window.location.href=("objc:??gotoPrePage");
			}
			else{
				alert("调用本地goPersonal方法,PC不支持.");
			}
		}
	},
	pageMove:function(evt){
		this.moved = true;
	},
	
	/**
	 * 隐藏dom 卸载资源
	*/
	pageHide:function(){
	},
	
	/*
	 * 平台启动页面初始化参数
	*/
	initPageManager:function(){
		this.localUserInfo = Base.getLocalDataInfo();
		
		//请求比赛状态
		this.getCompetitionStatus();
	},
	btnDown:function(evt){
		//按钮按下通用高亮效果
		this.moved = false;
		var ele = evt.currentTarget;
		$(ele).addClass("curr");
	},
	/**
	 * 跳转到跑队设置页面/创建加入跑队页面
	*/
	teamBtnUp:function(evt){
		var ele = evt.currentTarget;
		setTimeout(function(){
			$(ele).removeClass("curr");
		},Base.delay);
		if(!this.moved){
			var type = $(ele).attr("data") || "";
			if(type !== ""){
				if(type == "setup"){
					//保存当前比赛状态
					Base.offlineStore.set("playstatus",this.playStatus,true);
					
					//跳转到跑队设置
					var isleader = this.localUserInfo.userinfo.isleader - 0 || 0;
					if(isleader){
						//领队跳转队员页面
						Base.toPage("team_member.html");
						/*
						if(this.playStatus == 2){
							//直接跳转到设置第一棒
							//跳转到设置第一棒
							Base.toPage("team_setbaton.html");
						}
						else{
							//领队跳转队员页面
							Base.toPage("team_member.html");
						}
						*/
					}
					else{
						//非领队跳转队员页面
						Base.toPage("team_member_play.html");
					}
				}
				else{
					//跳转到创建/加入跑对
				}
			}
			else{
				Base.alert("用户状态错误!!!");
			}
		}
		else{
			$(ele).removeClass("curr");
		}
	},
	
	/**
	 * 初始化滚动插件
	*/
	initiScroll:function(){
		if(this.iScrollX == null){
			/*
			//动态调整滚动插件宽高,
			var w = this.bodyWidth;
			//console.log(w)
			// var h = this.bodyHeight + "px";
			 var iw = w * 3;

			//this.iScroller[0].style.cssText = "";
			$("#viewport").css({"width":w + "px"});
			$("#scroller").css({"width":iw + "px"});
			$(".slide").css({"width":w + "px"});
			$(".scroller").css({"width":w + "px"});
			*/

			this.iScrollX = new IScroll('#wrapper',{
				scrollX:true,
				scrollY:true,
				momentum:false,
				snap:true,
				snapSpeed:400,
				scope:this
			});

			this.iScrollX.on('scrollEnd',function(){
				var scope = this.options.scope;
				var index = scope.cityIndex;
				
				var pageX = this.currentPage.pageX;
				if(index != pageX){
					var indicator = $("#indicator > li");
					indicator.removeClass("active");
					var li = indicator[pageX];
					li.className = "active";
				}
			});
		}
	},
	
	/**
	 * 获取比赛状态
	*/
	getCompetitionStatus:function(){
		var local = this.localUserInfo;
		var user = local.userinfo || {};
		var play = local.playinfo || {};
		var device = local.deviceinfo || {};

		var options = {};
		//上报类型 1 手机端 2网站
		options.stype = 1;
		//用户ID,未注册用户无此属性，如果有此属性后台服务会执行用户与设备匹配验证
		options.uid = user.uid || "";
		//比赛id,现在只有一个比赛 值=1
		options.mid = play.mid || 1;
		//客户端唯一标识
		options["X-PID"] = device.deviceid || "";
		var reqUrl = this.bulidSendUrl("/match/querymatchinfo.htm",options);
		//console.log(reqUrl);
		this.httpTip.show();
		$.ajaxJSONP({
			url:reqUrl,
			context:this,
			success:function(data){
				//console.log(data);
				var state = data.state.code - 0;
				if(state === 0){
					//this.changeSlideImage(data);
					//保存数据
					this.playData = data;
					
					//更新比赛状态/用户状态初始化页面
					this.userStatus = this.countUserStatus();
					this.playStatus = this.countPlayStatus(data);
					this.initLoadHtml();
				}
				else{
					var msg = data.state.desc + "(" + state + ")";
					Base.alert(msg);
				}
				this.httpTip.hide();
			}
		});
		/**/
	},

	/**
	 * 获取比赛总距离
	*/
	getPlayDistance:function(isLoad){
		var local = this.localUserInfo;
		var user = local.userinfo || {};
		var play = local.playinfo || {};
		var device = local.deviceinfo || {};

		var options = {};
		//上报类型 1 手机端 2网站
		options.stype = 1;
		//用户ID,未注册用户无此属性，如果有此属性后台服务会执行用户与设备匹配验证
		options.uid = user.uid || "";
		//比赛id,现在只有一个比赛 值=1
		options.mid = play.mid || 1;
		//客户端唯一标识
		options["X-PID"] = device.deviceid || "";

		var reqUrl = this.bulidSendUrl("/match/allrunmatch.htm",options);
		//console.log(reqUrl);
		if(isLoad){
			//定时器请求,不显示loading
			this.httpTip.show();
		}
		$.ajaxJSONP({
			url:reqUrl,
			context:this,
			success:function(data){
				//console.log(data);
				var state = data.state.code - 0;
				if(state === 0){
					var km = (data.allrun - 0) / 1000;
					var distance = this.raceDistance(km.toFixed(2));
					var distanceDiv = $("#distanceDiv");
					distanceDiv.html(distance);
					distanceDiv.show();

					//开定时器
					this.playTimeDistance();
				}
				else{
					var msg = data.state.desc + "(" + state + ")";
					Base.alert(msg);
				}
				this.httpTip.hide();
			}
		});
		/**/
	},

	/*
	 * 根据不同的用户状态和比赛状态动态显示页面
	*/
	initLoadHtml:function(){
		//dom
		var playTimeDiv = $("#playTimeDiv");
		var playStatus = $("#playStatus");
		var distanceDiv = $("#distanceDiv");
		var teamList = $("#teamList");
		var thirdWeb = $("#thirdWeb");

		//用户状态
		var us = this.userStatus;
		//比赛状态
		var ps = this.playStatus;
		//console.log(us,ps);
		var local = this.localUserInfo;
		var user = local.userinfo || {};
		//用户昵称
		var nickName = user.nickname || "用户昵称";
		//跑队名称
		var groupName = user.groupname || "跑队名称";
		//是否第一棒
		var isbaton = user.isbaton - 0 || 0;
		//头像
		var headimg = user.userphoto || "";

		//页面以显示高度
		var showHeight = 44;

		//显示比赛倒计时和进行时
		if(ps == 5){
			//结束比赛,隐藏时间
			playTimeDiv.hide();
		}
		else{
			//显示时间
			var time = this.countPlayTime();
			playTimeDiv.html(time);
			playTimeDiv.show();

			showHeight = showHeight + 50;
		}
		
		//隐藏文字提示
		//if((us == 2 || us == 3) && (ps == 3 || ps == 0)){
		if( (ps == 0) || 
			((us == 2 || us == 3) && ps == 1) || 
			((us == 2 || us == 3) && ps == 3) ){
			//未组队或者已组队,并且比赛状态再比赛前1小时
			//这时候需要隐藏文字提示
			playStatus.hide();
		}
		else{
			var text = [[],[],[],[]];
			text[0].push("");
			text[0].push("2014年北京要跑24小时接力赛报名阶段已结束");
			text[0].push("2014年北京要跑24小时接力赛报名阶段已结束");
			text[0].push("2014年北京要跑24小时接力赛报名阶段已结束");
			text[0].push("2014年北京要跑24小时接力赛正在进行中");
			text[0].push("2014年北京要跑24小时接力赛已完赛");
			text[1].push("");
			text[1].push("2014年北京要跑24小时接力赛报名阶段已结束");
			text[1].push("2014年北京要跑24小时接力赛报名阶段已结束");
			text[1].push("2014年北京要跑24小时接力赛报名阶段已结束");
			text[1].push("2014年北京要跑24小时接力赛正在进行中");
			text[1].push("2014年北京要跑24小时接力赛已完赛");
			text[2].push("");
			text[2].push("");
			text[2].push("2014年北京要跑24小时接力赛组队阶段已结束，跑队成员已不可变更.");
			text[2].push("");
			text[2].push("");
			text[2].push("");
			text[3].push("");
			text[3].push("");
			text[3].push("2014年北京要跑24小时接力赛组队阶段已结束，跑队成员已不可变更.");
			text[3].push("");
			text[3].push("");
			text[3].push("");
			//获取文字数据
			var t = text[us][ps];
			if(t !== ""){
				playStatus.html(t);
				playStatus.show();

				showHeight = showHeight + playStatus.height();
			}
			else{
				playStatus.hide();
			}
		}

		//比赛距离显示/隐藏
		if((us == 0 || us == 1) && (ps == 4 || ps == 5)){
			//未注册或者未登录 并且 比赛阶段/赛后阶段
			this.getPlayDistance(true);
			/*
			var distance = this.raceDistance();
			distanceDiv.html(distance);
			distanceDiv.show();
			*/

			showHeight = showHeight + 108;
		}
		else{
			distanceDiv.hide();
		}
		
		var html = [];
		//根据状态显示操作按钮
		if(us == 0 && ps == 0){
			//显示我要注册/登录
			html.push('<li>');
			html.push('<div class="head-img"><img id="_headimg" src="images/default-head-img.jpg" alt="" width="36" height="36"></div>');
			html.push('<p>');
			html.push('<span>未登录</span>');
			//html.push('<span>' + groupName + '</span>');
			html.push('</p>');
			html.push('</li>');
			html.push('<li id="_loginBtn" data="setup">注册/登录</li>');
			teamList.addClass("login-btn");
		}
		else if((us == 1) && ps == 0){
			//显示我要报名
			html.push('<li>');
			html.push('<div class="head-img"><img id="_headimg" src="images/default-head-img.jpg" alt="" width="36" height="36"></div>');
			html.push('<p>');
			html.push('<span>' + nickName + '</span>');
			//html.push('<span>' + groupName + '</span>');
			html.push('</p>');
			html.push('</li>');
			html.push('<li id="_signBtn" data="setup">我要报名</li>');
			teamList.addClass("login-btn");
		}
		else if(us == 2 && (ps == 0 || ps == 1)){
			//显示创建/加入跑队
			html.push('<li>');
			html.push('<div class="head-img"><img id="_headimg" src="images/default-head-img.jpg" alt="" width="36" height="36"></div>');
			html.push('<p>');
			html.push('<span>' + nickName + '</span>');
			html.push('</p>');
			html.push('</li>');
			html.push('<li id="_teamBtn" data="add">创建/加入跑队</li>');
			teamList.addClass("login-btn");
		}
		else if(us == 3 && (ps == 0 || ps == 1 || ps == 2)){
			//显示设置跑队
			html.push('<li>');
			html.push('<div class="head-img"><img id="_headimg" src="images/default-head-img.jpg" alt="" width="36" height="36"></div>');
			html.push('<p>');
			html.push('<span>' + nickName + '</span>');
			html.push('<span>' + groupName + '</span>');
			html.push('</p>');
			html.push('</li>');
			html.push('<li id="_teamBtn" data="setup">跑队设置</li>');
			teamList.addClass("login-btn");
		}
		else if((us == 2 || us == 3) && ps == 3){
			//显示跑队名称
			html.push('<li>');
			//判断是否第一棒
			if(isbaton == 1){
				html.push('<span class="baton">接力棒</span>');
			}
			html.push('<div class="head-img"><img id="_headimg" src="images/default-head-img.jpg" alt="" width="36" height="36"></div>');
			html.push('<p>');
			html.push('<span>' + nickName + '</span>');
			html.push('<span>' + groupName + '</span>');
			html.push('</p>');
			html.push('</li>');
			teamList.removeClass("login-btn");
		}

		if(html.length > 0){
			teamList.html(html.join(''));
			teamList.show();

			//跑队设置/创建/加入跑队事件
			$("#_teamBtn").onbind("touchstart",this.btnDown,this);
			$("#_teamBtn").onbind("touchend",this.teamBtnUp,this);

			showHeight = showHeight + teamList.height();
		}

		if(headimg !== ""){
			//获取图片dom
			var serverUrl = Base.offlineStore.get("local_picserver_url",true);
			var img = $("#_headimg");
			var imgUrl = serverUrl + headimg;
			//加载图片
			Base.imageLoaded(img,imgUrl);
		}

		//判断是否显示第三方网页
		if((us == 0 || us == 1) && ( ps != 0)){
			//改变第三方网页高度,让沾满全屏
			var w = $(window).width() || 320;
			var wh = $(window).height();
			//图片按9:5缩放
			var h = parseInt(5/9 * w);
			$("#viewport").css({"height":h + "px"});

			var th = wh - showHeight - h - 4;
			thirdWeb.height(th);

			thirdWeb.show();
		}
		else{
			thirdWeb.hide();
		}
	},

	/*
	 * 轮播广告图片
	*/
	changeSlideImage:function(obj){
		var img1 = obj.annoneimg || "";
		var img2 = obj.anntwoimg || "";
		var img3 = obj.annthreeimg || "";

		var html = [];
		if(img1 != ""){
			html.push(slide());
		}
		if(img2 != ""){
			html.push(slide());
		}
		if(img3 != ""){
			html.push(slide());
		}
		function slide(){
			var html = [];
			html.push('<div class="slide">');
			html.push('<img src="images/banner.jpg" alt="" width="320"/>');
			html.push('</div>');
			return html.join('');
		}
		
		if(html.length > 0){
			$("#viewport").show();
			$("#scroller").html(html.join(''));
			this.initiScroll();
			//保存url
			// this.mapOldUrl["cityMap" + code] = imgUrl;
			//获取图片dom
			var img = $("#scroller > div > img");
			var imgUrl = [img1,img2,img3];
			for(var i = 0,len = img.length; i < len; i++){
				//加载图片
				Base.imageLoaded($(img[i]),imgUrl[i]);
			}
		}
		else{
			//隐藏广告图片
			$("#viewport").hide();
		}
		
	},

	/*
	 * 计算比较倒计时和进行时
	*/
	countPlayTime:function(){
		//var time = "距比赛还有：<span>18</span><s>天</s><span>52</span><s>时</s><span>25</span><s>分</s><span>42</span><s>秒</s>";
		var time = "比赛未开始";
		var obj = this.playData;
		var now = new Date();
		var startTime = obj.starttime;
		//console.log(startTime);
		//startTime = "2014-09-30 8:0:0";
		var sDate = this.formatDate(startTime);
		//判断是倒计时 还是 正计时
		//1比赛开始 2未开始3 比赛结束
		var matchstate = obj.matchstate - 0;
		//matchstate = 2;
		
		if(matchstate == 1){
			//正计时
			if(sDate != null){
				var ms = now - sDate;
				time = this.formatMs(ms);
				time = "比赛已经开始：" + time;
			}
		}
		else if(matchstate == 2){
			//倒计时
			if(sDate != null){
				var ms = sDate - now;
				time = this.formatMs(ms);
				time = "距比赛还有：" + time;
			}
		}
		//启动计时time
		this.playTimeCountDown();

		return time;
	},

	formatDate:function(str){
		var date = null;
		var s1 = str.split(" ");
		if(s1.length == 2){
			var arr1 = s1[0].split("-");
			var arr2 = s1[1].split(":");

			if(arr1.length == 3 && arr2.length == 3){
				date = new Date(arr1[0],arr1[1] - 1,arr1[2],arr2[0],arr2[1],arr2[2]);
				return date;
			}
		}
		return date;
	},

	formatMs:function(ms){
		//debugger
		var time = parseInt(ms / 1000);
		if (time <= 60) {
			return "<span>" + time + "</span><s>秒</s>";
		} else if (time > 60 && time < 3600) {
			//秒
			var second = parseInt(time % 60);
			//分钟
			var minute = parseInt((time % 3600) / 60);
			return "<span>" + minute + "</span><s>分</s>" + "<span>" + second + "</span><s>秒</s>";
		} else if (time >= 3600 && time < 86400) {
			//秒
			var second = parseInt(time % 60);
			//分钟
			var minute = parseInt((time % 3600) / 60);
			var hour = parseInt(time / 3600);
			return "<span>" + hour + "</span><s>时</s><span>" + minute + "</span><s>分</s>" + "<span>" + second + "</span><s>秒</s>";
		} else {
			//秒
			var second = parseInt(time % 60);
			//分钟
			var minute = parseInt((time % 3600) / 60);
			//小时
			var temp_hour = parseInt((time % 86400) / 3600);
			var day = parseInt(time / 86400);
			return "<span>" + day + "</span><s>天</s><span>" + temp_hour + "</span><s>时</s><span>" + minute + "</span><s>分</s><span>" + second + "</span><s>秒</s>";
		}
	},

	/*
	 * 获取比赛总距离
	*/
	raceDistance:function(km){
		var html = [];
		html.push('<p class="p_km">' + km + '<span>KM</span></p>');
		html.push('<p class="p_distance">比赛总距离</p>');
		return html.join('');
	},

	/*
	 * 计算用户当前状态
	*/
	countUserStatus:function(){
		var status;
		var local = this.localUserInfo;
		var user = local.userinfo || {};
		var uid = user.uid || "";
		//报名ID
		var bid = user.bid || "";
		//组ID
		var gid = user.gid || "";
		if(uid == ""){
			//如果uid等于"",就标识未注册状态
			status = 0;
		}
		else if(bid == ""){
			//如果bid=="",就标识未报名
			status = 1;
		}
		else if(gid == ""){
			//如果gid=="",就标识未组队
			status = 2;
		}
		else{
			status = 3;
		}
		return status;
	},

	/*
	 * 计算比赛当前状态
	*/
	countPlayStatus:function(obj){
		//console.log(obj);
		var status;

		var local = this.localUserInfo;
		var user = local.userinfo || {};
		//组ID
		var gid = user.gid || "";

		//报名状态1可以报名 2报名未开始  3 报名过期
		var signstate = obj.signstate - 0 || 1;
		//组队状态1 允许组队 0不允许
		var groupstate = obj.groupstate - 0 || 0;
		//比赛状态1比赛开始 2未开始3 比赛结束
		var matchstate = obj.matchstate - 0 || 2;
		if(signstate == 2){
			//报名未开始,页面不显示操作按钮
			status = -1;
		}
		else if(signstate == 1){
			//报名阶段
			status = 0;
		}

		if(groupstate == 1){
			if(gid == ""){
				//如果没有组ID,那么应该就是组队阶段
				//组队阶段
				status = 1;
			}
			else{
				//可以组队,又有组ID了,应该就是设置第一棒的状态
				status = 2;
			}
		}
		else{
			//不允许组队,应该就进入赛前1小时阶段了
			status = 3;
		}

		if(matchstate == 1){
			//比赛开始
			status = 4;
		}
		else if(matchstate == 3){
			//比赛结束
			status = 5;
		}
		return status;
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
	 * 比赛倒计时定时器
	*/
	playTimeCountDown:function(){
		var t = this;
		var playTimeDiv = $("#playTimeDiv");
		this.tout = setTimeout(function(){
			var time = t.countPlayTime();
			playTimeDiv.html(time);
		},1000);
	},

	/**
	 * 比赛总距离定时器,5分钟一次
	*/
	playTimeDistance:function(){
		var t = this;
		var time = 5 * 60 * 1000;
		this.tout = setTimeout(function(){
			t.getPlayDistance(false);
		},time);
	},

	/**
	 * 关闭提示框
	*/
	closeTipBtnUp:function(evt){
		if(evt != null){
			var ele = evt.currentTarget;
			$(ele).removeClass("curr");
			if(!this.moved){
			}
		}
		else{
		}
	},
	
	/**
	 * 重试
	*/
	retryBtnUp:function(evt){
		var ele = evt.currentTarget;
		$(ele).removeClass("curr");
		if(!this.moved){
		}
	},
	
	/**
	 * 关闭http提示框,中断http请求
	*/
	closeHttpTip:function(){
		this.httpTip.hide();
		this.pageHide();
	}
};

//页面初始化
$(function(){
	Base.page = new PageManager({});
});



