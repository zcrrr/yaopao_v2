/**
 * <pre>
 * UserInfoManager登录信息管理
 * PageManager页面功能管理
 * </pre>
 *
 * file:移除跑友
 * author:ToT
 * date:2014-08-19
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

		//移除跑友
		$("#removeBtn").onbind("touchstart",this.btnDown,this);
		$("#removeBtn").onbind("touchend",this.removeBtnUp,this);
		
	},
	pageLoad:function(evt){
		var w = $(window).width();
		var h = $(window).height();
		//this.ratio = window.devicePixelRatio || 1;
		this.bodyWidth = w;

		//获取跑友数据
		this.getTeamMemberList();
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
		evt.preventDefault();
		//按钮按下通用高亮效果
		this.moved = false;
		var ele = evt.currentTarget;
		$(ele).addClass("curr");
	},

	/**
	 * 选择队员设置
	*/
	itemUp:function(evt){
		evt.preventDefault();
		var ele = evt.currentTarget;
		var dom = $(ele);
		dom.addClass("curr");

		setTimeout(function(){
			dom.removeClass("curr");
			dom.toggleClass("curr_d");
		},Base.delay);
	},

	/*
	 * 移除跑友
	*/
	removeBtnUp:function(evt){
		var ele = evt.currentTarget;
		setTimeout(function(){
			$(ele).removeClass("curr");
		},Base.delay);
		if(!this.moved){
			//获取选中了哪些
			var kickuid = [];
			var selected = $("#memberList .curr_d");
			for(var i = 0,len = selected.length; i < len; i++){
				var li = selected[i];
				var id = li.id.split('_')[1];
				var obj = this.memberData.list[id];
				var uid = obj.uid || "";
				kickuid.push(uid);
			}
			this.removeTeamMember(kickuid);
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
			this.iScrollY = new IScroll('#wrapper', {
				scrollbars: true,
				mouseWheel: true,
				click: true,
				tap: true,
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
		var options = {};
		//上报类型 1 手机端 2网站
		options.stype = 1;
		//用户ID,
		options.uid = "132";
		//组ID
		options.gid = 7;
		//比赛id,现在只有一个比赛 值=1
		//options.mid = 1;
		//客户端唯一标识
		options["X-PID"] = "tre211";
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
	},

	/*
	 * 移除跑友
	*/
	removeTeamMember:function(kickuid){
		var options = {};
		//上报类型 1 手机端 2网站
		options.stype = 1;
		//用户ID
		options.uid = "132";
		//kickuid 必须被T人员id（多人）例如:[234,222,221]
		options.kickuid = Base.json2Str(kickuid);
		//比赛id,现在只有一个比赛 值=1
		options.mid = 1;
		//组ID
		options.gid = 7;
		//客户端唯一标识
		options["X-PID"] = "tre211";

		var reqUrl = this.bulidSendUrl("/match/kickinggroup.htm",options);
		//console.log(reqUrl);
		
		$.ajaxJSONP({
			url:reqUrl,
			context:this,
			success:function(data){
				//console.log(data);
				var state = data.state.code - 0;
				if(state === 0){
					//隐藏移除跑友
					var selected = $("#memberList .curr_d");
					selected.hide();
					selected.removeClass("curr_d");
					
					this.initiScroll();
				}
				else{
					var msg = data.state.desc + "(" + state + ")";
					Base.alert(msg);
				}
			}
		});
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

				//移除跑友,不显示领队
				if(isleader !== 1){
					li.push('<li id="member_' + i + '">');
					li.push('<div class="head-img"><img src="' + imgpath + '" alt="" width="36" height="36"></div>');
					li.push('<p>' + nickname + '</p>');
					li.push('</li>');
					ul.push(li.join(''));
				}
			}

			$("#memberList").append(ul.join(''));

			$("#memberList > li").onbind("click",this.itemUp,this);

			this.initiScroll();
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



