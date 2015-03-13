/**
 * <pre>
 * UserInfoManager登录信息管理
 * PageManager页面功能管理
 * </pre>
 *
 * file:跑队成员列表,设置第一棒
 * author:ToT
 * date:2014-08-19
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
	//队员数据
	memberData:null,
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
	pageLoad:function(evt){
		var w = $(window).width();
		var h = $(window).height();
		//this.ratio = window.devicePixelRatio || 1;
		this.bodyWidth = w;
		//this.bodyHeight = h;

		//获取本地用户数据
		this.localUserInfo = Base.getLocalDataInfo();
		//根据状态初始化页面
		this.initLoadHtml();

		//请求队员列表
		this.getTeamMemberList();
	},
	pageBack:function(evt){
		Base.pageBack(-1);
	},
	pageMove:function(evt){
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
	 * 队员设置
	*/
	itemUp:function(evt){
		var ele = evt.currentTarget;
		setTimeout(function(){
			$(ele).removeClass("curr");
		},Base.delay);
		if(!this.moved){
			$("#memberList > li").removeClass("selected");
			$(ele).addClass("selected");
			var id = ele.id.split("_")[1];

		}
		else{
			$(ele).removeClass("curr");
		}
	},

	/*
	 * 修改密码
	*/
	updatePwdBtnUp:function(evt){
		var ele = evt.currentTarget;
		setTimeout(function(){
			$(ele).removeClass("curr");
		},Base.delay);
		if(!this.moved){
			//跳转到修改密码
			Base.toPage("team_updatepwd.html");
		}
		else{
			$(ele).removeClass("curr");
		}
	},

	/*
	 * 从队中移除跑友/选择第一棒
	*/
	memberSetupBtnUp:function(evt){
		var ele = evt.currentTarget;
		setTimeout(function(){
			$(ele).removeClass("curr");
		},Base.delay);
		if(!this.moved){
			var id = ele.id;
			switch(id){
				case "delete":
					//跳转到移除跑友
					Base.toPage("team_removemember.html");
				break
				case "select":
				case "selectFirstBtn":
					//跳转到设置第一棒
					Base.toPage("team_setbaton.html");
				break;
			}
		}
		else{
			$(ele).removeClass("curr");
		}
	},

	/*
	 * 跳转到解散跑队页面
	*/
	disbandBtnUp:function(evt){
		var ele = evt.currentTarget;
		setTimeout(function(){
			$(ele).removeClass("curr");
		},Base.delay);
		if(!this.moved){
			//跳转到解散跑队页面
			Base.toPage("team_disband.html");
		}
		else{
			$(ele).removeClass("curr");
		}
	},

	/**
	 * 初始化滚动插件
	*/
	initiScroll:function(){
		if(this.iScrollY == null){
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
			this.iScrollY = new IScroll('#wrapper', {
				scrollbars: true,
				mouseWheel: true,
				interactiveScrollbars: true,
				shrinkScrollbars: 'scale',
				fadeScrollbars: true
			});
		}
		else{
			this.iScrollY.refresh();
		}
	},
	
	/**
	 * 请求跑队队员列表
	*/
	getTeamMemberList:function(){
		var local = this.localUserInfo;
		var user = local.userinfo || {};
		var device = local.deviceinfo || {};

		var options = {};
		//上报类型 1 手机端 2网站
		options.stype = 1;
		//用户ID,
		options.uid = user.uid || "";
		//组ID
		options.gid = user.gid || "";
		//比赛id,现在只有一个比赛 值=1
		//options.mid = 1;
		//客户端唯一标识
		options["X-PID"] = device.deviceid || "";
		//第几页
		options.cpage = 1;
		//每页多少条
		options.pagesize = 30;
		
		var reqUrl = this.bulidSendUrl("/match/querygroupry.htm",options);
		//console.log(reqUrl);
		this.httpTip.show();
		$.ajaxJSONP({
			url:reqUrl,
			context:this,
			success:function(data){
				//console.log(data);
				var state = data.state.code - 0;
				if(state === 0){
					this.memberData = data;
					this.changeMemberHtml(data);
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
	 * 修改队员列表
	*/
	changeMemberHtml:function(obj){
		var data = obj.list || "";
		if(data instanceof Array){
			var ul = [];
			for(var i = 0,len = data.length; i < len; i++){
				var li = [];
				var list = data[i];
				//是否头棒 1/0 是/否
				var isbaton = list.isbaton - 0 || 0;
				//是否领队 1/0  是/否
				var isleader = list.isleader - 0 || 0;
				var nickname = list.nickname || "昵称";
				//头像
				var imgpath = list.imgpath || "images/default-head-img.jpg";
				if(imgpath != "images/default-head-img.jpg"){
					var serverUrl = Base.offlineStore.get("local_picserver_url",true);
					imgpath = serverUrl + imgpath;
				}

				li.push('<li id="member_' + i + '">');
				if(isbaton === 1){
					li.push('<span class="baton">接力棒</span>');
				}
				if(isleader === 1){
					li.push('<span class="leader">领队</span>');
				}
				li.push('<div class="head-img"><img src="' + imgpath + '" alt="" width="36" height="36"></div>');
				li.push('<p>' + nickname + '</p>');
				li.push('</li>');
				ul.push(li.join(''));
			}

			$("#memberList").html(ul.join(''));
			this.initiScroll();
		}
	},

	/*
	 * 根据比赛状态显示页面
	*/
	initLoadHtml:function(){
		var status = Base.offlineStore.get("playstatus",true) - 0;
		switch(status){
			case 1:
				//组队阶段
				$("#wrapper").css("bottom","123px");
				$("#isbatonStatus").hide();
				$("#groupStatus").show();

				//修改密码
				$("#updatePwdBtn").rebind("touchstart",this.btnDown,this);
				$("#updatePwdBtn").rebind("touchend",this.updatePwdBtnUp,this);
				
				//从队中移除跑友/选择第一棒
				$("#memberSetupBtn > li").rebind("touchstart",this.btnDown,this);
				$("#memberSetupBtn > li").rebind("touchend",this.memberSetupBtnUp,this);

				//解散跑队
				$("#disbandBtn").rebind("touchstart",this.btnDown,this);
				$("#disbandBtn").rebind("touchend",this.disbandBtnUp,this);
			break;
			case 2:
				//设置第一棒阶段
				$("#wrapper").css("bottom","40px");
				$("#groupStatus").hide();
				$("#isbatonStatus").show();

				//选择第一棒事件
				$("#selectFirstBtn").rebind("touchstart",this.btnDown,this);
				$("#selectFirstBtn").rebind("touchend",this.memberSetupBtnUp,this);
			break;
		}
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



